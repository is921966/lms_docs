<?php

declare(strict_types=1);

namespace Learning\Domain\Services;

use Learning\Domain\Course;
use Learning\Domain\ValueObjects\CourseId;

interface CourseCacheInterface
{
    public function getCourse(CourseId $courseId): ?Course;
    
    public function setCourse(Course $course): bool;
    
    public function invalidateCourse(CourseId $courseId): bool;
    
    public function invalidateByTag(string $tag): bool;
    
    /**
     * @param Course[] $courses
     */
    public function warmCache(array $courses): int;
    
    public function clear(): bool;
    
    /**
     * @param CourseId[] $courseIds
     * @return Course[]
     */
    public function getMultiple(array $courseIds): array;
    
    public function getStatistics(): array;
} 