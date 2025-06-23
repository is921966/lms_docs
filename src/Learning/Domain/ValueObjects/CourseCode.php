<?php

declare(strict_types=1);

namespace App\Learning\Domain\ValueObjects;

final class CourseCode implements \JsonSerializable
{
    private const PATTERN = '/^[A-Z]{2,5}-\d{3,}$/';
    
    private string $code;
    
    private function __construct(string $code)
    {
        $this->validateCode($code);
        $this->code = $code;
    }
    
    public static function fromString(string $code): self
    {
        return new self($code);
    }
    
    private function validateCode(string $code): void
    {
        if (empty($code)) {
            throw new \InvalidArgumentException('Invalid course code format: code cannot be empty');
        }
        
        if (!preg_match(self::PATTERN, $code)) {
            throw new \InvalidArgumentException(
                sprintf('Invalid course code format: "%s". Expected format: 2-5 uppercase letters, hyphen, 3+ digits (e.g., CRS-001)', $code)
            );
        }
    }
    
    public function toString(): string
    {
        return $this->code;
    }
    
    public function equals(self $other): bool
    {
        return $this->code === $other->code;
    }
    
    public function jsonSerialize(): string
    {
        return $this->code;
    }
    
    public function __toString(): string
    {
        return $this->code;
    }
} 