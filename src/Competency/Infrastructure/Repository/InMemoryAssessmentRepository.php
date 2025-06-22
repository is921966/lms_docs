<?php

declare(strict_types=1);

namespace App\Competency\Infrastructure\Repository;

use App\Competency\Domain\CompetencyAssessment;
use App\Competency\Domain\Repository\AssessmentRepositoryInterface;
use App\Competency\Domain\ValueObjects\CompetencyId;
use App\User\Domain\ValueObjects\UserId;

class InMemoryAssessmentRepository implements AssessmentRepositoryInterface
{
    /**
     * @var array<string, CompetencyAssessment>
     */
    private array $assessments = [];
    
    public function save(CompetencyAssessment $assessment): void
    {
        $this->assessments[$assessment->getId()] = $assessment;
    }
    
    public function findById(string $id): ?CompetencyAssessment
    {
        return $this->assessments[$id] ?? null;
    }
    
    public function findByUser(UserId $userId): array
    {
        return array_values(
            array_filter(
                $this->assessments,
                fn(CompetencyAssessment $a) => $a->getUserId()->equals($userId)
            )
        );
    }
    
    public function findByUserAndCompetency(UserId $userId, CompetencyId $competencyId): array
    {
        return array_values(
            array_filter(
                $this->assessments,
                fn(CompetencyAssessment $a) => 
                    $a->getUserId()->equals($userId) && 
                    $a->getCompetencyId()->equals($competencyId)
            )
        );
    }
    
    public function findByCompetency(CompetencyId $competencyId): array
    {
        return array_values(
            array_filter(
                $this->assessments,
                fn(CompetencyAssessment $a) => $a->getCompetencyId()->equals($competencyId)
            )
        );
    }
    
    public function findByAssessor(UserId $assessorId): array
    {
        return array_values(
            array_filter(
                $this->assessments,
                fn(CompetencyAssessment $a) => $a->getAssessorId()->equals($assessorId)
            )
        );
    }
    
    public function getHistory(UserId $userId, CompetencyId $competencyId, int $limit = 10): array
    {
        $userCompetencyAssessments = $this->findByUserAndCompetency($userId, $competencyId);
        
        // Sort by date descending
        usort($userCompetencyAssessments, function (CompetencyAssessment $a, CompetencyAssessment $b) {
            return $b->getAssessedAt() <=> $a->getAssessedAt();
        });
        
        return array_slice($userCompetencyAssessments, 0, $limit);
    }
    
    public function getLatest(UserId $userId, CompetencyId $competencyId): ?CompetencyAssessment
    {
        $history = $this->getHistory($userId, $competencyId, 1);
        
        return $history[0] ?? null;
    }
    
    public function findPendingConfirmation(): array
    {
        return array_values(
            array_filter(
                $this->assessments,
                fn(CompetencyAssessment $a) => !$a->isConfirmed()
            )
        );
    }
    
    public function getStatistics(UserId $userId): array
    {
        $userAssessments = $this->findByUser($userId);
        $total = count($userAssessments);
        
        if ($total === 0) {
            return [
                'total' => 0,
                'confirmed' => 0,
                'self_assessments' => 0,
                'average_score' => 0.0
            ];
        }
        
        $confirmed = 0;
        $selfAssessments = 0;
        $totalScore = 0;
        
        foreach ($userAssessments as $assessment) {
            if ($assessment->isConfirmed()) {
                $confirmed++;
            }
            
            if ($assessment->isSelfAssessment()) {
                $selfAssessments++;
            }
            
            $totalScore += $assessment->getScore()->getPercentage();
        }
        
        return [
            'total' => $total,
            'confirmed' => $confirmed,
            'self_assessments' => $selfAssessments,
            'average_score' => round($totalScore / $total, 1)
        ];
    }
    
    public function hasAssessment(UserId $userId, CompetencyId $competencyId): bool
    {
        return count($this->findByUserAndCompetency($userId, $competencyId)) > 0;
    }
} 