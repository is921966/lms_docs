<?php

declare(strict_types=1);

namespace Program\Infrastructure\Persistence;

use Program\Domain\Repository\ProgramEnrollmentRepositoryInterface;
use Program\Domain\ProgramEnrollment;
use Program\Domain\ValueObjects\ProgramId;
use User\Domain\ValueObjects\UserId;

final class InMemoryProgramEnrollmentRepository implements ProgramEnrollmentRepositoryInterface
{
    /**
     * @var array<string, ProgramEnrollment>
     */
    private array $enrollments = [];
    
    public function save(ProgramEnrollment $enrollment): void
    {
        $key = $this->generateKey($enrollment->getUserId(), $enrollment->getProgramId());
        $this->enrollments[$key] = clone $enrollment;
    }
    
    public function findByUserAndProgram(UserId $userId, ProgramId $programId): ?ProgramEnrollment
    {
        $key = $this->generateKey($userId, $programId);
        
        if (!isset($this->enrollments[$key])) {
            return null;
        }
        
        return clone $this->enrollments[$key];
    }
    
    /**
     * @return ProgramEnrollment[]
     */
    public function findByUserId(UserId $userId): array
    {
        $results = [];
        
        foreach ($this->enrollments as $enrollment) {
            if ($enrollment->getUserId()->equals($userId)) {
                $results[] = clone $enrollment;
            }
        }
        
        return $results;
    }
    
    /**
     * @return ProgramEnrollment[]
     */
    public function findByProgramId(ProgramId $programId): array
    {
        $results = [];
        
        foreach ($this->enrollments as $enrollment) {
            if ($enrollment->getProgramId()->equals($programId)) {
                $results[] = clone $enrollment;
            }
        }
        
        return $results;
    }
    
    /**
     * @return ProgramEnrollment[]
     */
    public function findActiveByUserId(UserId $userId): array
    {
        $results = [];
        
        foreach ($this->enrollments as $enrollment) {
            if ($enrollment->getUserId()->equals($userId) && 
                in_array($enrollment->getStatus(), ['enrolled', 'in_progress'])) {
                $results[] = clone $enrollment;
            }
        }
        
        return $results;
    }
    
    public function countByProgramId(ProgramId $programId): int
    {
        return count($this->findByProgramId($programId));
    }
    
    // Additional helper methods
    
    /**
     * @return ProgramEnrollment[]
     */
    public function findByUser(UserId $userId): array
    {
        return $this->findByUserId($userId);
    }
    
    /**
     * @return ProgramEnrollment[]
     */
    public function findByProgram(ProgramId $programId): array
    {
        return $this->findByProgramId($programId);
    }
    
    public function countByProgram(ProgramId $programId): int
    {
        return $this->countByProgramId($programId);
    }
    
    /**
     * @return ProgramEnrollment[]
     */
    public function findActive(): array
    {
        $results = [];
        
        foreach ($this->enrollments as $enrollment) {
            if (in_array($enrollment->getStatus(), ['enrolled', 'in_progress'])) {
                $results[] = clone $enrollment;
            }
        }
        
        return $results;
    }
    
    private function generateKey(UserId $userId, ProgramId $programId): string
    {
        return $userId->getValue() . '_' . $programId->getValue();
    }
} 