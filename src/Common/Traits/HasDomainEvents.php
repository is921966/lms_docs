<?php

declare(strict_types=1);

namespace Common\Traits;

use Common\Interfaces\DomainEventInterface;

trait HasDomainEvents
{
    /**
     * @var array<DomainEventInterface>
     */
    private array $domainEvents = [];
    
    /**
     * Record a domain event
     */
    protected function recordDomainEvent(DomainEventInterface $event): void
    {
        $this->domainEvents[] = $event;
    }
    
    // Alias для совместимости
    protected function addDomainEvent(object $event): void
    {
        $this->recordDomainEvent($event);
    }
    
    /**
     * Pull all domain events and clear the list
     * 
     * @return array<DomainEventInterface>
     */
    public function pullDomainEvents(): array
    {
        $events = $this->domainEvents;
        $this->domainEvents = [];
        
        return $events;
    }
    
    /**
     * Get domain events without clearing
     * 
     * @return array<DomainEventInterface>
     */
    public function getDomainEvents(): array
    {
        return $this->domainEvents;
    }
    
    /**
     * Check if there are any domain events
     */
    public function hasDomainEvents(): bool
    {
        return count($this->domainEvents) > 0;
    }
} 