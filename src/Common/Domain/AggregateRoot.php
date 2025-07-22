<?php

declare(strict_types=1);

namespace App\Common\Domain;

abstract class AggregateRoot
{
    private array $domainEvents = [];
    
    protected function recordEvent(DomainEvent $event): void
    {
        $this->domainEvents[] = $event;
    }
    
    public function pullDomainEvents(): array
    {
        $events = $this->domainEvents;
        $this->domainEvents = [];
        return $events;
    }
    
    public function hasDomainEvents(): bool
    {
        return count($this->domainEvents) > 0;
    }
} 