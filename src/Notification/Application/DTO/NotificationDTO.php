<?php

declare(strict_types=1);

namespace Notification\Application\DTO;

use Notification\Domain\Notification;

class NotificationDTO
{
    public function __construct(
        public readonly string $id,
        public readonly string $recipientId,
        public readonly string $type,
        public readonly string $channel,
        public readonly string $subject,
        public readonly string $content,
        public readonly string $priority,
        public readonly string $status,
        public readonly array $metadata,
        public readonly string $createdAt,
        public readonly ?string $sentAt = null,
        public readonly ?string $deliveredAt = null,
        public readonly ?string $readAt = null,
        public readonly ?string $failedAt = null,
        public readonly ?string $failureReason = null
    ) {
    }
    
    public static function fromArray(array $data): self
    {
        return new self(
            id: $data['id'],
            recipientId: $data['recipientId'],
            type: $data['type'],
            channel: $data['channel'],
            subject: $data['subject'],
            content: $data['content'],
            priority: $data['priority'],
            status: $data['status'],
            metadata: $data['metadata'] ?? [],
            createdAt: $data['createdAt'],
            sentAt: $data['sentAt'] ?? null,
            deliveredAt: $data['deliveredAt'] ?? null,
            readAt: $data['readAt'] ?? null,
            failedAt: $data['failedAt'] ?? null,
            failureReason: $data['failureReason'] ?? null
        );
    }
    
    public static function fromEntity(Notification $notification): self
    {
        return new self(
            id: $notification->getId()->getValue(),
            recipientId: $notification->getRecipientId()->getValue(),
            type: $notification->getType()->getValue(),
            channel: $notification->getChannel()->getValue(),
            subject: $notification->getSubject(),
            content: $notification->getContent(),
            priority: $notification->getPriority()->getValue(),
            status: $notification->getStatus()->getValue(),
            metadata: $notification->getMetadata(),
            createdAt: $notification->getCreatedAt()->format('c'),
            sentAt: $notification->getSentAt()?->format('c'),
            deliveredAt: $notification->getDeliveredAt()?->format('c'),
            readAt: $notification->getReadAt()?->format('c'),
            failedAt: $notification->getFailedAt()?->format('c'),
            failureReason: $notification->getFailureReason()
        );
    }
    
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'recipientId' => $this->recipientId,
            'type' => $this->type,
            'channel' => $this->channel,
            'subject' => $this->subject,
            'content' => $this->content,
            'priority' => $this->priority,
            'status' => $this->status,
            'metadata' => $this->metadata,
            'createdAt' => $this->createdAt,
            'sentAt' => $this->sentAt,
            'deliveredAt' => $this->deliveredAt,
            'readAt' => $this->readAt,
            'failedAt' => $this->failedAt,
            'failureReason' => $this->failureReason,
        ];
    }
} 