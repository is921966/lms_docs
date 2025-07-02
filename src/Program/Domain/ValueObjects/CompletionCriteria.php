<?php

declare(strict_types=1);

namespace Program\Domain\ValueObjects;

final class CompletionCriteria implements \JsonSerializable
{
    private int $percentage;
    private bool $requireAll;
    
    private function __construct(int $percentage, bool $requireAll = false)
    {
        if ($percentage < 0 || $percentage > 100) {
            throw new \InvalidArgumentException('Percentage must be between 0 and 100');
        }
        
        $this->percentage = $percentage;
        $this->requireAll = $requireAll;
    }
    
    public static function fromPercentage(int $percentage): self
    {
        return new self($percentage, false);
    }
    
    public static function requireAll(): self
    {
        return new self(100, true);
    }
    
    public function getRequiredPercentage(): int
    {
        return $this->percentage;
    }
    
    public function requiresAllCourses(): bool
    {
        return $this->requireAll;
    }
    
    public function isMet(int $completedCourses, int $totalCourses): bool
    {
        if ($totalCourses === 0) {
            return true;
        }
        
        $completionPercentage = ($completedCourses / $totalCourses) * 100;
        
        if ($this->requireAll) {
            return $completedCourses === $totalCourses;
        }
        
        return $completionPercentage >= $this->percentage;
    }
    
    public function calculateProgress(int $completedCourses, int $totalCourses): float
    {
        if ($totalCourses === 0) {
            return 0.0;
        }
        
        return ($completedCourses / $totalCourses) * 100;
    }
    
    public function equals(self $other): bool
    {
        return $this->percentage === $other->percentage && 
               $this->requireAll === $other->requireAll;
    }
    
    public function toString(): string
    {
        return $this->percentage . '%';
    }
    
    public function jsonSerialize(): array
    {
        return [
            'percentage' => $this->percentage,
            'requireAll' => $this->requireAll
        ];
    }
    
    public function __toString(): string
    {
        return $this->toString();
    }
} 