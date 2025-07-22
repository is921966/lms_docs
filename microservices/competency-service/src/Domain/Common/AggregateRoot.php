<?php

namespace CompetencyService\Domain\Common;

abstract class AggregateRoot
{
    private array $domainEvents = [];
    
    protected function raiseDomainEvent(DomainEvent $event): void
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