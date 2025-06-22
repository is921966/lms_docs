<?php

declare(strict_types=1);

namespace App\Competency\Domain\Repository;

use App\Competency\Domain\CompetencyAssessment;
use App\Competency\Domain\ValueObjects\CompetencyId;
use App\User\Domain\ValueObjects\UserId;

interface AssessmentRepositoryInterface
{
    /**
     * Save an assessment
     */
    public function save(CompetencyAssessment $assessment): void;
    
    /**
     * Find assessment by ID
     */
    public function findById(string $id): ?CompetencyAssessment;
    
    /**
     * Find all assessments for a user
     * @return CompetencyAssessment[]
     */
    public function findByUser(UserId $userId): array;
    
    /**
     * Find assessments for a user and specific competency
     * @return CompetencyAssessment[]
     */
    public function findByUserAndCompetency(UserId $userId, CompetencyId $competencyId): array;
    
    /**
     * Find all assessments for a competency
     * @return CompetencyAssessment[]
     */
    public function findByCompetency(CompetencyId $competencyId): array;
    
    /**
     * Find assessments by assessor
     * @return CompetencyAssessment[]
     */
    public function findByAssessor(UserId $assessorId): array;
    
    /**
     * Get assessment history for user and competency
     * @return CompetencyAssessment[]
     */
    public function getHistory(UserId $userId, CompetencyId $competencyId, int $limit = 10): array;
    
    /**
     * Get latest assessment for user and competency
     */
    public function getLatest(UserId $userId, CompetencyId $competencyId): ?CompetencyAssessment;
    
    /**
     * Find assessments that need confirmation
     * @return CompetencyAssessment[]
     */
    public function findPendingConfirmation(): array;
    
    /**
     * Get assessment statistics for a user
     * @return array{total: int, confirmed: int, self_assessments: int, average_score: float}
     */
    public function getStatistics(UserId $userId): array;
    
    /**
     * Check if user has been assessed for competency
     */
    public function hasAssessment(UserId $userId, CompetencyId $competencyId): bool;
} 