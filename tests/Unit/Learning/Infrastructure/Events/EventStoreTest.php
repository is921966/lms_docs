<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Infrastructure\Events;

use Learning\Domain\Events\CourseCreated;
use Learning\Domain\ValueObjects\CourseId;
use Learning\Domain\ValueObjects\CourseCode;
use Learning\Domain\ValueObjects\CourseStatus;
use Learning\Infrastructure\Events\EventStore;
use PHPUnit\Framework\TestCase;
use Doctrine\DBAL\Connection;
use Doctrine\DBAL\Statement;
use Doctrine\DBAL\Result;

class EventStoreTest extends TestCase
{
    private Connection $connection;
    private EventStore $eventStore;
    
    protected function setUp(): void
    {
        $this->connection = $this->createMock(Connection::class);
        $this->eventStore = new EventStore($this->connection);
    }
    
    public function testStoreEvent(): void
    {
        // Arrange
        $event = CourseCreated::create(
            CourseId::fromString('course-123'),
            CourseCode::fromString('PHP-101'),
            'PHP Basics',
            'Learn PHP from scratch',
            CourseStatus::draft()
        );
        
        $this->connection->expects($this->once())
            ->method('insert')
            ->with(
                'domain_events',
                $this->callback(function ($data) {
                    return $data['aggregate_id'] === 'course-123'
                        && $data['event_name'] === 'course.created'
                        && $data['event_version'] === 1
                        && is_string($data['event_data'])
                        && isset($data['occurred_at']);
                })
            );
        
        // Act
        $this->eventStore->store($event);
    }
    
    public function testGetEventsForAggregate(): void
    {
        // Arrange
        $aggregateId = 'course-123';
        
        $mockStatement = $this->createMock(Statement::class);
        $mockResult = $this->createMock(Result::class);
        
        $mockResult->expects($this->once())
            ->method('fetchAllAssociative')
            ->willReturn([
                [
                    'event_name' => 'course.created',
                    'event_data' => json_encode([
                        'course_id' => 'course-123',
                        'course_code' => 'PHP-101',
                        'title' => 'PHP Basics'
                    ]),
                    'occurred_at' => '2025-07-01 12:00:00',
                    'event_version' => 1
                ]
            ]);
        
        $mockStatement->expects($this->once())
            ->method('executeQuery')
            ->willReturn($mockResult);
        
        $this->connection->expects($this->once())
            ->method('prepare')
            ->with($this->stringContains('SELECT * FROM domain_events WHERE aggregate_id = ?'))
            ->willReturn($mockStatement);
        
        // Act
        $events = $this->eventStore->getEventsForAggregate($aggregateId);
        
        // Assert
        $this->assertCount(1, $events);
        $this->assertEquals('course.created', $events[0]['event_name']);
    }
    
    public function testGetEventsByType(): void
    {
        // Arrange
        $eventType = 'course.created';
        $limit = 10;
        
        $mockStatement = $this->createMock(Statement::class);
        $mockResult = $this->createMock(Result::class);
        
        $mockResult->expects($this->once())
            ->method('fetchAllAssociative')
            ->willReturn([
                [
                    'event_name' => 'course.created',
                    'aggregate_id' => 'course-123',
                    'event_data' => json_encode(['title' => 'PHP Basics']),
                    'occurred_at' => '2025-07-01 12:00:00'
                ],
                [
                    'event_name' => 'course.created',
                    'aggregate_id' => 'course-456',
                    'event_data' => json_encode(['title' => 'JavaScript Basics']),
                    'occurred_at' => '2025-07-01 13:00:00'
                ]
            ]);
        
        $mockStatement->expects($this->once())
            ->method('executeQuery')
            ->willReturn($mockResult);
        
        $this->connection->expects($this->once())
            ->method('prepare')
            ->with($this->stringContains('SELECT * FROM domain_events WHERE event_name = ?'))
            ->willReturn($mockStatement);
        
        // Act
        $events = $this->eventStore->getEventsByType($eventType, $limit);
        
        // Assert
        $this->assertCount(2, $events);
        $this->assertEquals('course-123', $events[0]['aggregate_id']);
        $this->assertEquals('course-456', $events[1]['aggregate_id']);
    }
    
    public function testGetLastEventVersion(): void
    {
        // Arrange
        $aggregateId = 'course-123';
        
        $mockStatement = $this->createMock(Statement::class);
        $mockResult = $this->createMock(Result::class);
        
        $mockResult->expects($this->once())
            ->method('fetchOne')
            ->willReturn(5);
        
        $mockStatement->expects($this->once())
            ->method('executeQuery')
            ->willReturn($mockResult);
        
        $this->connection->expects($this->once())
            ->method('prepare')
            ->with($this->stringContains('SELECT MAX(event_version)'))
            ->willReturn($mockStatement);
        
        // Act
        $version = $this->eventStore->getLastEventVersion($aggregateId);
        
        // Assert
        $this->assertEquals(5, $version);
    }
} 