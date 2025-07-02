<?php

declare(strict_types=1);

namespace Learning\Infrastructure\Repository;

use Learning\Domain\Repository\CourseRepositoryInterface;
use Learning\Domain\Course;
use Learning\Domain\ValueObjects\CourseId;
use Learning\Domain\ValueObjects\CourseCode;
use Learning\Domain\ValueObjects\CourseStatus;

class InMemoryCourseRepository implements CourseRepositoryInterface
{
    /** @var array<string, Course> */
    private array $courses = [];
    
    public function save(Course $course): void
    {
        $this->courses[$course->getId()->getValue()] = $course;
    }
    
    public function findById(CourseId $id): ?Course
    {
        return $this->courses[$id->getValue()] ?? null;
    }
    
    public function findByCode(CourseCode $code): ?Course
    {
        foreach ($this->courses as $course) {
            if ($course->getCode()->getValue() === $code->getValue()) {
                return $course;
            }
        }
        
        return null;
    }
    
    public function findByStatus(CourseStatus $status): array
    {
        return array_values(array_filter(
            $this->courses,
            fn(Course $course) => $course->getStatus()->getValue() === $status->getValue()
        ));
    }
    
    public function findPublished(int $limit = 100, int $offset = 0): array
    {
        $published = $this->findByStatus(CourseStatus::published());
        
        return array_slice($published, $offset, $limit);
    }
    
    public function findByTag(string $tag): array
    {
        return array_values(array_filter(
            $this->courses,
            fn(Course $course) => in_array($tag, $course->getMetadata()['tags'] ?? [], true)
        ));
    }
    
    public function findByPrerequisite(CourseId $prerequisiteId): array
    {
        return array_values(array_filter(
            $this->courses,
            function (Course $course) use ($prerequisiteId) {
                foreach ($course->getPrerequisites() as $prereq) {
                    if ($prereq->getValue() === $prerequisiteId->getValue()) {
                        return true;
                    }
                }
                return false;
            }
        ));
    }
    
    public function search(string $keyword): array
    {
        $keyword = strtolower($keyword);
        
        return array_values(array_filter(
            $this->courses,
            function (Course $course) use ($keyword) {
                return str_contains(strtolower($course->getTitle()), $keyword) ||
                       str_contains(strtolower($course->getDescription()), $keyword) ||
                       str_contains(strtolower($course->getCode()->getValue()), $keyword);
            }
        ));
    }
    
    public function codeExists(CourseCode $code, ?CourseId $excludeId = null): bool
    {
        foreach ($this->courses as $course) {
            if ($course->getCode()->getValue() === $code->getValue()) {
                if ($excludeId === null || $course->getId()->getValue() !== $excludeId->getValue()) {
                    return true;
                }
            }
        }
        
        return false;
    }
    
    public function delete(Course $course): void
    {
        unset($this->courses[$course->getId()->getValue()]);
    }
    
    public function getNextCourseCode(): CourseCode
    {
        $maxNumber = 0;
        
        foreach ($this->courses as $course) {
            $code = $course->getCode()->getValue();
            if (preg_match('/CRS-(\d+)/', $code, $matches)) {
                $number = (int) $matches[1];
                if ($number > $maxNumber) {
                    $maxNumber = $number;
                }
            }
        }
        
        return CourseCode::fromString(sprintf('CRS-%03d', $maxNumber + 1));
    }
    
    public function findAll(): array
    {
        return array_values($this->courses);
    }
} 