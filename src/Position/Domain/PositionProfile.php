<?php

declare(strict_types=1);

namespace App\Position\Domain;

use App\Position\Domain\ValueObjects\PositionId;
use App\Position\Domain\ValueObjects\RequiredCompetency;
use App\Competency\Domain\ValueObjects\CompetencyId;
use App\Competency\Domain\ValueObjects\CompetencyLevel;

class PositionProfile
{
    private PositionId $positionId;
    private array $responsibilities;
    private array $requirements;
    private array $requiredCompetencies = [];
    private array $desiredCompetencies = [];
    private \DateTimeImmutable $createdAt;
    private \DateTimeImmutable $updatedAt;
    
    private function __construct(
        PositionId $positionId,
        array $responsibilities,
        array $requirements
    ) {
        $this->positionId = $positionId;
        $this->responsibilities = $responsibilities;
        $this->requirements = $requirements;
        $this->createdAt = new \DateTimeImmutable();
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public static function create(
        PositionId $positionId,
        array $responsibilities,
        array $requirements
    ): self {
        return new self($positionId, $responsibilities, $requirements);
    }
    
    public function addRequiredCompetency(
        CompetencyId $competencyId,
        CompetencyLevel $minimumLevel
    ): void {
        if ($this->hasCompetencyInList($competencyId, $this->requiredCompetencies)) {
            throw new \DomainException('Competency already exists in required list');
        }
        
        $this->requiredCompetencies[] = RequiredCompetency::required(
            $competencyId,
            $minimumLevel
        );
        
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function addDesiredCompetency(
        CompetencyId $competencyId,
        CompetencyLevel $preferredLevel
    ): void {
        if ($this->hasCompetencyInList($competencyId, $this->desiredCompetencies)) {
            throw new \DomainException('Competency already exists in desired list');
        }
        
        $this->desiredCompetencies[] = RequiredCompetency::desired(
            $competencyId,
            $preferredLevel
        );
        
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function removeRequiredCompetency(CompetencyId $competencyId): void
    {
        $this->requiredCompetencies = array_values(
            array_filter(
                $this->requiredCompetencies,
                fn(RequiredCompetency $req) => !$req->getCompetencyId()->equals($competencyId)
            )
        );
        
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function removeDesiredCompetency(CompetencyId $competencyId): void
    {
        $this->desiredCompetencies = array_values(
            array_filter(
                $this->desiredCompetencies,
                fn(RequiredCompetency $req) => !$req->getCompetencyId()->equals($competencyId)
            )
        );
        
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function updateResponsibilities(array $responsibilities): void
    {
        $this->responsibilities = $responsibilities;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function updateRequirements(array $requirements): void
    {
        $this->requirements = $requirements;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function getCompetencyRequirement(CompetencyId $competencyId): ?RequiredCompetency
    {
        foreach ($this->requiredCompetencies as $requirement) {
            if ($requirement->getCompetencyId()->equals($competencyId)) {
                return $requirement;
            }
        }
        
        foreach ($this->desiredCompetencies as $requirement) {
            if ($requirement->getCompetencyId()->equals($competencyId)) {
                return $requirement;
            }
        }
        
        return null;
    }
    
    public function hasCompetencyRequirement(CompetencyId $competencyId): bool
    {
        return $this->hasCompetencyInList($competencyId, $this->requiredCompetencies) ||
               $this->hasCompetencyInList($competencyId, $this->desiredCompetencies);
    }
    
    private function hasCompetencyInList(CompetencyId $competencyId, array $list): bool
    {
        foreach ($list as $requirement) {
            if ($requirement->getCompetencyId()->equals($competencyId)) {
                return true;
            }
        }
        
        return false;
    }
    
    // Getters
    public function getPositionId(): PositionId
    {
        return $this->positionId;
    }
    
    public function getResponsibilities(): array
    {
        return $this->responsibilities;
    }
    
    public function getRequirements(): array
    {
        return $this->requirements;
    }
    
    public function getRequiredCompetencies(): array
    {
        return $this->requiredCompetencies;
    }
    
    public function getDesiredCompetencies(): array
    {
        return $this->desiredCompetencies;
    }
    
    public function getCreatedAt(): \DateTimeImmutable
    {
        return $this->createdAt;
    }
    
    public function getUpdatedAt(): \DateTimeImmutable
    {
        return $this->updatedAt;
    }
} 