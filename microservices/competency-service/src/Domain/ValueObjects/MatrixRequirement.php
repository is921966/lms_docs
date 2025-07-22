<?php

namespace CompetencyService\Domain\ValueObjects;

use InvalidArgumentException;

final class MatrixRequirement
{
    private CompetencyId $competencyId;
    private int $requiredLevel;
    private string $type;
    
    public function __construct(CompetencyId $competencyId, int $requiredLevel, string $type)
    {
        $this->validateLevel($requiredLevel);
        $this->validateType($type);
        
        $this->competencyId = $competencyId;
        $this->requiredLevel = $requiredLevel;
        $this->type = $type;
    }
    
    private function validateLevel(int $level): void
    {
        if ($level < 1 || $level > 10) {
            throw new InvalidArgumentException('Required level must be between 1 and 10');
        }
    }
    
    private function validateType(string $type): void
    {
        $validTypes = ['core', 'nice-to-have', 'optional'];
        if (!in_array($type, $validTypes)) {
            throw new InvalidArgumentException(
                'Requirement type must be one of: ' . implode(', ', $validTypes)
            );
        }
    }
    
    public function getCompetencyId(): CompetencyId
    {
        return $this->competencyId;
    }
    
    public function getRequiredLevel(): int
    {
        return $this->requiredLevel;
    }
    
    public function getType(): string
    {
        return $this->type;
    }
    
    public function isCore(): bool
    {
        return $this->type === 'core';
    }
    
    public function isNiceToHave(): bool
    {
        return $this->type === 'nice-to-have';
    }
    
    public function isOptional(): bool
    {
        return $this->type === 'optional';
    }
    
    public function isSatisfiedBy(int $userLevel): bool
    {
        return $userLevel >= $this->requiredLevel;
    }
    
    public function toArray(): array
    {
        return [
            'competency_id' => $this->competencyId->toString(),
            'required_level' => $this->requiredLevel,
            'type' => $this->type
        ];
    }
} 