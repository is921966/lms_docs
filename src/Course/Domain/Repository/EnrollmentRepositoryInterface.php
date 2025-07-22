<?php

declare(strict_types=1);

namespace App\Course\Domain\Repository;

use App\Course\Domain\Entities\Enrollment;
use App\Course\Domain\ValueObjects\CourseId;

interface EnrollmentRepositoryInterface
{
    public function save(Enrollment $enrollment): void;
    
    public function findById(string $id): ?Enrollment;
    
    public function findByUserAndCourse(string $userId, CourseId $courseId): ?Enrollment;
    
    /**
     * @return Enrollment[]
     */
    public function findByUser(string $userId): array;
    
    /**
     * @return Enrollment[]
     */
    public function findByCourse(CourseId $courseId): array;
    
    /**
     * @return Enrollment[]
     */
    public function findActiveByUser(string $userId): array;
    
    /**
     * @return Enrollment[]
     */
    public function findCompletedByUser(string $userId): array;
    
    public function countByCourse(CourseId $courseId): int;
    
    public function countCompletedByCourse(CourseId $courseId): int;
    
    public function exists(string $userId, CourseId $courseId): bool;
} 