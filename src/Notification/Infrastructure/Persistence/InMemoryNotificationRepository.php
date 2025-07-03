<?php

declare(strict_types=1);

namespace Notification\Infrastructure\Persistence;

use Notification\Domain\Repository\NotificationRepositoryInterface;
use Notification\Domain\Notification;
use Notification\Domain\ValueObjects\NotificationId;
use Notification\Domain\ValueObjects\RecipientId;
use Notification\Domain\ValueObjects\NotificationStatus;
use Notification\Domain\ValueObjects\NotificationChannel;

class InMemoryNotificationRepository implements NotificationRepositoryInterface
{
    /** @var array<string, Notification> */
    private array $notifications = [];
    
    public function save(Notification $notification): void
    {
        $this->notifications[$notification->getId()->getValue()] = $notification;
    }
    
    public function findById(NotificationId $id): ?Notification
    {
        return $this->notifications[$id->getValue()] ?? null;
    }
    
    public function findByRecipient(RecipientId $recipientId, int $limit = 50, int $offset = 0): array
    {
        $filtered = array_filter(
            $this->notifications,
            fn(Notification $n) => $n->getRecipientId()->equals($recipientId)
        );
        
        // Sort by creation date descending
        uasort($filtered, function (Notification $a, Notification $b) {
            return $b->getCreatedAt() <=> $a->getCreatedAt();
        });
        
        return array_values(array_slice($filtered, $offset, $limit));
    }
    
    public function findByRecipientAndStatus(RecipientId $recipientId, NotificationStatus $status): array
    {
        $filtered = array_filter(
            $this->notifications,
            fn(Notification $n) => $n->getRecipientId()->equals($recipientId) 
                && $n->getStatus()->equals($status)
        );
        
        return array_values($filtered);
    }
    
    public function findByRecipientAndChannel(RecipientId $recipientId, NotificationChannel $channel): array
    {
        $filtered = array_filter(
            $this->notifications,
            fn(Notification $n) => $n->getRecipientId()->equals($recipientId) 
                && $n->getChannel()->equals($channel)
        );
        
        return array_values($filtered);
    }
    
    public function findPendingNotifications(int $limit = 100): array
    {
        $pending = array_filter(
            $this->notifications,
            fn(Notification $n) => $n->getStatus()->equals(NotificationStatus::pending())
        );
        
        // Sort by priority (high first) and then by creation date
        uasort($pending, function (Notification $a, Notification $b) {
            $priorityCompare = $b->getPriority()->getNumericValue() <=> $a->getPriority()->getNumericValue();
            if ($priorityCompare !== 0) {
                return $priorityCompare;
            }
            return $a->getCreatedAt() <=> $b->getCreatedAt();
        });
        
        return array_values(array_slice($pending, 0, $limit));
    }
    
    public function countUnreadByRecipient(RecipientId $recipientId): int
    {
        $unread = array_filter(
            $this->notifications,
            fn(Notification $n) => $n->getRecipientId()->equals($recipientId) 
                && !$n->getStatus()->equals(NotificationStatus::read())
        );
        
        return count($unread);
    }
    
    public function markAllAsReadForRecipient(RecipientId $recipientId): void
    {
        foreach ($this->notifications as $notification) {
            if ($notification->getRecipientId()->equals($recipientId) 
                && $notification->getStatus()->equals(NotificationStatus::delivered())) {
                $notification->markAsRead();
            }
        }
    }
} 