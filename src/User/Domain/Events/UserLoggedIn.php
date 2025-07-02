<?php

declare(strict_types=1);

namespace User\Domain\Events;

use User\Domain\ValueObjects\UserId;

/**
 * Domain event: User logged in
 */
final class UserLoggedIn
{
    private UserId $userId;
    private string $ipAddress;
    private ?string $userAgent;
    private \DateTimeImmutable $occurredAt;
    
    public function __construct(
        UserId $userId,
        string $ipAddress,
        ?string $userAgent = null
    ) {
        $this->userId = $userId;
        $this->ipAddress = $ipAddress;
        $this->userAgent = $userAgent;
        $this->occurredAt = new \DateTimeImmutable();
    }
    
    public function getUserId(): UserId
    {
        return $this->userId;
    }
    
    public function getIpAddress(): string
    {
        return $this->ipAddress;
    }
    
    public function getUserAgent(): ?string
    {
        return $this->userAgent;
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
        return 'user.logged_in';
    }
    
    /**
     * Convert to array for serialization
     */
    public function toArray(): array
    {
        return [
            'event' => $this->getEventName(),
            'user_id' => $this->userId->getValue(),
            'ip_address' => $this->ipAddress,
            'user_agent' => $this->userAgent,
            'occurred_at' => $this->occurredAt->format('Y-m-d H:i:s'),
        ];
    }
} 