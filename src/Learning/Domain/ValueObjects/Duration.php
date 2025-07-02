<?php

declare(strict_types=1);

namespace Learning\Domain\ValueObjects;

use InvalidArgumentException;

final class Duration
{
    private function __construct(
        private readonly int $minutes
    ) {
        if ($minutes < 0) {
            throw new InvalidArgumentException('Duration cannot be negative');
        }
    }
    
    public static function fromMinutes(int $minutes): self
    {
        return new self($minutes);
    }
    
    public static function fromHours(float $hours): self
    {
        return new self((int)($hours * 60));
    }
    
    public static function fromString(string $duration): self
    {
        $duration = trim($duration);
        
        // Match patterns like "2h 30m", "45m", "3h"
        if (!preg_match('/^((\d+)h)?\s*((\d+)m)?$/', $duration, $matches)) {
            throw new InvalidArgumentException('Invalid duration format. Use format like "2h 30m", "45m", or "3h"');
        }
        
        $hours = isset($matches[2]) ? (int)$matches[2] : 0;
        $minutes = isset($matches[4]) ? (int)$matches[4] : 0;
        
        if ($hours === 0 && $minutes === 0 && $duration !== '0m') {
            throw new InvalidArgumentException('Invalid duration format');
        }
        
        return new self($hours * 60 + $minutes);
    }
    
    public function getMinutes(): int
    {
        return $this->minutes;
    }
    
    public function getHours(): int
    {
        return intval($this->minutes / 60);
    }
    
    public function getRemainingMinutes(): int
    {
        return $this->minutes % 60;
    }
    
    public function format(): string
    {
        if ($this->minutes === 0) {
            return '0m';
        }
        
        $hours = $this->getHours();
        $minutes = $this->getRemainingMinutes();
        
        if ($hours > 0 && $minutes > 0) {
            return sprintf('%dh %dm', $hours, $minutes);
        } elseif ($hours > 0) {
            return sprintf('%dh', $hours);
        } else {
            return sprintf('%dm', $minutes);
        }
    }
    
    public function add(self $other): self
    {
        return new self($this->minutes + $other->minutes);
    }
    
    public function subtract(self $other): self
    {
        $result = $this->minutes - $other->minutes;
        if ($result < 0) {
            throw new InvalidArgumentException('Cannot subtract to negative duration');
        }
        return new self($result);
    }
    
    public function equals(self $other): bool
    {
        return $this->minutes === $other->minutes;
    }
    
    public function isLessThan(self $other): bool
    {
        return $this->minutes < $other->minutes;
    }
    
    public function isGreaterThan(self $other): bool
    {
        return $this->minutes > $other->minutes;
    }
    
    public function __toString(): string
    {
        return $this->format();
    }
} 