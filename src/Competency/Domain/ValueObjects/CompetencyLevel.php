<?php

declare(strict_types=1);

namespace Competency\Domain\ValueObjects;

/**
 * Represents a competency proficiency level
 */
final class CompetencyLevel
{
    private const LEVELS = [
        1 => [
            'name' => 'Beginner',
            'description' => 'Basic knowledge, requires supervision'
        ],
        2 => [
            'name' => 'Elementary', 
            'description' => 'Can perform simple tasks independently'
        ],
        3 => [
            'name' => 'Intermediate',
            'description' => 'Can handle standard tasks and solve common problems'
        ],
        4 => [
            'name' => 'Advanced',
            'description' => 'Can handle complex tasks and mentor others'
        ],
        5 => [
            'name' => 'Expert',
            'description' => 'Deep expertise, can innovate and lead initiatives'
        ],
    ];

    private function __construct(
        private readonly int $value
    ) {
        if (!isset(self::LEVELS[$value])) {
            throw new \InvalidArgumentException(
                sprintf('Invalid competency level: %d. Valid levels are 1-5', $value)
            );
        }
    }

    public static function beginner(): self
    {
        return new self(1);
    }

    public static function elementary(): self
    {
        return new self(2);
    }

    public static function intermediate(): self
    {
        return new self(3);
    }

    public static function advanced(): self
    {
        return new self(4);
    }

    public static function expert(): self
    {
        return new self(5);
    }

    public static function fromValue(int $value): self
    {
        return new self($value);
    }

    public function getValue(): int
    {
        return $this->value;
    }

    public function getName(): string
    {
        return self::LEVELS[$this->value]['name'];
    }

    public function getDescription(): string
    {
        return self::LEVELS[$this->value]['description'];
    }

    public function isLowerThan(self $other): bool
    {
        return $this->value < $other->value;
    }

    public function isHigherThan(self $other): bool
    {
        return $this->value > $other->value;
    }

    public function equals(self $other): bool
    {
        return $this->value === $other->value;
    }

    public function meetsRequirement(self $requiredLevel): bool
    {
        return $this->value >= $requiredLevel->value;
    }

    public function gapTo(self $targetLevel): int
    {
        return $targetLevel->value - $this->value;
    }

    /**
     * @return self[]
     */
    public static function getAllLevels(): array
    {
        $levels = [];
        foreach (array_keys(self::LEVELS) as $value) {
            $levels[] = new self($value);
        }
        return $levels;
    }

    public function __toString(): string
    {
        return sprintf('%s (%d)', $this->getName(), $this->value);
    }
} 