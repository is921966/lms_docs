<?php

declare(strict_types=1);

namespace Notification\Domain\Events;

use Notification\Domain\DomainEvent;
use Notification\Domain\ValueObjects\NotificationId;

class NotificationSent implements DomainEvent
{
    private NotificationId $notificationId;
    private \DateTimeImmutable $occurredAt;
    
    public function __construct(NotificationId $notificationId)
    {
        $this->notificationId = $notificationId;
        $this->occurredAt = new \DateTimeImmutable();
    }
    
    public function getEventName(): string
    {
        return 'notification.sent';
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
} 