<?php

declare(strict_types=1);

namespace Notification\Domain\Events;

use Notification\Domain\DomainEvent;
use Notification\Domain\ValueObjects\NotificationId;

class NotificationFailed implements DomainEvent
{
    private NotificationId $notificationId;
    private string $reason;
    private \DateTimeImmutable $occurredAt;
    
    public function __construct(NotificationId $notificationId, string $reason)
    {
        $this->notificationId = $notificationId;
        $this->reason = $reason;
        $this->occurredAt = new \DateTimeImmutable();
    }
    
    public function getEventName(): string
    {
        return 'notification.failed';
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
    
    public function getReason(): string
    {
        return $this->reason;
    }
} 