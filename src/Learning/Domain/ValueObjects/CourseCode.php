<?php

declare(strict_types=1);

namespace Learning\Domain\ValueObjects;

use InvalidArgumentException;

final class CourseCode
{
    private function __construct(
        private readonly string $value
    ) {
        $this->validate($value);
    }
    
    public static function fromString(string $value): self
    {
        // Normalize to uppercase
        $normalized = strtoupper(trim($value));
        return new self($normalized);
    }
    
    public static function generate(string $prefix = 'CRS'): self
    {
        $prefix = strtoupper(trim($prefix));
        if (empty($prefix)) {
            $prefix = 'CRS';
        }
        
        $number = random_int(100, 999999);
        $code = sprintf('%s-%03d', $prefix, $number);
        
        return new self($code);
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
    
    private function validate(string $value): void
    {
        if (empty($value)) {
            throw new InvalidArgumentException('Course code cannot be empty');
        }
        
        if (strlen($value) > 20) {
            throw new InvalidArgumentException('Course code cannot exceed 20 characters');
        }
        
        if (!preg_match('/^[A-Z]+-\d+$/', $value)) {
            throw new InvalidArgumentException('Course code must be in format: PREFIX-NUMBER (e.g., PHP-101)');
        }
    }
} 