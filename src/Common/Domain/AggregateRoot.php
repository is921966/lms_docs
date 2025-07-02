<?php

declare(strict_types=1);

namespace Common\Domain;

abstract class AggregateRoot
{
    private array $domainEvents = [];
    
    protected function recordThat(DomainEvent $event): void
    {
        $this->domainEvents[] = $event;
    }
    
    public function pullDomainEvents(): array
    {
        $events = $this->domainEvents;
        $this->domainEvents = [];
        
        return $events;
    }
} 