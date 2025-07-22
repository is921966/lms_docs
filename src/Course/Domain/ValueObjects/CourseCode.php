<?php

declare(strict_types=1);

namespace App\Course\Domain\ValueObjects;

use App\Common\Exceptions\InvalidArgumentException;

final class CourseCode
{
    private const MIN_LENGTH = 3;
    private const MAX_LENGTH = 20;
    private const VALID_PATTERN = '/^[A-Z0-9\-]+$/';
    
    private string $value;
    
    public function __construct(string $value)
    {
        $value = trim($value);
        
        if (empty($value)) {
            throw new InvalidArgumentException('CourseCode cannot be empty');
        }
        
        if (strlen($value) < self::MIN_LENGTH) {
            throw new InvalidArgumentException('CourseCode must be at least 3 characters long');
        }
        
        if (strlen($value) > self::MAX_LENGTH) {
            throw new InvalidArgumentException('CourseCode cannot exceed 20 characters');
        }
        
        $value = strtoupper($value);
        
        if (!preg_match(self::VALID_PATTERN, $value)) {
            throw new InvalidArgumentException('CourseCode can only contain letters, numbers, and hyphens');
        }
        
        $this->value = $value;
    }
    
    public function value(): string
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