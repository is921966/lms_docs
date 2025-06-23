<?php

declare(strict_types=1);

namespace App\Position\Domain\ValueObjects;

final class Department
{
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
        $value = trim($value);
        
        if (empty($value)) {
            throw new \InvalidArgumentException('Department name cannot be empty');
        }
        
        if (strlen($value) < 2) {
            throw new \InvalidArgumentException('Department name must be at least 2 characters long');
        }
        
        if (strlen($value) > 100) {
            throw new \InvalidArgumentException('Department name cannot exceed 100 characters');
        }
        
        $this->value = $value;
    }
    
    public function getValue(): string
    {
        return $this->value;
    }
    
    public function equals(Department $other): bool
    {
        return $this->value === $other->value;
    }
    
    public function __toString(): string
    {
        return $this->value;
    }
} 