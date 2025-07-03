<?php

declare(strict_types=1);

namespace Notification\Application\UseCases;

use Notification\Domain\Repository\NotificationRepositoryInterface;
use Notification\Domain\ValueObjects\NotificationId;

class MarkAsReadUseCase
{
    public function __construct(
        private NotificationRepositoryInterface $repository
    ) {
    }
    
    public function execute(string $notificationId): bool
    {
        $id = NotificationId::fromString($notificationId);
        
        $notification = $this->repository->findById($id);
        if ($notification === null) {
            return false;
        }
        
        $notification->markAsRead();
        $this->repository->save($notification);
        
        return true;
    }
} 