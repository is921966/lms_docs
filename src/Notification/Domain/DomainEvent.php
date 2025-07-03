<?php

declare(strict_types=1);

namespace Notification\Domain;

interface DomainEvent
{
    public function getEventName(): string;
    
    public function getOccurredAt(): \DateTimeImmutable;
    
    public function getAggregateId(): string;
} 