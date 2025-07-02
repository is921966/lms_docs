<?php

declare(strict_types=1);

namespace Competency\Domain\ValueObjects;

/**
 * Competency category value object
 */
final class CompetencyCategory
{
    private const TECHNICAL = 'technical';
    private const SOFT = 'soft';
    private const LEADERSHIP = 'leadership';
    private const BUSINESS = 'business';
    
    private const VALID_CATEGORIES = [
        self::TECHNICAL,
        self::SOFT,
        self::LEADERSHIP,
        self::BUSINESS,
    ];
    
    private const DISPLAY_NAMES = [
        self::TECHNICAL => 'Technical',
        self::SOFT => 'Soft Skills',
        self::LEADERSHIP => 'Leadership',
        self::BUSINESS => 'Business',
    ];
    
    private const COLORS = [
        self::TECHNICAL => '#3B82F6',  // Blue
        self::SOFT => '#10B981',       // Green
        self::LEADERSHIP => '#8B5CF6', // Purple
        self::BUSINESS => '#F59E0B',   // Amber
    ];
    
    private string $value;
    
    private function __construct(string $value)
    {
        if (!in_array($value, self::VALID_CATEGORIES, true)) {
            throw new \InvalidArgumentException(
                sprintf('Invalid competency category: %s', $value)
            );
        }
        
        $this->value = $value;
    }
    
    /**
     * Create from string
     */
    public static function fromString(string $value): self
    {
        return new self($value);
    }
    
    /**
     * Technical competencies
     */
    public static function technical(): self
    {
        return new self(self::TECHNICAL);
    }
    
    /**
     * Soft skills competencies
     */
    public static function soft(): self
    {
        return new self(self::SOFT);
    }
    
    /**
     * Leadership competencies
     */
    public static function leadership(): self
    {
        return new self(self::LEADERSHIP);
    }
    
    /**
     * Business competencies
     */
    public static function business(): self
    {
        return new self(self::BUSINESS);
    }
    
    /**
     * Get value
     */
    public function getValue(): string
    {
        return $this->value;
    }
    
    /**
     * Get display name
     */
    public function getDisplayName(): string
    {
        return self::DISPLAY_NAMES[$this->value];
    }
    
    /**
     * Get color
     */
    public function getColor(): string
    {
        return self::COLORS[$this->value];
    }
    
    /**
     * Compare with another category
     */
    public function equals(self $other): bool
    {
        return $this->value === $other->value;
    }
    
    /**
     * Get all valid categories
     */
    public static function validCategories(): array
    {
        return self::VALID_CATEGORIES;
    }
    
    /**
     * String representation
     */
    public function __toString(): string
    {
        return $this->value;
    }
} 