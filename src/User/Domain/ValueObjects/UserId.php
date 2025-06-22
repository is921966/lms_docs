<?php

declare(strict_types=1);

namespace App\User\Domain\ValueObjects;

use Ramsey\Uuid\Uuid;
use Ramsey\Uuid\UuidInterface;

/**
 * User ID value object
 */
final class UserId implements \Stringable, \JsonSerializable
{
    private UuidInterface $uuid;
    
    private function __construct(UuidInterface $uuid)
    {
        $this->uuid = $uuid;
    }
    
    /**
     * Generate new user ID
     */
    public static function generate(): self
    {
        return new self(Uuid::uuid4());
    }
    
    /**
     * Create from string
     */
    public static function fromString(string $id): self
    {
        // Basic format validation
        if (empty($id)) {
            throw new \InvalidArgumentException('Invalid UUID format: empty string');
        }
        
        // Check for standard UUID format with hyphens
        if (!preg_match('/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i', $id)) {
            throw new \InvalidArgumentException(sprintf('Invalid UUID format: %s', $id));
        }
        
        try {
            $uuid = Uuid::fromString($id);
        } catch (\InvalidArgumentException $e) {
            throw new \InvalidArgumentException(
                sprintf('Invalid UUID format: %s', $id),
                0,
                $e
            );
        }
        
        return new self($uuid);
    }
    
    /**
     * Create from integer (for legacy systems)
     */
    public static function fromInt(int $id): self
    {
        if ($id <= 0) {
            throw new \InvalidArgumentException('User ID must be positive integer');
        }
        
        // Create deterministic UUID from integer
        $namespace = Uuid::fromString('6ba7b810-9dad-11d1-80b4-00c04fd430c8');
        $uuid = Uuid::uuid5($namespace, (string) $id);
        
        return new self($uuid);
    }
    
    /**
     * Create from legacy ID (alias for fromInt)
     */
    public static function fromLegacyId(int $id): self
    {
        return self::fromInt($id);
    }
    
    /**
     * Create nil/empty UUID
     */
    public static function nil(): self
    {
        return new self(Uuid::fromString(Uuid::NIL));
    }
    
    /**
     * Create from bytes
     */
    public static function fromBytes(string $bytes): self
    {
        try {
            $uuid = Uuid::fromBytes($bytes);
        } catch (\InvalidArgumentException $e) {
            throw new \InvalidArgumentException(
                'Invalid UUID bytes',
                0,
                $e
            );
        }
        
        return new self($uuid);
    }
    
    /**
     * Create deterministic UUID from string
     */
    public static function fromDeterministic(string $name, ?UuidInterface $namespace = null): self
    {
        $namespace = $namespace ?? Uuid::fromString('6ba7b810-9dad-11d1-80b4-00c04fd430c8');
        $uuid = Uuid::uuid5($namespace, $name);
        
        return new self($uuid);
    }
    
    /**
     * Get string representation
     */
    public function getValue(): string
    {
        return $this->uuid->toString();
    }
    
    /**
     * Get UUID object
     */
    public function getUuid(): UuidInterface
    {
        return $this->uuid;
    }
    
    /**
     * Compare with another user ID
     */
    public function equals(UserId $other): bool
    {
        return $this->uuid->equals($other->uuid);
    }
    
    /**
     * Check if ID is nil/empty
     */
    public function isNil(): bool
    {
        return $this->uuid->toString() === Uuid::NIL;
    }
    
    /**
     * Get bytes representation
     */
    public function getBytes(): string
    {
        return $this->uuid->getBytes();
    }
    
    /**
     * String representation
     */
    public function __toString(): string
    {
        return $this->uuid->toString();
    }
    
    /**
     * Get UUID version
     */
    public function getVersion(): int
    {
        return $this->uuid->getFields()->getVersion();
    }
    
    /**
     * JSON serialization
     */
    public function jsonSerialize(): mixed
    {
        return $this->uuid->toString();
    }
    
    /**
     * Get legacy ID if created from integer
     * Note: This is a reverse operation and may not return the original ID
     */
    public function getLegacyId(): int
    {
        // Extract the integer from the UUID string
        // This is a simplified version - in real implementation
        // you might want to store the original ID
        return (int) hexdec(substr($this->uuid->toString(), 0, 8));
    }
} 