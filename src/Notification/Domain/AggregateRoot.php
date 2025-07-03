<?php

declare(strict_types=1);

namespace Notification\Domain;

abstract class AggregateRoot
{
    /** @var array<DomainEvent> */
    private array $events = [];
    
    protected function recordEvent(DomainEvent $event): void
    {
        $this->events[] = $event;
    }
    
    /**
     * @return array<DomainEvent>
     */
    public function pullEvents(): array
    {
        $events = $this->events;
        $this->events = [];
        return $events;
    }
    
    public function hasEvents(): bool
    {
        return count($this->events) > 0;
    }
} 