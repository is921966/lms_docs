<?php

declare(strict_types=1);

namespace Notification\Domain;

use Notification\Domain\Events\NotificationCreated;
use Notification\Domain\Events\NotificationSent;
use Notification\Domain\Events\NotificationFailed;
use Notification\Domain\ValueObjects\NotificationId;
use Notification\Domain\ValueObjects\NotificationType;
use Notification\Domain\ValueObjects\NotificationChannel;
use Notification\Domain\ValueObjects\NotificationPriority;
use Notification\Domain\ValueObjects\NotificationStatus;
use Notification\Domain\ValueObjects\RecipientId;

class Notification extends AggregateRoot
{
    private NotificationId $id;
    private RecipientId $recipientId;
    private NotificationType $type;
    private NotificationChannel $channel;
    private string $subject;
    private string $content;
    private NotificationPriority $priority;
    private NotificationStatus $status;
    private array $metadata;
    private \DateTimeImmutable $createdAt;
    private ?\DateTimeImmutable $sentAt = null;
    private ?\DateTimeImmutable $deliveredAt = null;
    private ?\DateTimeImmutable $readAt = null;
    private ?\DateTimeImmutable $failedAt = null;
    private ?string $failureReason = null;
    
    private function __construct(
        NotificationId $id,
        RecipientId $recipientId,
        NotificationType $type,
        NotificationChannel $channel,
        string $subject,
        string $content,
        NotificationPriority $priority,
        array $metadata = []
    ) {
        $this->id = $id;
        $this->recipientId = $recipientId;
        $this->type = $type;
        $this->channel = $channel;
        $this->subject = $subject;
        $this->content = $content;
        $this->priority = $priority;
        $this->status = NotificationStatus::pending();
        $this->metadata = $metadata;
        $this->createdAt = new \DateTimeImmutable();
    }
    
    public static function create(
        NotificationId $id,
        RecipientId $recipientId,
        NotificationType $type,
        NotificationChannel $channel,
        string $subject,
        string $content,
        NotificationPriority $priority,
        array $metadata = []
    ): self {
        $notification = new self(
            $id,
            $recipientId,
            $type,
            $channel,
            $subject,
            $content,
            $priority,
            $metadata
        );
        
        $notification->recordEvent(new NotificationCreated(
            $id,
            $recipientId,
            $type,
            $channel,
            $priority
        ));
        
        return $notification;
    }
    
    public function markAsSent(): void
    {
        $this->transitionTo(NotificationStatus::sent());
        $this->sentAt = new \DateTimeImmutable();
        
        $this->recordEvent(new NotificationSent($this->id));
    }
    
    public function markAsDelivered(): void
    {
        $this->transitionTo(NotificationStatus::delivered());
        $this->deliveredAt = new \DateTimeImmutable();
    }
    
    public function markAsFailed(string $reason): void
    {
        $this->transitionTo(NotificationStatus::failed());
        $this->failedAt = new \DateTimeImmutable();
        $this->failureReason = $reason;
        
        $this->recordEvent(new NotificationFailed($this->id, $reason));
    }
    
    public function markAsRead(): void
    {
        $this->transitionTo(NotificationStatus::read());
        $this->readAt = new \DateTimeImmutable();
    }
    
    private function transitionTo(NotificationStatus $newStatus): void
    {
        if ($this->status->isFinal()) {
            throw new \DomainException('Cannot change status from final state');
        }
        
        if (!$this->status->canTransitionTo($newStatus)) {
            throw new \DomainException('Invalid status transition');
        }
        
        $this->status = $newStatus;
    }
    
    public function isHighPriority(): bool
    {
        return $this->priority->equals(NotificationPriority::high());
    }
    
    // Getters
    public function getId(): NotificationId
    {
        return $this->id;
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
    
    public function getSubject(): string
    {
        return $this->subject;
    }
    
    public function getContent(): string
    {
        return $this->content;
    }
    
    public function getPriority(): NotificationPriority
    {
        return $this->priority;
    }
    
    public function getStatus(): NotificationStatus
    {
        return $this->status;
    }
    
    public function getMetadata(): array
    {
        return $this->metadata;
    }
    
    public function getCreatedAt(): \DateTimeImmutable
    {
        return $this->createdAt;
    }
    
    public function getSentAt(): ?\DateTimeImmutable
    {
        return $this->sentAt;
    }
    
    public function getDeliveredAt(): ?\DateTimeImmutable
    {
        return $this->deliveredAt;
    }
    
    public function getReadAt(): ?\DateTimeImmutable
    {
        return $this->readAt;
    }
    
    public function getFailedAt(): ?\DateTimeImmutable
    {
        return $this->failedAt;
    }
    
    public function getFailureReason(): ?string
    {
        return $this->failureReason;
    }
} 