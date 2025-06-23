<?php

declare(strict_types=1);

namespace App\Learning\Domain\ValueObjects;

enum CourseStatus: string implements \JsonSerializable
{
    case DRAFT = 'DRAFT';
    case PUBLISHED = 'PUBLISHED';
    case ARCHIVED = 'ARCHIVED';
    
    public function getLabel(): string
    {
        return match($this) {
            self::DRAFT => 'Draft',
            self::PUBLISHED => 'Published',
            self::ARCHIVED => 'Archived',
        };
    }
    
    public function isActive(): bool
    {
        return $this === self::PUBLISHED;
    }
    
    public function isEditable(): bool
    {
        return $this === self::DRAFT;
    }
    
    public function getAllowedTransitions(): array
    {
        return match($this) {
            self::DRAFT => [self::PUBLISHED],
            self::PUBLISHED => [self::DRAFT, self::ARCHIVED],
            self::ARCHIVED => [self::DRAFT],
        };
    }
    
    public function canTransitionTo(self $newStatus): bool
    {
        return in_array($newStatus, $this->getAllowedTransitions(), true);
    }
    
    public static function values(): array
    {
        return array_map(fn($case) => $case->value, self::cases());
    }
    
    public function jsonSerialize(): string
    {
        return $this->value;
    }
} 