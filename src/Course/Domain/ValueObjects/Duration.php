<?php

declare(strict_types=1);

namespace App\Course\Domain\ValueObjects;

use App\Common\Exceptions\InvalidArgumentException;

final class Duration
{
    private int $minutes;
    
    public function __construct(int $minutes)
    {
        if ($minutes < 0) {
            throw new InvalidArgumentException('Duration cannot be negative');
        }
        
        if ($minutes === 0) {
            throw new InvalidArgumentException('Duration must be greater than zero');
        }
        
        $this->minutes = $minutes;
    }
    
    public static function fromHours(float $hours): self
    {
        return new self((int)($hours * 60));
    }
    
    public function inMinutes(): int
    {
        return $this->minutes;
    }
    
    public function inHours(): float
    {
        return round($this->minutes / 60, 2);
    }
    
    public function add(self $other): self
    {
        return new self($this->minutes + $other->minutes);
    }
    
    public function equals(self $other): bool
    {
        return $this->minutes === $other->minutes;
    }
    
    public function __toString(): string
    {
        $hours = intval($this->minutes / 60);
        $remainingMinutes = $this->minutes % 60;
        
        if ($hours === 0) {
            return "{$remainingMinutes}m";
        }
        
        if ($remainingMinutes === 0) {
            return "{$hours}h";
        }
        
        return "{$hours}h {$remainingMinutes}m";
    }
} 