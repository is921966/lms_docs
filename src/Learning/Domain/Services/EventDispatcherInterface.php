<?php

declare(strict_types=1);

namespace Learning\Domain\Services;

use Common\Interfaces\DomainEventInterface;

interface EventDispatcherInterface
{
    public function dispatch(DomainEventInterface $event): void;
} 