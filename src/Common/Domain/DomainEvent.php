<?php

declare(strict_types=1);

namespace Common\Domain;

interface DomainEvent
{
    public function getAggregateId(): string;
    
    public function occurredOn(): \DateTimeImmutable;
} 