<?php

declare(strict_types=1);

namespace Notification\Domain\Repository;

use Notification\Domain\Notification;
use Notification\Domain\ValueObjects\NotificationId;
use Notification\Domain\ValueObjects\RecipientId;
use Notification\Domain\ValueObjects\NotificationStatus;
use Notification\Domain\ValueObjects\NotificationChannel;

interface NotificationRepositoryInterface
{
    public function save(Notification $notification): void;
    
    public function findById(NotificationId $id): ?Notification;
    
    /**
     * @return array<Notification>
     */
    public function findByRecipient(RecipientId $recipientId, int $limit = 50, int $offset = 0): array;
    
    /**
     * @return array<Notification>
     */
    public function findByRecipientAndStatus(RecipientId $recipientId, NotificationStatus $status): array;
    
    /**
     * @return array<Notification>
     */
    public function findByRecipientAndChannel(RecipientId $recipientId, NotificationChannel $channel): array;
    
    /**
     * @return array<Notification>
     */
    public function findPendingNotifications(int $limit = 100): array;
    
    public function countUnreadByRecipient(RecipientId $recipientId): int;
    
    public function markAllAsReadForRecipient(RecipientId $recipientId): void;
} 