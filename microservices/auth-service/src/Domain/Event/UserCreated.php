<?php

namespace App\Domain\Event;

use App\Domain\ValueObject\UserId;
use App\Domain\ValueObject\Email;

final class UserCreated
{
    private UserId $userId;
    private Email $email;
    private \DateTimeImmutable $occurredAt;
    
    public function __construct(UserId $userId, Email $email)
    {
        $this->userId = $userId;
        $this->email = $email;
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
    
    public function getOccurredAt(): \DateTimeImmutable
    {
        return $this->occurredAt;
    }
} 