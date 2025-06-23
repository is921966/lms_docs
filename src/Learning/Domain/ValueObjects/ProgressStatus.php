<?php

declare(strict_types=1);

namespace App\Learning\Domain\ValueObjects;

enum ProgressStatus: string
{
    case NOT_STARTED = 'not_started';
    case IN_PROGRESS = 'in_progress';
    case COMPLETED = 'completed';
    case FAILED = 'failed';
    
    public function label(): string
    {
        return match ($this) {
            self::NOT_STARTED => 'Не начато',
            self::IN_PROGRESS => 'В процессе',
            self::COMPLETED => 'Завершено',
            self::FAILED => 'Провалено',
        };
    }
    
    public function isCompleted(): bool
    {
        return $this === self::COMPLETED;
    }
    
    public function isActive(): bool
    {
        return $this === self::IN_PROGRESS;
    }
    
    public static function fromPercentage(float $percentage): self
    {
        if ($percentage < 0 || $percentage > 100) {
            throw new \InvalidArgumentException('Percentage must be between 0 and 100');
        }
        
        return match (true) {
            $percentage === 0.0 => self::NOT_STARTED,
            $percentage === 100.0 => self::COMPLETED,
            default => self::IN_PROGRESS,
        };
    }
} 