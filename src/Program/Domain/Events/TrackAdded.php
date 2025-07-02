<?php

declare(strict_types=1);

namespace Program\Domain\Events;

use Common\Domain\DomainEvent;
use Program\Domain\ValueObjects\ProgramId;
use Program\Domain\ValueObjects\TrackId;
use Program\Domain\ValueObjects\TrackOrder;

final class TrackAdded implements DomainEvent
{
    private ProgramId $programId;
    private TrackId $trackId;
    private string $title;
    private TrackOrder $order;
    private \DateTimeImmutable $occurredOn;
    
    public function __construct(
        ProgramId $programId,
        TrackId $trackId,
        string $title,
        TrackOrder $order
    ) {
        $this->programId = $programId;
        $this->trackId = $trackId;
        $this->title = $title;
        $this->order = $order;
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
    
    public function getTrackId(): TrackId
    {
        return $this->trackId;
    }
    
    public function getTitle(): string
    {
        return $this->title;
    }
    
    public function getOrder(): TrackOrder
    {
        return $this->order;
    }
} 