<?php

declare(strict_types=1);

namespace Notification\Domain\ValueObjects;

use Ramsey\Uuid\Uuid;

class NotificationId
{
    private string $value;
    
    private function __construct(string $value)
    {
        $this->value = $value;
    }
    
    public static function fromString(string $value): self
    {
        if (empty($value)) {
            throw new \InvalidArgumentException('Notification ID cannot be empty');
        }
        
        if (!Uuid::isValid($value)) {
            throw new \InvalidArgumentException('Invalid notification ID format');
        }
        
        return new self($value);
    }
    
    public static function generate(): self
    {
        return new self(Uuid::uuid4()->toString());
    }
    
    public function getValue(): string
    {
        return $this->value;
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