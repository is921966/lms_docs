<?php

declare(strict_types=1);

namespace App\User\Domain\Events;

use App\User\Domain\ValueObjects\UserId;

/**
 * Domain event: User updated
 */
final class UserUpdated
{
    private UserId $userId;
    private array $changedFields;
    private \DateTimeImmutable $occurredAt;
    
    public function __construct(UserId $userId, array $changedFields = [])
    {
        $this->userId = $userId;
        $this->changedFields = $changedFields;
        $this->occurredAt = new \DateTimeImmutable();
    }
    
    public function getUserId(): UserId
    {
        return $this->userId;
    }
    
    public function getChangedFields(): array
    {
        return $this->changedFields;
    }
    
    public function getOccurredAt(): \DateTimeImmutable
    {
        return $this->occurredAt;
    }
    
    /**
     * Get event name
     */
    public function getEventName(): string
    {
        return 'user.updated';
    }
    
    /**
     * Convert to array for serialization
     */
    public function toArray(): array
    {
        return [
            'event' => $this->getEventName(),
            'user_id' => $this->userId->getValue(),
            'changed_fields' => $this->changedFields,
            'occurred_at' => $this->occurredAt->format('Y-m-d H:i:s'),
        ];
    }
} 