<?php

declare(strict_types=1);

namespace Learning\Domain\Services;

interface QueryBusInterface
{
    /**
     * @param object $query
     * @return mixed The query result
     */
    public function handle(object $query): mixed;
} 