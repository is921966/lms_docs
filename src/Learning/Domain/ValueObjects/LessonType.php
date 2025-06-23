<?php

declare(strict_types=1);

namespace App\Learning\Domain\ValueObjects;

enum LessonType: string implements \JsonSerializable
{
    case VIDEO = 'VIDEO';
    case TEXT = 'TEXT';
    case QUIZ = 'QUIZ';
    case ASSIGNMENT = 'ASSIGNMENT';
    
    public function getLabel(): string
    {
        return match($this) {
            self::VIDEO => 'Video Lesson',
            self::TEXT => 'Text Lesson',
            self::QUIZ => 'Quiz',
            self::ASSIGNMENT => 'Assignment',
        };
    }
    
    public function getIcon(): string
    {
        return match($this) {
            self::VIDEO => '🎥',
            self::TEXT => '📄',
            self::QUIZ => '❓',
            self::ASSIGNMENT => '📝',
        };
    }
    
    public function isInteractive(): bool
    {
        return in_array($this, [self::QUIZ, self::ASSIGNMENT], true);
    }
    
    public function isGradable(): bool
    {
        return in_array($this, [self::QUIZ, self::ASSIGNMENT], true);
    }
    
    public function jsonSerialize(): string
    {
        return $this->value;
    }
} 