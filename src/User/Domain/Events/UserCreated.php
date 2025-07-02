<?php

declare(strict_types=1);

namespace User\Domain\Events;

use User\Domain\ValueObjects\Email;
use User\Domain\ValueObjects\UserId;

/**
 * Domain event: User created
 */
final class UserCreated
{
    private UserId $userId;
    private Email $email;
    private string $firstName;
    private string $lastName;
    private \DateTimeImmutable $occurredAt;
    
    public function __construct(
        UserId $userId,
        Email $email,
        string $firstName,
        string $lastName
    ) {
        $this->userId = $userId;
        $this->email = $email;
        $this->firstName = $firstName;
        $this->lastName = $lastName;
        $this->occurredAt = new \DateTimeImmutable();
    }
    
    public function getUserId(): UserId
    {
        return $this->userId;
    }
    
    public function getEmail(): Email
    {
        return $this->email;
    }
    
    public function getFirstName(): string
    {
        return $this->firstName;
    }
    
    public function getLastName(): string
    {
        return $this->lastName;
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
        return 'user.created';
    }
    
    /**
     * Convert to array for serialization
     */
    public function toArray(): array
    {
        return [
            'event' => $this->getEventName(),
            'user_id' => $this->userId->getValue(),
            'email' => $this->email->getValue(),
            'first_name' => $this->firstName,
            'last_name' => $this->lastName,
            'occurred_at' => $this->occurredAt->format('Y-m-d H:i:s'),
        ];
    }
} 