<?php

declare(strict_types=1);

namespace App\User\Domain\ValueObjects;

/**
 * Password value object
 */
final class Password implements \JsonSerializable
{
    private string $hashedValue;
    
    private function __construct(string $hashedValue)
    {
        $this->hashedValue = $hashedValue;
    }
    
    /**
     * Create from plain text password
     */
    public static function fromPlainText(string $plainPassword, array $policy = []): self
    {
        PasswordPolicy::validate($plainPassword, $policy);
        
        $hashedValue = password_hash($plainPassword, PASSWORD_ARGON2ID, [
            'memory_cost' => 65536,
            'time_cost' => 4,
            'threads' => 3,
        ]);
        
        return new self($hashedValue);
    }
    
    /**
     * Create from already hashed password
     */
    public static function fromHash(string $hashedValue): self
    {
        if (empty($hashedValue)) {
            throw new \InvalidArgumentException('Password hash cannot be empty');
        }
        
        return new self($hashedValue);
    }
    
    /**
     * Verify plain text password
     */
    public function verify(string $plainPassword): bool
    {
        return password_verify($plainPassword, $this->hashedValue);
    }
    
    /**
     * Check if password needs rehashing
     */
    public function needsRehash(): bool
    {
        return password_needs_rehash($this->hashedValue, PASSWORD_ARGON2ID, [
            'memory_cost' => 65536,
            'time_cost' => 4,
            'threads' => 3,
        ]);
    }
    
    /**
     * Get hashed value
     */
    public function getHashedValue(): string
    {
        return $this->hashedValue;
    }
    
    /**
     * Get hash (alias for getHashedValue)
     */
    public function getHash(): string
    {
        return $this->hashedValue;
    }
    
    /**
     * Compare with another password
     */
    public function equals(Password $other): bool
    {
        return $this->hashedValue === $other->hashedValue;
    }
    
    /**
     * Generate random password (returns Password object)
     */
    public static function generate(int $length = 16): self
    {
        $plainPassword = PasswordPolicy::generateRandom($length);
        return self::fromPlainText($plainPassword);
    }
    
    /**
     * Validate password against custom policies (static method)
     */
    public static function validateAgainstPolicies(string $plainPassword, array $policies): bool
    {
        try {
            PasswordPolicy::validate($plainPassword, $policies);
            return true;
        } catch (\InvalidArgumentException $e) {
            return false;
        }
    }
    
    /**
     * Check if password has been compromised
     */
    public function isCompromised(): bool
    {
        // In real implementation, this would check against
        // Have I Been Pwned API or similar service
        // For now, return false
        return false;
    }
    
    /**
     * Check if password was used before
     * Note: This compares hashes directly, so the same password
     * must have been hashed with the same algorithm
     */
    public function wasUsedBefore(array $previousHashes): bool
    {
        return in_array($this->hashedValue, $previousHashes, true);
    }
    
    /**
     * String representation (masked for security)
     */
    public function __toString(): string
    {
        return '********';
    }
    
    /**
     * Get password strength
     */
    public function getStrength(): string
    {
        // Since we can't calculate strength from hash,
        // we'll return a default value
        return 'medium';
    }
    
    /**
     * JSON serialization
     */
    public function jsonSerialize(): mixed
    {
        return $this->__toString();
    }
} 