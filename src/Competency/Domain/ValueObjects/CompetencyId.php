<?php

declare(strict_types=1);

namespace App\Competency\Domain\ValueObjects;

use Ramsey\Uuid\Uuid;
use Ramsey\Uuid\UuidInterface;

/**
 * Competency identifier value object
 */
final class CompetencyId
{
    private UuidInterface $uuid;
    
    public function __construct(string $uuid)
    {
        if (!Uuid::isValid($uuid)) {
            throw new \InvalidArgumentException('Invalid UUID format');
        }
        
        $this->uuid = Uuid::fromString($uuid);
    }
    
    /**
     * Generate new CompetencyId
     */
    public static function generate(): self
    {
        return new self(Uuid::uuid4()->toString());
    }
    
    public static function fromString(string $id): self
    {
        return new self($id);
    }
    
    /**
     * Get string value
     */
    public function getValue(): string
    {
        return $this->uuid->toString();
    }
    
    /**
     * Get string representation (alias for getValue)
     */
    public function toString(): string
    {
        return $this->getValue();
    }
    
    /**
     * Compare with another CompetencyId
     */
    public function equals(self $other): bool
    {
        return $this->uuid->equals($other->uuid);
    }
    
    /**
     * String representation
     */
    public function __toString(): string
    {
        return $this->getValue();
    }
} 