<?php

namespace CompetencyService\Domain\ValueObjects;

use Ramsey\Uuid\Uuid;
use Ramsey\Uuid\UuidInterface;

final class AssessmentId
{
    private UuidInterface $value;
    
    private function __construct(UuidInterface $value)
    {
        $this->value = $value;
    }
    
    public static function generate(): self
    {
        return new self(Uuid::uuid4());
    }
    
    public static function fromString(string $value): self
    {
        return new self(Uuid::fromString($value));
    }
    
    public function toString(): string
    {
        return $this->value->toString();
    }
    
    public function equals(AssessmentId $other): bool
    {
        return $this->value->equals($other->value);
    }
    
    public function __toString(): string
    {
        return $this->toString();
    }
} 