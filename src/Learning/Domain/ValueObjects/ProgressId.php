<?php

declare(strict_types=1);

namespace App\Learning\Domain\ValueObjects;

final class ProgressId
{
    private string $value;
    
    private function __construct(string $value)
    {
        if (!$this->isValidUuid($value)) {
            throw new \InvalidArgumentException('Invalid UUID format');
        }
        
        $this->value = $value;
    }
    
    public static function fromString(string $value): self
    {
        return new self($value);
    }
    
    public static function generate(): self
    {
        return new self(self::uuid4());
    }
    
    public function toString(): string
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
    
    private function isValidUuid(string $uuid): bool
    {
        return preg_match('/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i', $uuid) === 1;
    }
    
    private static function uuid4(): string
    {
        $data = random_bytes(16);
        
        $data[6] = chr(ord($data[6]) & 0x0f | 0x40);
        $data[8] = chr(ord($data[8]) & 0x3f | 0x80);
        
        return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($data), 4));
    }
} 