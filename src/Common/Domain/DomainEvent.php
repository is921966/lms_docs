<?php

declare(strict_types=1);

namespace App\Common\Domain;

interface DomainEvent
{
    public function occurredOn(): \DateTimeImmutable;
    
    public function aggregateId(): string;
} 