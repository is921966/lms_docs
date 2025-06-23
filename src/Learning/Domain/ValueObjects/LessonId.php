<?php

declare(strict_types=1);

namespace App\Learning\Domain\ValueObjects;

use Ramsey\Uuid\Uuid;
use Ramsey\Uuid\UuidInterface;

final class LessonId implements \JsonSerializable
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
            throw new \InvalidArgumentException('Invalid LessonId format: ' . $e->getMessage());
        }
    }
    
    public function toString(): string
    {
        return $this->uuid->toString();
    }
    
    public function equals(self $other): bool
    {
        return $this->uuid->equals($other->uuid);
    }
    
    public function jsonSerialize(): string
    {
        return $this->toString();
    }
    
    public function __toString(): string
    {
        return $this->toString();
    }
} 