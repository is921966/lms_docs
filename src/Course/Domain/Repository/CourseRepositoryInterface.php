<?php

declare(strict_types=1);

namespace App\Course\Domain\Repository;

use App\Course\Domain\Entities\Course;
use App\Course\Domain\ValueObjects\CourseId;
use App\Course\Domain\ValueObjects\CourseCode;

interface CourseRepositoryInterface
{
    public function save(Course $course): void;
    
    public function findById(CourseId $id): ?Course;
    
    public function findByCode(CourseCode $code): ?Course;
    
    /**
     * @return Course[]
     */
    public function findAll(): array;
    
    /**
     * @return Course[]
     */
    public function findPublished(): array;
    
    /**
     * @return Course[]
     */
    public function findByStatus(string $status): array;
    
    public function exists(CourseId $id): bool;
    
    public function delete(Course $course): void;
} 