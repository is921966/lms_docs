<?php

namespace CompetencyService\Domain\Entities;

use CompetencyService\Domain\Common\AggregateRoot;
use CompetencyService\Domain\ValueObjects\MatrixId;
use CompetencyService\Domain\ValueObjects\CompetencyId;
use CompetencyService\Domain\ValueObjects\MatrixRequirement;

class CompetencyMatrix extends AggregateRoot
{
    private MatrixId $id;
    private string $positionId;
    private string $name;
    private array $requirements = [];
    private bool $isActive = true;
    private \DateTimeImmutable $createdAt;
    private ?\DateTimeImmutable $updatedAt = null;
    
    public function __construct(MatrixId $id, string $positionId, string $name)
    {
        $this->id = $id;
        $this->positionId = $positionId;
        $this->name = $name;
        $this->createdAt = new \DateTimeImmutable();
    }
    
    public function addRequirement(MatrixRequirement $requirement): void
    {
        $this->requirements[] = $requirement;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function removeRequirement(CompetencyId $competencyId): void
    {
        $this->requirements = array_filter(
            $this->requirements,
            fn(MatrixRequirement $req) => !$req->getCompetencyId()->equals($competencyId)
        );
        $this->requirements = array_values($this->requirements);
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function getCoreCompetencies(): array
    {
        return array_filter(
            $this->requirements,
            fn(MatrixRequirement $req) => $req->isCore()
        );
    }
    
    public function getNiceToHaveCompetencies(): array
    {
        return array_filter(
            $this->requirements,
            fn(MatrixRequirement $req) => $req->isNiceToHave()
        );
    }
    
    public function getOptionalCompetencies(): array
    {
        return array_filter(
            $this->requirements,
            fn(MatrixRequirement $req) => $req->isOptional()
        );
    }
    
    public function calculateCompleteness(array $userAssessments): array
    {
        $coreReqs = $this->getCoreCompetencies();
        $niceToHaveReqs = $this->getNiceToHaveCompetencies();
        $allReqs = $this->requirements;
        
        $coreMet = 0;
        $niceToHaveMet = 0;
        $totalMet = 0;
        
        // Convert assessments to lookup map
        $assessmentMap = [];
        foreach ($userAssessments as $assessment) {
            $assessmentMap[$assessment['competency_id']] = $assessment['level'];
        }
        
        // Check core requirements
        foreach ($coreReqs as $req) {
            $competencyId = $req->getCompetencyId()->toString();
            if (isset($assessmentMap[$competencyId]) && 
                $req->isSatisfiedBy($assessmentMap[$competencyId])) {
                $coreMet++;
                $totalMet++;
            }
        }
        
        // Check nice-to-have requirements
        foreach ($niceToHaveReqs as $req) {
            $competencyId = $req->getCompetencyId()->toString();
            if (isset($assessmentMap[$competencyId]) && 
                $req->isSatisfiedBy($assessmentMap[$competencyId])) {
                $niceToHaveMet++;
                $totalMet++;
            }
        }
        
        $corePercentage = count($coreReqs) > 0 
            ? round(($coreMet / count($coreReqs)) * 100, 2) 
            : 100.0;
            
        $niceToHavePercentage = count($niceToHaveReqs) > 0 
            ? round(($niceToHaveMet / count($niceToHaveReqs)) * 100, 2) 
            : 100.0;
            
        $overallPercentage = count($allReqs) > 0 
            ? round(($totalMet / count($allReqs)) * 100, 2) 
            : 100.0;
        
        return [
            'core_percentage' => $corePercentage,
            'nice_to_have_percentage' => $niceToHavePercentage,
            'overall_percentage' => $overallPercentage,
            'core_met' => $coreMet,
            'core_total' => count($coreReqs),
            'nice_to_have_met' => $niceToHaveMet,
            'nice_to_have_total' => count($niceToHaveReqs),
            'total_met' => $totalMet,
            'total_requirements' => count($allReqs)
        ];
    }
    
    public function deactivate(): void
    {
        $this->isActive = false;
    }
    
    public function activate(): void
    {
        $this->isActive = true;
    }
    
    // Getters
    public function getId(): MatrixId
    {
        return $this->id;
    }
    
    public function getPositionId(): string
    {
        return $this->positionId;
    }
    
    public function getName(): string
    {
        return $this->name;
    }
    
    public function getRequirements(): array
    {
        return $this->requirements;
    }
    
    public function isActive(): bool
    {
        return $this->isActive;
    }
    
    public function toArray(): array
    {
        return [
            'id' => $this->id->toString(),
            'position_id' => $this->positionId,
            'name' => $this->name,
            'requirements' => array_map(fn($req) => $req->toArray(), $this->requirements),
            'is_active' => $this->isActive,
            'created_at' => $this->createdAt->format('Y-m-d H:i:s'),
            'updated_at' => $this->updatedAt?->format('Y-m-d H:i:s')
        ];
    }
} 