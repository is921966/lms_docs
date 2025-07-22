<?php

namespace CompetencyService\Domain\Repositories;

use CompetencyService\Domain\Entities\Assessment;
use CompetencyService\Domain\ValueObjects\AssessmentId;
use CompetencyService\Domain\ValueObjects\CompetencyId;
use CompetencyService\Domain\ValueObjects\UserId;

interface AssessmentRepositoryInterface
{
    public function findById(AssessmentId $id): ?Assessment;
    
    public function findByUser(UserId $userId): array;
    
    public function findByCompetency(CompetencyId $competencyId): array;
    
    public function findByUserAndCompetency(UserId $userId, CompetencyId $competencyId): array;
    
    public function findPendingByAssessor(UserId $assessorId): array;
    
    public function save(Assessment $assessment): void;
    
    public function delete(AssessmentId $id): void;
} 