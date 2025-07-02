<?php

declare(strict_types=1);

namespace Learning\Domain\ValueObjects;

use InvalidArgumentException;

final class CourseStatus
{
    private const STATUSES = [
        'draft' => [
            'display' => 'Draft',
            'can_enroll' => true,
            'transitions' => ['under_review', 'published']
        ],
        'under_review' => [
            'display' => 'Under Review',
            'can_enroll' => false,
            'transitions' => ['draft', 'published']
        ],
        'published' => [
            'display' => 'Published',
            'can_enroll' => true,
            'transitions' => ['archived']
        ],
        'archived' => [
            'display' => 'Archived',
            'can_enroll' => false,
            'transitions' => []
        ]
    ];
    
    private function __construct(
        private readonly string $value
    ) {
        if (!array_key_exists($value, self::STATUSES)) {
            throw new InvalidArgumentException("Invalid course status: {$value}");
        }
    }
    
    public static function draft(): self
    {
        return new self('draft');
    }
    
    public static function underReview(): self
    {
        return new self('under_review');
    }
    
    public static function published(): self
    {
        return new self('published');
    }
    
    public static function archived(): self
    {
        return new self('archived');
    }
    
    public static function fromString(string $value): self
    {
        return new self(strtolower(trim($value)));
    }
    
    public static function getAllStatuses(): array
    {
        return array_keys(self::STATUSES);
    }
    
    public function getValue(): string
    {
        return $this->value;
    }
    
    public function getDisplayName(): string
    {
        return self::STATUSES[$this->value]['display'];
    }
    
    public function isDraft(): bool
    {
        return $this->value === 'draft';
    }
    
    public function isUnderReview(): bool
    {
        return $this->value === 'under_review';
    }
    
    public function isPublished(): bool
    {
        return $this->value === 'published';
    }
    
    public function isArchived(): bool
    {
        return $this->value === 'archived';
    }
    
    public function canEnroll(): bool
    {
        return self::STATUSES[$this->value]['can_enroll'];
    }
    
    public function canTransitionTo(self $newStatus): bool
    {
        return in_array($newStatus->value, self::STATUSES[$this->value]['transitions']);
    }
    
    public function equals(self $other): bool
    {
        return $this->value === $other->value;
    }
    
    public function __toString(): string
    {
        return $this->value;
    }
} 