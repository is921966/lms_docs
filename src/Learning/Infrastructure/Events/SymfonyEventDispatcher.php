<?php

declare(strict_types=1);

namespace Learning\Infrastructure\Events;

use Common\Interfaces\DomainEventInterface;
use Learning\Domain\Services\EventDispatcherInterface;
use Symfony\Component\EventDispatcher\EventDispatcherInterface as SymfonyEventDispatcherInterface;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;

final class SymfonyEventDispatcher implements EventDispatcherInterface
{
    public function __construct(
        private readonly SymfonyEventDispatcherInterface $eventDispatcher
    ) {
    }
    
    public function dispatch(DomainEventInterface $event): void
    {
        $this->eventDispatcher->dispatch($event, get_class($event));
    }
    
    public function addSubscriber(EventSubscriberInterface $subscriber): void
    {
        $this->eventDispatcher->addSubscriber($subscriber);
    }
} 