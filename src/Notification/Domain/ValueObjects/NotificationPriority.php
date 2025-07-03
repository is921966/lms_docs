<?php

declare(strict_types=1);

namespace Notification\Domain\ValueObjects;

class NotificationPriority
{
    private const HIGH = 'high';
    private const MEDIUM = 'medium';
    private const LOW = 'low';
    
    private const VALID_PRIORITIES = [
        self::HIGH,
        self::MEDIUM,
        self::LOW,
    ];
    
    private const NUMERIC_VALUES = [
        self::HIGH => 3,
        self::MEDIUM => 2,
        self::LOW => 1,
    ];
    
    private string $value;
    
    private function __construct(string $value)
    {
        $this->value = $value;
    }
    
    public static function fromString(string $value): self
    {
        if (empty($value)) {
            throw new \InvalidArgumentException('Notification priority cannot be empty');
        }
        
        if (!in_array($value, self::VALID_PRIORITIES, true)) {
            throw new \InvalidArgumentException('Invalid notification priority');
        }
        
        return new self($value);
    }
    
    public static function high(): self
    {
        return new self(self::HIGH);
    }
    
    public static function medium(): self
    {
        return new self(self::MEDIUM);
    }
    
    public static function low(): self
    {
        return new self(self::LOW);
    }
    
    public function getValue(): string
    {
        return $this->value;
    }
    
    public function getNumericValue(): int
    {
        return self::NUMERIC_VALUES[$this->value];
    }
    
    public function isHigherThan(self $other): bool
    {
        return $this->getNumericValue() > $other->getNumericValue();
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