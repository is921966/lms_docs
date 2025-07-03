<?php

declare(strict_types=1);

namespace Notification\Infrastructure;

use Notification\Domain\Repository\NotificationRepositoryInterface;
use Notification\Domain\Notification;
use Notification\Infrastructure\Email\EmailNotificationSender;
use Notification\Application\Services\NotificationDispatcher;

class CompositeNotificationDispatcher implements NotificationDispatcher
{
    /** @var array<EmailNotificationSender> */
    private array $senders = [];
    
    public function __construct(
        private NotificationRepositoryInterface $repository
    ) {
    }
    
    public function addSender(EmailNotificationSender $sender): void
    {
        $this->senders[] = $sender;
    }
    
    public function dispatch(Notification $notification): void
    {
        $sender = $this->findSupportedSender($notification);
        
        if ($sender === null) {
            throw new \RuntimeException(sprintf(
                'No sender available for notification channel: %s',
                $notification->getChannel()->getValue()
            ));
        }
        
        try {
            $sender->send($notification);
            $notification->markAsSent();
        } catch (\RuntimeException $e) {
            $notification->markAsFailed($e->getMessage());
            $this->repository->save($notification);
            throw new \RuntimeException('Failed to dispatch notification: ' . $e->getMessage(), 0, $e);
        }
        
        $this->repository->save($notification);
    }
    
    private function findSupportedSender(Notification $notification): ?EmailNotificationSender
    {
        foreach ($this->senders as $sender) {
            if ($sender->supports($notification)) {
                return $sender;
            }
        }
        
        return null;
    }
} 