<?php

namespace Auth\Domain\ValueObjects;

use Ramsey\Uuid\Uuid;
use Ramsey\Uuid\UuidInterface;

final class RoleId
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

    public static function fromString(string $id): self
    {
        return new self(Uuid::fromString($id));
    }

    public function getValue(): string
    {
        return $this->uuid->toString();
    }

    public function equals(RoleId $other): bool
    {
        return $this->uuid->equals($other->uuid);
    }

    public function __toString(): string
    {
        return $this->uuid->toString();
    }
} 