<?php

declare(strict_types=1);

namespace Learning\Domain\Repositories;

use Learning\Domain\Course;
use Learning\Domain\ValueObjects\CourseId;
use Learning\Domain\ValueObjects\CourseCode;

interface CourseRepositoryInterface
{
    public function findById(CourseId $id): ?Course;
    
    public function findByCourseCode(CourseCode $code): ?Course;
    
    public function save(Course $course): void;
    
    public function delete(Course $course): void;
    
    /**
     * @return Course[]
     */
    public function findAll(): array;
    
    /**
     * @param array $criteria
     * @return Course[]
     */
    public function findBy(array $criteria, int $limit = null, int $offset = null): array;
} 