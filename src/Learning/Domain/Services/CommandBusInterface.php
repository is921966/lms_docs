<?php

declare(strict_types=1);

namespace Learning\Domain\Services;

interface CommandBusInterface
{
    /**
     * @param object $command
     * @return mixed The handler return value
     */
    public function handle(object $command): mixed;
} 