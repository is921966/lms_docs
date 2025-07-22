<?php

namespace App\Domain\ValueObject;

use Symfony\Component\Uid\Uuid;

final class UserId
{
    private string $value;
    
    private function __construct(string $value)
    {
        if (!Uuid::isValid($value)) {
            throw new \InvalidArgumentException('Invalid user ID format');
        }
        
        $this->value = $value;
    }
    
    public static function generate(): self
    {
        return new self(Uuid::v4()->toString());
    }
    
    public static function fromString(string $value): self
    {
        return new self($value);
    }
    
    public function getValue(): string
    {
        return $this->value;
    }
    
    public function equals(UserId $other): bool
    {
        return $this->value === $other->value;
    }
    
    public function __toString(): string
    {
        return $this->value;
    }
} 