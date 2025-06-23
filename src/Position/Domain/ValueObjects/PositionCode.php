<?php

declare(strict_types=1);

namespace App\Position\Domain\ValueObjects;

final class PositionCode
{
    private const PATTERN = '/^[A-Z]{2,5}-\d{3,5}$/';
    
    private string $value;
    
    private function __construct(string $value)
    {
        $this->setValue($value);
    }
    
    public static function fromString(string $value): self
    {
        return new self($value);
    }
    
    private function setValue(string $value): void
    {
        $value = trim(strtoupper($value));
        
        if (empty($value)) {
            throw new \InvalidArgumentException('Position code cannot be empty');
        }
        
        if (!preg_match(self::PATTERN, $value)) {
            throw new \InvalidArgumentException(
                'Position code must follow pattern: 2-5 uppercase letters, hyphen, 3-5 digits (e.g., DEV-001)'
            );
        }
        
        $this->value = $value;
    }
    
    public function getValue(): string
    {
        return $this->value;
    }
    
    public function equals(PositionCode $other): bool
    {
        return $this->value === $other->value;
    }
    
    public function __toString(): string
    {
        return $this->value;
    }
} 