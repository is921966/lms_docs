<?php

namespace CompetencyService\Domain\Events;

use CompetencyService\Domain\Common\DomainEvent;
use CompetencyService\Domain\ValueObjects\CompetencyId;
use CompetencyService\Domain\ValueObjects\CompetencyCode;

final class CompetencyCreated implements DomainEvent
{
    private CompetencyId $competencyId;
    private CompetencyCode $code;
    private string $name;
    private string $description;
    private string $category;
    private \DateTimeImmutable $occurredAt;
    
    public function __construct(
        CompetencyId $competencyId,
        CompetencyCode $code,
        string $name,
        string $description,
        string $category
    ) {
        $this->competencyId = $competencyId;
        $this->code = $code;
        $this->name = $name;
        $this->description = $description;
        $this->category = $category;
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
        return 'competency.created';
    }
    
    public function toArray(): array
    {
        return [
            'competency_id' => $this->competencyId->toString(),
            'code' => $this->code->getValue(),
            'name' => $this->name,
            'description' => $this->description,
            'category' => $this->category,
            'occurred_at' => $this->occurredAt->format('Y-m-d H:i:s')
        ];
    }
} 