<?php

declare(strict_types=1);

namespace App\Position\Domain\ValueObjects;

use App\Competency\Domain\ValueObjects\CompetencyId;
use App\Competency\Domain\ValueObjects\CompetencyLevel;

final class RequiredCompetency
{
    private CompetencyId $competencyId;
    private CompetencyLevel $minimumLevel;
    private bool $isRequired;
    
    public function __construct(
        CompetencyId $competencyId,
        CompetencyLevel $minimumLevel,
        bool $isRequired = true
    ) {
        $this->competencyId = $competencyId;
        $this->minimumLevel = $minimumLevel;
        $this->isRequired = $isRequired;
    }
    
    public static function required(
        CompetencyId $competencyId,
        CompetencyLevel $minimumLevel
    ): self {
        return new self($competencyId, $minimumLevel, true);
    }
    
    public static function desired(
        CompetencyId $competencyId,
        CompetencyLevel $preferredLevel
    ): self {
        return new self($competencyId, $preferredLevel, false);
    }
    
    public function getCompetencyId(): CompetencyId
    {
        return $this->competencyId;
    }
    
    public function getMinimumLevel(): CompetencyLevel
    {
        return $this->minimumLevel;
    }
    
    public function isRequired(): bool
    {
        return $this->isRequired;
    }
    
    public function isDesired(): bool
    {
        return !$this->isRequired;
    }
    
    public function equals(RequiredCompetency $other): bool
    {
        return $this->competencyId->equals($other->competencyId) &&
               $this->minimumLevel->equals($other->minimumLevel) &&
               $this->isRequired === $other->isRequired;
    }
} 