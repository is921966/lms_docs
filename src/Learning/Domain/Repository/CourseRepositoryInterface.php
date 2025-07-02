<?php

declare(strict_types=1);

namespace Learning\Domain\Repository;

use Learning\Domain\Course;
use Learning\Domain\ValueObjects\CourseId;
use Learning\Domain\ValueObjects\CourseCode;
use Learning\Domain\ValueObjects\CourseStatus;

interface CourseRepositoryInterface
{
    /**
     * Find course by ID
     */
    public function findById(CourseId $id): ?Course;
    
    /**
     * Find course by code
     */
    public function findByCode(CourseCode $code): ?Course;
    
    /**
     * Find courses by status
     * @return Course[]
     */
    public function findByStatus(CourseStatus $status): array;
    
    /**
     * Find published courses
     * @return Course[]
     */
    public function findPublished(int $limit = 100, int $offset = 0): array;
    
    /**
     * Find courses by tag
     * @return Course[]
     */
    public function findByTag(string $tag): array;
    
    /**
     * Find courses that have specific prerequisite
     * @return Course[]
     */
    public function findByPrerequisite(CourseId $prerequisiteId): array;
    
    /**
     * Search courses by keyword
     * @return Course[]
     */
    public function search(string $keyword): array;
    
    /**
     * Check if course code exists
     */
    public function codeExists(CourseCode $code, ?CourseId $excludeId = null): bool;
    
    /**
     * Save course
     */
    public function save(Course $course): void;
    
    /**
     * Delete course
     */
    public function delete(Course $course): void;
    
    /**
     * Get next available course code
     */
    public function getNextCourseCode(): CourseCode;
} 