<?php

declare(strict_types=1);

namespace Notification\Domain\Events;

use Notification\Domain\DomainEvent;
use Notification\Domain\ValueObjects\NotificationId;
use Notification\Domain\ValueObjects\RecipientId;
use Notification\Domain\ValueObjects\NotificationType;
use Notification\Domain\ValueObjects\NotificationChannel;
use Notification\Domain\ValueObjects\NotificationPriority;

class NotificationCreated implements DomainEvent
{
    private NotificationId $notificationId;
    private RecipientId $recipientId;
    private NotificationType $type;
    private NotificationChannel $channel;
    private NotificationPriority $priority;
    private \DateTimeImmutable $occurredAt;
    
    public function __construct(
        NotificationId $notificationId,
        RecipientId $recipientId,
        NotificationType $type,
        NotificationChannel $channel,
        NotificationPriority $priority
    ) {
        $this->notificationId = $notificationId;
        $this->recipientId = $recipientId;
        $this->type = $type;
        $this->channel = $channel;
        $this->priority = $priority;
        $this->occurredAt = new \DateTimeImmutable();
    }
    
    public function getEventName(): string
    {
        return 'notification.created';
    }
    
    public function getOccurredAt(): \DateTimeImmutable
    {
        return $this->occurredAt;
    }
    
    public function getAggregateId(): string
    {
        return $this->notificationId->getValue();
    }
    
    public function getNotificationId(): NotificationId
    {
        return $this->notificationId;
    }
    
    public function getRecipientId(): RecipientId
    {
        return $this->recipientId;
    }
    
    public function getType(): NotificationType
    {
        return $this->type;
    }
    
    public function getChannel(): NotificationChannel
    {
        return $this->channel;
    }
    
    public function getPriority(): NotificationPriority
    {
        return $this->priority;
    }
} 