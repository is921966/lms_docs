<?php

declare(strict_types=1);

namespace Program\Domain\ValueObjects;

final class ProgramStatus implements \JsonSerializable
{
    private const DRAFT = 'draft';
    private const ACTIVE = 'active';
    private const ARCHIVED = 'archived';
    
    private const VALID_STATUSES = [
        self::DRAFT,
        self::ACTIVE,
        self::ARCHIVED
    ];
    
    private const ALLOWED_TRANSITIONS = [
        self::DRAFT => [self::ACTIVE],
        self::ACTIVE => [self::ARCHIVED],
        self::ARCHIVED => []
    ];
    
    private string $value;
    
    private function __construct(string $value)
    {
        $this->value = $value;
    }
    
    public static function draft(): self
    {
        return new self(self::DRAFT);
    }
    
    public static function active(): self
    {
        return new self(self::ACTIVE);
    }
    
    public static function archived(): self
    {
        return new self(self::ARCHIVED);
    }
    
    public static function fromString(string $value): self
    {
        if (!in_array($value, self::VALID_STATUSES, true)) {
            throw new \InvalidArgumentException('Invalid program status: ' . $value);
        }
        
        return new self($value);
    }
    
    public function getValue(): string
    {
        return $this->value;
    }
    
    public function isDraft(): bool
    {
        return $this->value === self::DRAFT;
    }
    
    public function isActive(): bool
    {
        return $this->value === self::ACTIVE;
    }
    
    public function isArchived(): bool
    {
        return $this->value === self::ARCHIVED;
    }
    
    public function canTransitionTo(self $newStatus): bool
    {
        $allowedTransitions = self::ALLOWED_TRANSITIONS[$this->value] ?? [];
        return in_array($newStatus->value, $allowedTransitions, true);
    }
    
    public function canBePublished(): bool
    {
        return $this->isDraft();
    }
    
    public function equals(self $other): bool
    {
        return $this->value === $other->value;
    }
    
    public function jsonSerialize(): string
    {
        return $this->value;
    }
    
    public function __toString(): string
    {
        return $this->value;
    }
} 