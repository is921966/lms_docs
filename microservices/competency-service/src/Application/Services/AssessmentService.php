<?php

namespace CompetencyService\Application\Services;

use CompetencyService\Application\DTOs\CreateAssessmentDTO;
use CompetencyService\Application\DTOs\CompleteAssessmentDTO;
use CompetencyService\Application\DTOs\AssessmentDTO;
use CompetencyService\Domain\Repositories\AssessmentRepositoryInterface;
use CompetencyService\Domain\Repositories\CompetencyRepositoryInterface;
use CompetencyService\Domain\Entities\Assessment;
use CompetencyService\Domain\ValueObjects\AssessmentId;
use CompetencyService\Domain\ValueObjects\CompetencyId;
use CompetencyService\Domain\ValueObjects\UserId;
use CompetencyService\Domain\ValueObjects\AssessmentScore;
use DomainException;

class AssessmentService
{
    public function __construct(
        private readonly AssessmentRepositoryInterface $assessmentRepository,
        private readonly CompetencyRepositoryInterface $competencyRepository
    ) {}
    
    public function createAssessment(CreateAssessmentDTO $dto): AssessmentDTO
    {
        // Verify competency exists
        $competencyId = CompetencyId::fromString($dto->competencyId);
        $competency = $this->competencyRepository->findById($competencyId);
        
        if ($competency === null) {
            throw new DomainException("Competency with id {$dto->competencyId} not found");
        }
        
        // Create assessment
        $assessment = new Assessment(
            AssessmentId::generate(),
            $competencyId,
            new UserId($dto->userId),
            new UserId($dto->assessorId)
        );
        
        // Save
        $this->assessmentRepository->save($assessment);
        
        return AssessmentDTO::fromEntity($assessment);
    }
    
    public function completeAssessment(CompleteAssessmentDTO $dto): AssessmentDTO
    {
        $assessment = $this->assessmentRepository->findById(
            AssessmentId::fromString($dto->assessmentId)
        );
        
        if ($assessment === null) {
            throw new DomainException("Assessment with id {$dto->assessmentId} not found");
        }
        
        $score = new AssessmentScore(
            $dto->level,
            $dto->feedback,
            $dto->recommendations
        );
        
        $assessment->complete($score);
        
        $this->assessmentRepository->save($assessment);
        
        return AssessmentDTO::fromEntity($assessment);
    }
    
    public function cancelAssessment(string $assessmentId, string $reason): AssessmentDTO
    {
        $assessment = $this->assessmentRepository->findById(
            AssessmentId::fromString($assessmentId)
        );
        
        if ($assessment === null) {
            throw new DomainException("Assessment with id {$assessmentId} not found");
        }
        
        $assessment->cancel($reason);
        
        $this->assessmentRepository->save($assessment);
        
        return AssessmentDTO::fromEntity($assessment);
    }
    
    public function getAssessmentById(string $id): AssessmentDTO
    {
        $assessment = $this->assessmentRepository->findById(
            AssessmentId::fromString($id)
        );
        
        if ($assessment === null) {
            throw new DomainException("Assessment with id {$id} not found");
        }
        
        return AssessmentDTO::fromEntity($assessment);
    }
    
    public function getUserAssessments(string $userId): array
    {
        $assessments = $this->assessmentRepository->findByUser(
            new UserId($userId)
        );
        
        return array_map(
            fn(Assessment $assessment) => AssessmentDTO::fromEntity($assessment),
            $assessments
        );
    }
    
    public function getCompetencyAssessments(string $competencyId): array
    {
        $assessments = $this->assessmentRepository->findByCompetency(
            CompetencyId::fromString($competencyId)
        );
        
        return array_map(
            fn(Assessment $assessment) => AssessmentDTO::fromEntity($assessment),
            $assessments
        );
    }
    
    public function getPendingAssessmentsForAssessor(string $assessorId): array
    {
        $assessments = $this->assessmentRepository->findPendingByAssessor(
            new UserId($assessorId)
        );
        
        return array_map(
            fn(Assessment $assessment) => AssessmentDTO::fromEntity($assessment),
            $assessments
        );
    }
    
    public function getUserCompetencyProgress(string $userId): array
    {
        $assessments = $this->assessmentRepository->findByUser(
            new UserId($userId)
        );
        
        $progress = [];
        
        foreach ($assessments as $assessment) {
            if ($assessment->getStatus() === 'completed' && $assessment->getScore() !== null) {
                $competencyId = $assessment->getCompetencyId()->toString();
                
                // Keep track of highest level achieved per competency
                if (!isset($progress[$competencyId]) || 
                    $assessment->getScore()->getLevel() > $progress[$competencyId]['level']) {
                    
                    $competency = $this->competencyRepository->findById($assessment->getCompetencyId());
                    
                    $progress[$competencyId] = [
                        'competency_id' => $competencyId,
                        'competency_name' => $competency?->getName() ?? 'Unknown',
                        'competency_code' => $competency?->getCode()->getValue() ?? 'Unknown',
                        'level' => $assessment->getScore()->getLevel(),
                        'last_assessment_date' => $assessment->getCompletedAt()?->format('Y-m-d H:i:s')
                    ];
                }
            }
        }
        
        return array_values($progress);
    }
} 