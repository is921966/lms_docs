<?php

declare(strict_types=1);

namespace Learning\Infrastructure\Persistence\InMemory;

use Learning\Domain\Course;
use Learning\Domain\Repositories\CourseRepositoryInterface;
use Learning\Domain\ValueObjects\CourseId;
use Learning\Domain\ValueObjects\CourseCode;

final class InMemoryCourseRepository implements CourseRepositoryInterface
{
    /**
     * @var array<string, Course>
     */
    private array $courses = [];
    
    /**
     * @var array<string, string>
     */
    private array $codeToIdMap = [];
    
    public function findById(CourseId $id): ?Course
    {
        return $this->courses[(string)$id] ?? null;
    }
    
    public function findByCourseCode(CourseCode $code): ?Course
    {
        $id = $this->codeToIdMap[(string)$code] ?? null;
        
        if ($id === null) {
            return null;
        }
        
        return $this->courses[$id] ?? null;
    }
    
    public function save(Course $course): void
    {
        $id = (string)$course->getId();
        $code = (string)$course->getCode();
        
        // Update code mapping
        $this->codeToIdMap[$code] = $id;
        
        // Save course
        $this->courses[$id] = clone $course;
    }
    
    public function delete(Course $course): void
    {
        $id = (string)$course->getId();
        $code = (string)$course->getCode();
        
        unset($this->courses[$id]);
        unset($this->codeToIdMap[$code]);
    }
    
    /**
     * @return Course[]
     */
    public function findAll(): array
    {
        return array_values($this->courses);
    }
    
    /**
     * @param array $criteria
     * @return Course[]
     */
    public function findBy(array $criteria, int $limit = null, int $offset = null): array
    {
        $results = [];
        
        foreach ($this->courses as $course) {
            if ($this->matchesCriteria($course, $criteria)) {
                $results[] = $course;
            }
        }
        
        // Apply offset
        if ($offset !== null && $offset > 0) {
            $results = array_slice($results, $offset);
        }
        
        // Apply limit
        if ($limit !== null && $limit > 0) {
            $results = array_slice($results, 0, $limit);
        }
        
        return $results;
    }
    
    private function matchesCriteria(Course $course, array $criteria): bool
    {
        foreach ($criteria as $field => $value) {
            if (!$this->matchesField($course, $field, $value)) {
                return false;
            }
        }
        
        return true;
    }
    
    private function matchesField(Course $course, string $field, mixed $value): bool
    {
        // Handle metadata.* fields
        if (str_starts_with($field, 'metadata.')) {
            $metadataKey = substr($field, 9);
            $metadata = $course->getMetadata();
            
            return isset($metadata[$metadataKey]) && $metadata[$metadataKey] === $value;
        }
        
        // Handle direct fields
        return match ($field) {
            'status' => $course->getStatus()->value === $value,
            'instructorId' => $course->getMetadata()['instructorId'] ?? null === $value,
            'title' => $course->getTitle() === $value,
            default => false,
        };
    }
} 