<?php

namespace App\Domain\ValueObject;

final class Password
{
    private string $hashedValue;
    
    private function __construct(string $hashedValue)
    {
        $this->hashedValue = $hashedValue;
    }
    
    public static function fromPlainText(string $plainText): self
    {
        if (strlen($plainText) < 8) {
            throw new \InvalidArgumentException('Password must be at least 8 characters long');
        }
        
        if (!preg_match('/[A-Z]/', $plainText)) {
            throw new \InvalidArgumentException('Password must contain at least one uppercase letter');
        }
        
        if (!preg_match('/[a-z]/', $plainText)) {
            throw new \InvalidArgumentException('Password must contain at least one lowercase letter');
        }
        
        if (!preg_match('/[0-9]/', $plainText)) {
            throw new \InvalidArgumentException('Password must contain at least one number');
        }
        
        $hashedValue = password_hash($plainText, PASSWORD_ARGON2ID, [
            'memory_cost' => PASSWORD_ARGON2_DEFAULT_MEMORY_COST,
            'time_cost' => PASSWORD_ARGON2_DEFAULT_TIME_COST,
            'threads' => PASSWORD_ARGON2_DEFAULT_THREADS,
        ]);
        
        return new self($hashedValue);
    }
    
    public static function fromHash(string $hashedValue): self
    {
        return new self($hashedValue);
    }
    
    public function verify(string $plainText): bool
    {
        return password_verify($plainText, $this->hashedValue);
    }
    
    public function needsRehash(): bool
    {
        return password_needs_rehash($this->hashedValue, PASSWORD_ARGON2ID);
    }
    
    public function getHashed(): string
    {
        return $this->hashedValue;
    }
} 