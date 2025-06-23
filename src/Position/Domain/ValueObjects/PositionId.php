<?php

declare(strict_types=1);

namespace App\Position\Domain\ValueObjects;

use Ramsey\Uuid\Uuid;
use Ramsey\Uuid\UuidInterface;

final class PositionId
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
    
    public function getValue(): string
    {
        return $this->value->toString();
    }
    
    public function equals(PositionId $other): bool
    {
        return $this->value->equals($other->value);
    }
    
    public function __toString(): string
    {
        return $this->getValue();
    }
} 