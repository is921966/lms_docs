<?php

declare(strict_types=1);

namespace Notification\Domain\ValueObjects;

class NotificationStatus
{
    private const PENDING = 'pending';
    private const SENT = 'sent';
    private const DELIVERED = 'delivered';
    private const FAILED = 'failed';
    private const READ = 'read';
    
    private const VALID_STATUSES = [
        self::PENDING,
        self::SENT,
        self::DELIVERED,
        self::FAILED,
        self::READ,
    ];
    
    private const FINAL_STATUSES = [
        self::FAILED,
        self::READ,
    ];
    
    private const ALLOWED_TRANSITIONS = [
        self::PENDING => [self::SENT, self::FAILED],
        self::SENT => [self::DELIVERED, self::FAILED],
        self::DELIVERED => [self::READ],
        self::FAILED => [],
        self::READ => [],
    ];
    
    private string $value;
    
    private function __construct(string $value)
    {
        $this->value = $value;
    }
    
    public static function fromString(string $value): self
    {
        if (empty($value)) {
            throw new \InvalidArgumentException('Notification status cannot be empty');
        }
        
        if (!in_array($value, self::VALID_STATUSES, true)) {
            throw new \InvalidArgumentException('Invalid notification status');
        }
        
        return new self($value);
    }
    
    public static function pending(): self
    {
        return new self(self::PENDING);
    }
    
    public static function sent(): self
    {
        return new self(self::SENT);
    }
    
    public static function delivered(): self
    {
        return new self(self::DELIVERED);
    }
    
    public static function failed(): self
    {
        return new self(self::FAILED);
    }
    
    public static function read(): self
    {
        return new self(self::READ);
    }
    
    public function getValue(): string
    {
        return $this->value;
    }
    
    public function isFinal(): bool
    {
        return in_array($this->value, self::FINAL_STATUSES, true);
    }
    
    public function canTransitionTo(self $newStatus): bool
    {
        $allowedTransitions = self::ALLOWED_TRANSITIONS[$this->value] ?? [];
        return in_array($newStatus->getValue(), $allowedTransitions, true);
    }
    
    public function equals(self $other): bool
    {
        return $this->value === $other->value;
    }
    
    public function __toString(): string
    {
        return $this->value;
    }
} 