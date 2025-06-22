<?php

declare(strict_types=1);

namespace App\Competency\Domain\ValueObjects;

/**
 * Represents an assessment score
 */
final class AssessmentScore
{
    private const DEFAULT_PASSING_THRESHOLD = 70.0;
    
    private const GRADE_SCALE = [
        'A' => 90,
        'B' => 80,
        'C' => 70,
        'D' => 60,
        'F' => 0,
    ];
    
    private function __construct(
        private readonly float $percentage,
        private readonly ?int $points = null,
        private readonly ?int $maxPoints = null
    ) {
        if ($percentage < 0 || $percentage > 100) {
            throw new \InvalidArgumentException('Score percentage must be between 0 and 100');
        }
    }
    
    public static function fromPercentage(float $percentage): self
    {
        return new self($percentage);
    }
    
    public static function fromPoints(int $points, int $maxPoints): self
    {
        if ($points < 0) {
            throw new \InvalidArgumentException('Points cannot be negative');
        }
        
        if ($maxPoints <= 0) {
            throw new \InvalidArgumentException('Max points must be greater than 0');
        }
        
        if ($points > $maxPoints) {
            throw new \InvalidArgumentException('Points cannot exceed max points');
        }
        
        $percentage = ($points / $maxPoints) * 100;
        
        return new self($percentage, $points, $maxPoints);
    }
    
    public function getPercentage(): float
    {
        return $this->percentage;
    }
    
    public function getRoundedPercentage(): int
    {
        return (int) round($this->percentage);
    }
    
    public function getPoints(): ?int
    {
        return $this->points;
    }
    
    public function getMaxPoints(): ?int
    {
        return $this->maxPoints;
    }
    
    public function isPassing(float $threshold = self::DEFAULT_PASSING_THRESHOLD): bool
    {
        return $this->percentage >= $threshold;
    }
    
    public function isPerfect(): bool
    {
        return $this->percentage === 100.0;
    }
    
    public function getGradeLetter(): string
    {
        foreach (self::GRADE_SCALE as $grade => $minPercentage) {
            if ($this->percentage >= $minPercentage) {
                return $grade;
            }
        }
        
        return 'F';
    }
    
    public function isHigherThan(self $other): bool
    {
        return $this->percentage > $other->percentage;
    }
    
    public function isLowerThan(self $other): bool
    {
        return $this->percentage < $other->percentage;
    }
    
    public function equals(self $other): bool
    {
        return abs($this->percentage - $other->percentage) < 0.001; // Float comparison tolerance
    }
    
    public function __toString(): string
    {
        return $this->percentage . '%';
    }
} 