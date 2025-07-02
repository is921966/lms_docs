<?php

declare(strict_types=1);

namespace Program\Domain\ValueObjects;

use Ramsey\Uuid\Uuid;
use Ramsey\Uuid\UuidInterface;

final class TrackId implements \JsonSerializable
{
    private UuidInterface $uuid;
    
    private function __construct(UuidInterface $uuid)
    {
        $this->uuid = $uuid;
    }
    
    public static function generate(): self
    {
        return new self(Uuid::uuid4());
    }
    
    public static function fromString(string $uuid): self
    {
        try {
            return new self(Uuid::fromString($uuid));
        } catch (\InvalidArgumentException $e) {
            throw new \InvalidArgumentException('Invalid TrackId format: ' . $e->getMessage());
        }
    }
    
    public function getValue(): string
    {
        return $this->uuid->toString();
    }
    
    public function toString(): string
    {
        return $this->getValue();
    }
    
    public function equals(self $other): bool
    {
        return $this->uuid->equals($other->uuid);
    }
    
    public function jsonSerialize(): string
    {
        return $this->getValue();
    }
    
    public function __toString(): string
    {
        return $this->getValue();
    }
} 