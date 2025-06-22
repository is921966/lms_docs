<?php

declare(strict_types=1);

namespace App\Competency\Domain\Repository;

use App\Competency\Domain\UserCompetency;
use App\Competency\Domain\ValueObjects\CompetencyId;
use App\Competency\Domain\ValueObjects\CompetencyLevel;
use App\User\Domain\ValueObjects\UserId;

interface UserCompetencyRepositoryInterface
{
    /**
     * Save user competency
     */
    public function save(UserCompetency $userCompetency): void;
    
    /**
     * Find user competency
     */
    public function find(UserId $userId, CompetencyId $competencyId): ?UserCompetency;
    
    /**
     * Find all competencies for a user
     * @return UserCompetency[]
     */
    public function findByUser(UserId $userId): array;
    
    /**
     * Find all users with a specific competency
     * @return UserCompetency[]
     */
    public function findByCompetency(CompetencyId $competencyId): array;
    
    /**
     * Find users with competency at or above level
     * @return UserCompetency[]
     */
    public function findByCompetencyAndLevel(
        CompetencyId $competencyId, 
        CompetencyLevel $minLevel
    ): array;
    
    /**
     * Find user competencies with target levels
     * @return UserCompetency[]
     */
    public function findWithTargets(UserId $userId): array;
    
    /**
     * Find user competencies needing update (not updated in X days)
     * @return UserCompetency[]
     */
    public function findStale(int $daysSinceUpdate): array;
    
    /**
     * Get competency gap report for user
     * @return array{competency_id: string, current_level: int, target_level: int, gap: int}[]
     */
    public function getGapAnalysis(UserId $userId): array;
    
    /**
     * Delete user competency
     */
    public function delete(UserId $userId, CompetencyId $competencyId): void;
    
    /**
     * Check if user has competency
     */
    public function exists(UserId $userId, CompetencyId $competencyId): bool;
} 