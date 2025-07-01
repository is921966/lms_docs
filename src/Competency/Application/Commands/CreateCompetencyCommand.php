<?php

namespace Competency\Application\Commands;

use InvalidArgumentException;

class CreateCompetencyCommand
{
    private string $name;
    private string $description;
    private string $categoryId;
    private array $skillLevels;

    public function __construct(
        string $name,
        string $description,
        string $categoryId,
        array $skillLevels = []
    ) {
        if (empty($name)) {
            throw new InvalidArgumentException('Competency name cannot be empty');
        }

        if (empty($description)) {
            throw new InvalidArgumentException('Competency description cannot be empty');
        }

        if (empty($categoryId)) {
            throw new InvalidArgumentException('Category ID cannot be empty');
        }

        // Validate skill levels
        foreach ($skillLevels as $level) {
            if (!isset($level['level']) || $level['level'] < 1 || $level['level'] > 5) {
                throw new InvalidArgumentException('Skill level must be between 1 and 5');
            }
            if (empty($level['name'])) {
                throw new InvalidArgumentException('Skill level name cannot be empty');
            }
            if (empty($level['description'])) {
                throw new InvalidArgumentException('Skill level description cannot be empty');
            }
        }

        $this->name = $name;
        $this->description = $description;
        $this->categoryId = $categoryId;
        $this->skillLevels = $skillLevels;
    }

    public function getName(): string
    {
        return $this->name;
    }

    public function getDescription(): string
    {
        return $this->description;
    }

    public function getCategoryId(): string
    {
        return $this->categoryId;
    }

    public function getSkillLevels(): array
    {
        return $this->skillLevels;
    }

    public function toArray(): array
    {
        return [
            'name' => $this->name,
            'description' => $this->description,
            'categoryId' => $this->categoryId,
            'skillLevels' => $this->skillLevels
        ];
    }
} 