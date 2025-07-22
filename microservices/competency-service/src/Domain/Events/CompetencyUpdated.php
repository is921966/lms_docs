<?php

namespace CompetencyService\Domain\Events;

use CompetencyService\Domain\Common\DomainEvent;
use CompetencyService\Domain\ValueObjects\CompetencyId;

final class CompetencyUpdated implements DomainEvent
{
    private CompetencyId $competencyId;
    private string $name;
    private string $description;
    private \DateTimeImmutable $occurredAt;
    
    public function __construct(
        CompetencyId $competencyId,
        string $name,
        string $description
    ) {
        $this->competencyId = $competencyId;
        $this->name = $name;
        $this->description = $description;
        $this->occurredAt = new \DateTimeImmutable();
    }
    
    public function getAggregateId(): string
    {
        return $this->competencyId->toString();
    }
    
    public function getOccurredAt(): \DateTimeImmutable
    {
        return $this->occurredAt;
    }
    
    public function getEventName(): string
    {
        return 'competency.updated';
    }
    
    public function toArray(): array
    {
        return [
            'competency_id' => $this->competencyId->toString(),
            'name' => $this->name,
            'description' => $this->description,
            'occurred_at' => $this->occurredAt->format('Y-m-d H:i:s')
        ];
    }
} 