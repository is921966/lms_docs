<?php

namespace CompetencyService\Domain\Entities;

use CompetencyService\Domain\Common\AggregateRoot;
use CompetencyService\Domain\ValueObjects\CompetencyId;
use CompetencyService\Domain\ValueObjects\CompetencyCode;
use CompetencyService\Domain\ValueObjects\CompetencyLevel;
use CompetencyService\Domain\Events\CompetencyCreated;
use CompetencyService\Domain\Events\CompetencyUpdated;

class Competency extends AggregateRoot
{
    private CompetencyId $id;
    private CompetencyCode $code;
    private string $name;
    private string $description;
    private string $category;
    private array $levels = [];
    private bool $isActive = true;
    private \DateTimeImmutable $createdAt;
    private ?\DateTimeImmutable $updatedAt = null;
    
    public function __construct(
        CompetencyId $id,
        CompetencyCode $code,
        string $name,
        string $description,
        string $category
    ) {
        $this->id = $id;
        $this->code = $code;
        $this->name = $name;
        $this->description = $description;
        $this->category = $category;
        $this->createdAt = new \DateTimeImmutable();
        
        $this->raiseDomainEvent(new CompetencyCreated(
            $id,
            $code,
            $name,
            $description,
            $category
        ));
    }
    
    public function update(string $name, string $description): void
    {
        $this->name = $name;
        $this->description = $description;
        $this->updatedAt = new \DateTimeImmutable();
        
        $this->raiseDomainEvent(new CompetencyUpdated(
            $this->id,
            $name,
            $description
        ));
    }
    
    public function addLevel(CompetencyLevel $level): void
    {
        $this->levels[] = $level;
        $this->sortLevels();
    }
    
    public function deactivate(): void
    {
        $this->isActive = false;
    }
    
    public function activate(): void
    {
        $this->isActive = true;
    }
    
    private function sortLevels(): void
    {
        usort($this->levels, function (CompetencyLevel $a, CompetencyLevel $b) {
            return $a->getLevel() <=> $b->getLevel();
        });
    }
    
    // Getters
    public function getId(): CompetencyId
    {
        return $this->id;
    }
    
    public function getCode(): CompetencyCode
    {
        return $this->code;
    }
    
    public function getName(): string
    {
        return $this->name;
    }
    
    public function getDescription(): string
    {
        return $this->description;
    }
    
    public function getCategory(): string
    {
        return $this->category;
    }
    
    public function getLevels(): array
    {
        return $this->levels;
    }
    
    public function isActive(): bool
    {
        return $this->isActive;
    }
    
    public function getMinLevel(): ?int
    {
        if (empty($this->levels)) {
            return null;
        }
        return $this->levels[0]->getLevel();
    }
    
    public function getMaxLevel(): ?int
    {
        if (empty($this->levels)) {
            return null;
        }
        return $this->levels[count($this->levels) - 1]->getLevel();
    }
    
    public function toArray(): array
    {
        return [
            'id' => $this->id->toString(),
            'code' => $this->code->getValue(),
            'name' => $this->name,
            'description' => $this->description,
            'category' => $this->category,
            'levels' => array_map(fn($level) => $level->toArray(), $this->levels),
            'is_active' => $this->isActive,
            'created_at' => $this->createdAt->format('Y-m-d H:i:s'),
            'updated_at' => $this->updatedAt?->format('Y-m-d H:i:s')
        ];
    }
} 