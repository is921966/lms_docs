<?php

declare(strict_types=1);

namespace Program\Domain\Events;

use Common\Domain\DomainEvent;
use Program\Domain\ValueObjects\ProgramId;
use Program\Domain\ValueObjects\ProgramCode;

final class ProgramCreated implements DomainEvent
{
    private ProgramId $programId;
    private ProgramCode $code;
    private string $title;
    private string $description;
    private \DateTimeImmutable $occurredOn;
    
    public function __construct(
        ProgramId $programId,
        ProgramCode $code,
        string $title,
        string $description
    ) {
        $this->programId = $programId;
        $this->code = $code;
        $this->title = $title;
        $this->description = $description;
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
    
    public function getCode(): ProgramCode
    {
        return $this->code;
    }
    
    public function getTitle(): string
    {
        return $this->title;
    }
    
    public function getDescription(): string
    {
        return $this->description;
    }
    
    public function getEventName(): string
    {
        return 'program.created';
    }
} 