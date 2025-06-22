<?php

declare(strict_types=1);

namespace App\Common\Traits;

trait HasDomainEvents
{
    private array $domainEvents = [];
    
    protected function recordDomainEvent(object $event): void
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