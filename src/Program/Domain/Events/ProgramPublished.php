<?php

declare(strict_types=1);

namespace Program\Domain\Events;

use Common\Domain\DomainEvent;
use Program\Domain\ValueObjects\ProgramId;

final class ProgramPublished implements DomainEvent
{
    private ProgramId $programId;
    private \DateTimeImmutable $publishedAt;
    private \DateTimeImmutable $occurredOn;
    
    public function __construct(
        ProgramId $programId,
        \DateTimeImmutable $publishedAt
    ) {
        $this->programId = $programId;
        $this->publishedAt = $publishedAt;
        $this->occurredOn = new \DateTimeImmutable();
    }
    
    public function getAggregateId(): string
    {
        return $this->programId->getValue();
    }
    
    public function occurredOn(): \DateTimeImmutable
    {
        return $this->occurredOn;
    }
    
    public function getProgramId(): ProgramId
    {
        return $this->programId;
    }
    
    public function getPublishedAt(): \DateTimeImmutable
    {
        return $this->publishedAt;
    }
    
    public function getEventName(): string
    {
        return 'program.published';
    }
} 