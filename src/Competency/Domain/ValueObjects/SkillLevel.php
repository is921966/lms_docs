<?php

namespace Competency\Domain\ValueObjects;

use InvalidArgumentException;

class SkillLevel
{
    private int $level;
    private string $name;
    private string $description;

    public function __construct(int $level, string $name, string $description)
    {
        if ($level < 1 || $level > 5) {
            throw new InvalidArgumentException('Skill level must be between 1 and 5');
        }

        if (empty($name)) {
            throw new InvalidArgumentException('Skill level name cannot be empty');
        }

        if (empty($description)) {
            throw new InvalidArgumentException('Skill level description cannot be empty');
        }

        $this->level = $level;
        $this->name = $name;
        $this->description = $description;
    }

    public static function beginner(): self
    {
        return new self(
            1,
            'Beginner',
            'Has basic awareness and understanding of the skill'
        );
    }

    public static function elementary(): self
    {
        return new self(
            2,
            'Elementary',
            'Can perform simple tasks with guidance'
        );
    }

    public static function intermediate(): self
    {
        return new self(
            3,
            'Intermediate',
            'Can work independently on most tasks'
        );
    }

    public static function advanced(): self
    {
        return new self(
            4,
            'Advanced',
            'Can handle complex tasks and mentor others'
        );
    }

    public static function expert(): self
    {
        return new self(
            5,
            'Expert',
            'Has deep expertise and can lead strategic initiatives'
        );
    }

    public function getLevel(): int
    {
        return $this->level;
    }

    public function getName(): string
    {
        return $this->name;
    }

    public function getDescription(): string
    {
        return $this->description;
    }

    public function equals(SkillLevel $other): bool
    {
        return $this->level === $other->level;
    }

    public function isLowerThan(SkillLevel $other): bool
    {
        return $this->level < $other->level;
    }

    public function isHigherThan(SkillLevel $other): bool
    {
        return $this->level > $other->level;
    }

    public function __toString(): string
    {
        return sprintf('%s (Level %d)', $this->name, $this->level);
    }

    public function toArray(): array
    {
        return [
            'level' => $this->level,
            'name' => $this->name,
            'description' => $this->description
        ];
    }
} 