<?php

declare(strict_types=1);

namespace App\Learning\Domain\Repository;

use App\Learning\Domain\Progress;
use App\Learning\Domain\ValueObjects\ProgressId;
use App\Learning\Domain\ValueObjects\EnrollmentId;
use App\Learning\Domain\ValueObjects\LessonId;
use App\Learning\Domain\ValueObjects\ModuleId;

interface ProgressRepositoryInterface
{
    /**
     * Find progress by ID
     */
    public function findById(ProgressId $id): ?Progress;
    
    /**
     * Find progress for enrollment and lesson
     */
    public function findByEnrollmentAndLesson(EnrollmentId $enrollmentId, LessonId $lessonId): ?Progress;
    
    /**
     * Find all progress for enrollment
     * @return Progress[]
     */
    public function findByEnrollment(EnrollmentId $enrollmentId): array;
    
    /**
     * Find progress for enrollment and module
     * @return Progress[]
     */
    public function findByEnrollmentAndModule(EnrollmentId $enrollmentId, ModuleId $moduleId): array;
    
    /**
     * Calculate completion percentage for enrollment
     */
    public function calculateEnrollmentProgress(EnrollmentId $enrollmentId): float;
    
    /**
     * Calculate completion percentage for module
     */
    public function calculateModuleProgress(EnrollmentId $enrollmentId, ModuleId $moduleId): float;
    
    /**
     * Get total time spent on enrollment
     */
    public function getTotalTimeSpent(EnrollmentId $enrollmentId): int;
    
    /**
     * Get highest scores for enrollment
     * @return array<string, float>
     */
    public function getHighestScores(EnrollmentId $enrollmentId): array;
    
    /**
     * Save progress
     */
    public function save(Progress $progress): void;
    
    /**
     * Delete progress
     */
    public function delete(Progress $progress): void;
    
    /**
     * Delete all progress for enrollment
     */
    public function deleteByEnrollment(EnrollmentId $enrollmentId): void;
} 