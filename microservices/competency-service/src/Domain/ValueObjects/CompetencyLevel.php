<?php

namespace CompetencyService\Domain\ValueObjects;

use InvalidArgumentException;

final class CompetencyLevel
{
    private int $level;
    private string $name;
    private string $description;
    private array $criteria;
    
    public function __construct(int $level, string $name, string $description, array $criteria = [])
    {
        $this->validateLevel($level);
        $this->validateName($name);
        $this->validateDescription($description);
        
        $this->level = $level;
        $this->name = $name;
        $this->description = $description;
        $this->criteria = $criteria;
    }
    
    private function validateLevel(int $level): void
    {
        if ($level < 1 || $level > 10) {
            throw new InvalidArgumentException('Level must be between 1 and 10');
        }
    }
    
    private function validateName(string $name): void
    {
        if (empty($name)) {
            throw new InvalidArgumentException('Level name cannot be empty');
        }
        
        if (strlen($name) > 50) {
            throw new InvalidArgumentException('Level name cannot exceed 50 characters');
        }
    }
    
    private function validateDescription(string $description): void
    {
        if (empty($description)) {
            throw new InvalidArgumentException('Level description cannot be empty');
        }
        
        if (strlen($description) > 500) {
            throw new InvalidArgumentException('Level description cannot exceed 500 characters');
        }
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
    
    public function getCriteria(): array
    {
        return $this->criteria;
    }
    
    public function toArray(): array
    {
        return [
            'level' => $this->level,
            'name' => $this->name,
            'description' => $this->description,
            'criteria' => $this->criteria
        ];
    }
} 