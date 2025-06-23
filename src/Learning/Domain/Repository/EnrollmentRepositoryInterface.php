<?php

declare(strict_types=1);

namespace App\Learning\Domain\Repository;

use App\Learning\Domain\Enrollment;
use App\Learning\Domain\ValueObjects\EnrollmentId;
use App\Learning\Domain\ValueObjects\EnrollmentStatus;
use App\Learning\Domain\ValueObjects\CourseId;
use App\User\Domain\ValueObjects\UserId;

interface EnrollmentRepositoryInterface
{
    /**
     * Find enrollment by ID
     */
    public function findById(EnrollmentId $id): ?Enrollment;
    
    /**
     * Find user's enrollment for a course
     */
    public function findByUserAndCourse(UserId $userId, CourseId $courseId): ?Enrollment;
    
    /**
     * Find all enrollments for a user
     * @return Enrollment[]
     */
    public function findByUser(UserId $userId, ?EnrollmentStatus $status = null): array;
    
    /**
     * Find all enrollments for a course
     * @return Enrollment[]
     */
    public function findByCourse(CourseId $courseId, ?EnrollmentStatus $status = null): array;
    
    /**
     * Find enrollments by status
     * @return Enrollment[]
     */
    public function findByStatus(EnrollmentStatus $status): array;
    
    /**
     * Find expired enrollments
     * @return Enrollment[]
     */
    public function findExpired(\DateTimeImmutable $date): array;
    
    /**
     * Count enrollments for a course
     */
    public function countByCourse(CourseId $courseId, ?EnrollmentStatus $status = null): int;
    
    /**
     * Check if user is enrolled in course
     */
    public function isUserEnrolled(UserId $userId, CourseId $courseId): bool;
    
    /**
     * Get enrollment statistics for a user
     * @return array{total: int, active: int, completed: int, cancelled: int}
     */
    public function getUserStatistics(UserId $userId): array;
    
    /**
     * Save enrollment
     */
    public function save(Enrollment $enrollment): void;
    
    /**
     * Delete enrollment
     */
    public function delete(Enrollment $enrollment): void;
} 