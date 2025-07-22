<?php

namespace CompetencyService\Domain\ValueObjects;

use InvalidArgumentException;

final class CompetencyCode
{
    private string $value;
    
    public function __construct(string $value)
    {
        $this->validate($value);
        $this->value = strtoupper($value);
    }
    
    private function validate(string $value): void
    {
        if (empty($value)) {
            throw new InvalidArgumentException('Competency code cannot be empty');
        }
        
        if (strlen($value) > 20) {
            throw new InvalidArgumentException('Competency code cannot exceed 20 characters');
        }
        
        if (!preg_match('/^[A-Z0-9\-]+$/i', $value)) {
            throw new InvalidArgumentException('Competency code can only contain letters, numbers and hyphens');
        }
    }
    
    public function getValue(): string
    {
        return $this->value;
    }
    
    public function equals(CompetencyCode $other): bool
    {
        return $this->value === $other->value;
    }
    
    public function __toString(): string
    {
        return $this->value;
    }
} 