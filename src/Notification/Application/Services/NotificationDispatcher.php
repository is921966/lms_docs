<?php

declare(strict_types=1);

namespace Notification\Application\Services;

use Notification\Domain\Notification;

interface NotificationDispatcher
{
    /**
     * Dispatch notification to appropriate channel
     * 
     * @throws \RuntimeException if dispatch fails
     */
    public function dispatch(Notification $notification): void;
} 