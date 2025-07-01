<?php

namespace Competency\Domain\Entities;

use Competency\Domain\ValueObjects\CategoryId;

class CompetencyCategory
{
    private CategoryId $id;
    private string $name;
    private string $description;
    private bool $isActive;
    private ?CompetencyCategory $parent = null;
    private ?string $color = null;
    private ?string $icon = null;

    private function __construct(
        CategoryId $id,
        string $name,
        string $description,
        bool $isActive = true
    ) {
        $this->id = $id;
        $this->name = $name;
        $this->description = $description;
        $this->isActive = $isActive;
    }

    public static function create(string $name, string $description): self
    {
        return new self(
            CategoryId::generate(),
            $name,
            $description
        );
    }

    public static function createWithId(
        CategoryId $id,
        string $name,
        string $description
    ): self {
        return new self($id, $name, $description);
    }

    public function getId(): CategoryId
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

    public function isActive(): bool
    {
        return $this->isActive;
    }

    public function updateDetails(string $name, string $description): void
    {
        $this->name = $name;
        $this->description = $description;
    }

    public function deactivate(): void
    {
        $this->isActive = false;
    }

    public function activate(): void
    {
        $this->isActive = true;
    }

    public function setParent(CompetencyCategory $parent): void
    {
        $this->parent = $parent;
    }

    public function removeParent(): void
    {
        $this->parent = null;
    }

    public function hasParent(): bool
    {
        return $this->parent !== null;
    }

    public function getParent(): ?CompetencyCategory
    {
        return $this->parent;
    }

    public function setColor(string $color): void
    {
        $this->color = $color;
    }

    public function getColor(): ?string
    {
        return $this->color;
    }

    public function setIcon(string $icon): void
    {
        $this->icon = $icon;
    }

    public function getIcon(): ?string
    {
        return $this->icon;
    }

    public function equals(CompetencyCategory $other): bool
    {
        return $this->id->equals($other->id);
    }
} 