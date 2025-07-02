<?php

declare(strict_types=1);

namespace Program\Domain\ValueObjects;

final class TrackOrder implements \JsonSerializable
{
    private int $value;
    
    private function __construct(int $value)
    {
        if ($value <= 0) {
            throw new \InvalidArgumentException('Track order must be greater than zero');
        }
        
        $this->value = $value;
    }
    
    public static function fromInt(int $value): self
    {
        return new self($value);
    }
    
    public static function first(): self
    {
        return new self(1);
    }
    
    public function getValue(): int
    {
        return $this->value;
    }
    
    public function next(): self
    {
        return new self($this->value + 1);
    }
    
    public function isFirst(): bool
    {
        return $this->value === 1;
    }
    
    public function equals(self $other): bool
    {
        return $this->value === $other->value;
    }
    
    public function isLessThan(self $other): bool
    {
        return $this->value < $other->value;
    }
    
    public function isGreaterThan(self $other): bool
    {
        return $this->value > $other->value;
    }
    
    public function toString(): string
    {
        return (string) $this->value;
    }
    
    public function jsonSerialize(): int
    {
        return $this->value;
    }
    
    public function __toString(): string
    {
        return $this->toString();
    }
} 