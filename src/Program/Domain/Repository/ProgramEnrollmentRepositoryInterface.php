<?php

declare(strict_types=1);

namespace Program\Domain\Repository;

use Program\Domain\ProgramEnrollment;
use Program\Domain\ValueObjects\ProgramId;
use User\Domain\ValueObjects\UserId;

interface ProgramEnrollmentRepositoryInterface
{
    public function save(ProgramEnrollment $enrollment): void;
    
    public function findByUserAndProgram(UserId $userId, ProgramId $programId): ?ProgramEnrollment;
    
    /**
     * @return ProgramEnrollment[]
     */
    public function findByUserId(UserId $userId): array;
    
    /**
     * @return ProgramEnrollment[]
     */
    public function findByProgramId(ProgramId $programId): array;
    
    /**
     * @return ProgramEnrollment[]
     */
    public function findActiveByUserId(UserId $userId): array;
    
    public function countByProgramId(ProgramId $programId): int;
} 