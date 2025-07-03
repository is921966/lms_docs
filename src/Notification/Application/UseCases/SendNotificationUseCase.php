<?php

declare(strict_types=1);

namespace Notification\Application\UseCases;

use Notification\Application\DTO\NotificationDTO;
use Notification\Application\Services\NotificationDispatcher;
use Notification\Domain\Repository\NotificationRepositoryInterface;
use Notification\Domain\Notification;
use Notification\Domain\ValueObjects\NotificationId;
use Notification\Domain\ValueObjects\NotificationType;
use Notification\Domain\ValueObjects\NotificationChannel;
use Notification\Domain\ValueObjects\NotificationPriority;
use Notification\Domain\ValueObjects\RecipientId;

class SendNotificationUseCase
{
    public function __construct(
        private NotificationRepositoryInterface $repository,
        private NotificationDispatcher $dispatcher
    ) {
    }
    
    public function execute(SendNotificationRequest $request): NotificationDTO
    {
        $notification = Notification::create(
            NotificationId::generate(),
            RecipientId::fromString($request->recipientId),
            NotificationType::fromString($request->type),
            NotificationChannel::fromString($request->channel),
            $request->subject,
            $request->content,
            NotificationPriority::fromString($request->priority),
            $request->metadata
        );
        
        $this->repository->save($notification);
        
        try {
            $this->dispatcher->dispatch($notification);
        } catch (\RuntimeException $e) {
            // Log error but don't fail the use case
            // The notification is saved and can be retried later
        }
        
        return NotificationDTO::fromEntity($notification);
    }
} 