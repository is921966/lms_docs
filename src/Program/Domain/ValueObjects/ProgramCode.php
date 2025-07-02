<?php

declare(strict_types=1);

namespace Program\Domain\ValueObjects;

final class ProgramCode implements \JsonSerializable
{
    private const PATTERN = '/^[A-Z]{4}-\d{3}$/';
    
    private string $value;
    
    private function __construct(string $value)
    {
        $this->value = $value;
    }
    
    public static function fromString(string $value): self
    {
        if (empty($value)) {
            throw new \InvalidArgumentException('Program code cannot be empty');
        }
        
        if (!preg_match(self::PATTERN, $value)) {
            throw new \InvalidArgumentException('Invalid program code format. Expected format: XXXX-NNN');
        }
        
        return new self($value);
    }
    
    public function getValue(): string
    {
        return $this->value;
    }
    
    public function toString(): string
    {
        return $this->value;
    }
    
    public function equals(self $other): bool
    {
        return $this->value === $other->value;
    }
    
    public function jsonSerialize(): string
    {
        return $this->value;
    }
    
    public function __toString(): string
    {
        return $this->value;
    }
} 