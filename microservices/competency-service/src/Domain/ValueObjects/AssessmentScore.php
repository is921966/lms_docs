<?php

namespace CompetencyService\Domain\ValueObjects;

use InvalidArgumentException;

final class AssessmentScore
{
    private int $level;
    private string $feedback;
    private string $recommendations;
    
    public function __construct(int $level, string $feedback, string $recommendations)
    {
        $this->validateLevel($level);
        $this->validateFeedback($feedback);
        
        $this->level = $level;
        $this->feedback = $feedback;
        $this->recommendations = $recommendations;
    }
    
    private function validateLevel(int $level): void
    {
        if ($level < 1 || $level > 5) {
            throw new InvalidArgumentException('Assessment level must be between 1 and 5');
        }
    }
    
    private function validateFeedback(string $feedback): void
    {
        if (empty($feedback)) {
            throw new InvalidArgumentException('Feedback cannot be empty');
        }
        
        if (strlen($feedback) > 1000) {
            throw new InvalidArgumentException('Feedback cannot exceed 1000 characters');
        }
    }
    
    public function getLevel(): int
    {
        return $this->level;
    }
    
    public function getFeedback(): string
    {
        return $this->feedback;
    }
    
    public function getRecommendations(): string
    {
        return $this->recommendations;
    }
    
    public function toArray(): array
    {
        return [
            'level' => $this->level,
            'feedback' => $this->feedback,
            'recommendations' => $this->recommendations
        ];
    }
} 