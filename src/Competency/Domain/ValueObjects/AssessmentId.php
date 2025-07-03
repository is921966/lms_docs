<?php

declare(strict_types=1);

namespace Competency\Domain\ValueObjects;

final class AssessmentId
{
    private string $value;
    
    public function __construct(string $value)
    {
        if (empty($value)) {
            throw new \InvalidArgumentException('AssessmentId cannot be empty');
        }
        
        $this->value = $value;
    }
    
    public static function generate(): self
    {
        return new self(bin2hex(random_bytes(16)));
    }
    
    public static function fromString(string $value): self
    {
        return new self($value);
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
}
