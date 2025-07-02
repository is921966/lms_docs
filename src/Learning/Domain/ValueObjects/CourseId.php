<?php

declare(strict_types=1);

namespace Learning\Domain\ValueObjects;

use InvalidArgumentException;
use Ramsey\Uuid\Uuid;

final class CourseId
{
    private function __construct(
        private readonly string $value
    ) {
        $this->validate($value);
    }
    
    public static function fromString(string $value): self
    {
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
    
    private function validate(string $value): void
    {
        if (empty($value)) {
            throw new InvalidArgumentException('Course ID cannot be empty');
        }
        
        if (!preg_match('/^[a-zA-Z0-9\-]+$/', $value)) {
            throw new InvalidArgumentException('Course ID can only contain letters, numbers, and hyphens');
        }
    }
} 