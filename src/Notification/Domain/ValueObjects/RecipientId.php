<?php

declare(strict_types=1);

namespace Notification\Domain\ValueObjects;

use Ramsey\Uuid\Uuid;

class RecipientId
{
    private string $value;
    
    private function __construct(string $value)
    {
        $this->value = $value;
    }
    
    public static function fromString(string $value): self
    {
        if (empty($value)) {
            throw new \InvalidArgumentException('Recipient ID cannot be empty');
        }
        
        if (!Uuid::isValid($value)) {
            throw new \InvalidArgumentException('Invalid recipient ID format');
        }
        
        return new self($value);
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