<?php

namespace Competency\Domain\Entities;

use Competency\Domain\ValueObjects\CompetencyId;
use Competency\Domain\ValueObjects\SkillLevel;

class Competency
{
    private CompetencyId $id;
    private string $name;
    private string $description;
    private CompetencyCategory $category;
    private bool $isActive;
    private array $skillLevels = [];
    private array $requiredForPositions = [];

    private function __construct(
        CompetencyId $id,
        string $name,
        string $description,
        CompetencyCategory $category,
        bool $isActive = true
    ) {
        $this->id = $id;
        $this->name = $name;
        $this->description = $description;
        $this->category = $category;
        $this->isActive = $isActive;
    }

    public static function create(
        string $name,
        string $description,
        CompetencyCategory $category
    ): self {
        return new self(
            CompetencyId::generate(),
            $name,
            $description,
            $category
        );
    }

    public static function createWithId(
        CompetencyId $id,
        string $name,
        string $description,
        CompetencyCategory $category
    ): self {
        return new self($id, $name, $description, $category);
    }

    public function getId(): CompetencyId
    {
        return $this->id;
    }

    public function getName(): string
    {
        return $this->name;
    }

    public function getDescription(): string
    {
        return $this->description;
    }

    public function getCategory(): CompetencyCategory
    {
        return $this->category;
    }

    public function isActive(): bool
    {
        return $this->isActive;
    }

    public function updateDetails(string $name, string $description): void
    {
        $this->name = $name;
        $this->description = $description;
    }

    public function changeCategory(CompetencyCategory $category): void
    {
        $this->category = $category;
    }

    public function addSkillLevel(SkillLevel $level): void
    {
        $this->skillLevels[$level->getLevel()] = $level;
    }

    public function getSkillLevels(): array
    {
        return array_values($this->skillLevels);
    }

    public function hasSkillLevel(int $level): bool
    {
        return isset($this->skillLevels[$level]);
    }

    public function getSkillLevel(int $level): ?SkillLevel
    {
        return $this->skillLevels[$level] ?? null;
    }

    public function deactivate(): void
    {
        $this->isActive = false;
    }

    public function activate(): void
    {
        $this->isActive = true;
    }

    public function addRequiredForPosition(string $positionId, int $requiredLevel): void
    {
        $this->requiredForPositions[$positionId] = $requiredLevel;
    }

    public function removeRequiredForPosition(string $positionId): void
    {
        unset($this->requiredForPositions[$positionId]);
    }

    public function isRequiredForPosition(string $positionId): bool
    {
        return isset($this->requiredForPositions[$positionId]);
    }

    public function getRequiredLevelForPosition(string $positionId): ?int
    {
        return $this->requiredForPositions[$positionId] ?? null;
    }

    public function getRequiredForPositions(): array
    {
        return $this->requiredForPositions;
    }

    public function equals(Competency $other): bool
    {
        return $this->id->equals($other->id);
    }
} 