<?php

declare(strict_types=1);

namespace Learning\Infrastructure\Events;

use Common\Interfaces\DomainEventInterface;
use Doctrine\DBAL\Connection;
use DateTimeImmutable;

final class EventStore
{
    public function __construct(
        private readonly Connection $connection
    ) {
    }
    
    public function store(DomainEventInterface $event): void
    {
        $eventData = $event->toArray();
        
        $aggregateId = $event->getAggregateId();
        $version = $this->getLastEventVersion($aggregateId) + 1;
        
        $this->connection->insert('domain_events', [
            'aggregate_id' => $aggregateId,
            'event_name' => $event->getEventName(),
            'event_version' => $version,
            'event_data' => json_encode($eventData),
            'occurred_at' => $event->getOccurredAt()->format('Y-m-d H:i:s'),
            'created_at' => (new DateTimeImmutable())->format('Y-m-d H:i:s')
        ]);
    }
    
    /**
     * @return array<int, array<string, mixed>>
     */
    public function getEventsForAggregate(string $aggregateId): array
    {
        $sql = 'SELECT * FROM domain_events WHERE aggregate_id = ? ORDER BY event_version ASC';
        $statement = $this->connection->prepare($sql);
        $result = $statement->executeQuery([$aggregateId]);
        
        return $result->fetchAllAssociative();
    }
    
    /**
     * @return array<int, array<string, mixed>>
     */
    public function getEventsByType(string $eventType, int $limit = 100): array
    {
        $sql = 'SELECT * FROM domain_events WHERE event_name = ? ORDER BY occurred_at DESC LIMIT ?';
        $statement = $this->connection->prepare($sql);
        $result = $statement->executeQuery([$eventType, $limit]);
        
        return $result->fetchAllAssociative();
    }
    
    public function getLastEventVersion(string $aggregateId): int
    {
        $sql = 'SELECT MAX(event_version) FROM domain_events WHERE aggregate_id = ?';
        $statement = $this->connection->prepare($sql);
        $result = $statement->executeQuery([$aggregateId]);
        
        $version = $result->fetchOne();
        
        return $version !== false ? (int)$version : 0;
    }
    
    /**
     * @return array<int, array<string, mixed>>
     */
    public function getEventsSince(DateTimeImmutable $since): array
    {
        $sql = 'SELECT * FROM domain_events WHERE occurred_at > ? ORDER BY occurred_at ASC';
        $statement = $this->connection->prepare($sql);
        $result = $statement->executeQuery([$since->format('Y-m-d H:i:s')]);
        
        return $result->fetchAllAssociative();
    }
} 