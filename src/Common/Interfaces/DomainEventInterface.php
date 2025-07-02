<?php

declare(strict_types=1);

namespace Common\Interfaces;

use DateTimeImmutable;

/**
 * Interface for all domain events in the system
 */
interface DomainEventInterface
{
    /**
     * Get the unique name of the event
     */
    public function getEventName(): string;
    
    /**
     * Get the ID of the aggregate that raised this event
     */
    public function getAggregateId(): string;
    
    /**
     * Get when the event occurred
     */
    public function getOccurredAt(): DateTimeImmutable;
    
    /**
     * Convert event to array for serialization
     */
    public function toArray(): array;
} 