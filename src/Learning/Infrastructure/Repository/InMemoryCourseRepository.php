<?php

declare(strict_types=1);

namespace App\Learning\Infrastructure\Repository;

use App\Learning\Domain\Repository\CourseRepositoryInterface;
use App\Learning\Domain\Course;
use App\Learning\Domain\ValueObjects\CourseId;
use App\Learning\Domain\ValueObjects\CourseCode;
use App\Learning\Domain\ValueObjects\CourseStatus;

class InMemoryCourseRepository implements CourseRepositoryInterface
{
    /** @var array<string, Course> */
    private array $courses = [];
    
    public function save(Course $course): void
    {
        $this->courses[$course->getId()->toString()] = $course;
    }
    
    public function findById(CourseId $id): ?Course
    {
        return $this->courses[$id->toString()] ?? null;
    }
    
    public function findByCode(CourseCode $code): ?Course
    {
        foreach ($this->courses as $course) {
            if ($course->getCode()->toString() === $code->toString()) {
                return $course;
            }
        }
        
        return null;
    }
    
    public function findByStatus(CourseStatus $status): array
    {
        return array_values(array_filter(
            $this->courses,
            fn(Course $course) => $course->getStatus()->value === $status->value
        ));
    }
    
    public function findPublished(int $limit = 100, int $offset = 0): array
    {
        $published = $this->findByStatus(CourseStatus::PUBLISHED);
        
        return array_slice($published, $offset, $limit);
    }
    
    public function findByTag(string $tag): array
    {
        return array_values(array_filter(
            $this->courses,
            fn(Course $course) => in_array($tag, $course->getTags(), true)
        ));
    }
    
    public function findByPrerequisite(CourseId $prerequisiteId): array
    {
        return array_values(array_filter(
            $this->courses,
            function (Course $course) use ($prerequisiteId) {
                foreach ($course->getPrerequisites() as $prereq) {
                    if ($prereq->toString() === $prerequisiteId->toString()) {
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
                       str_contains(strtolower($course->getCode()->toString()), $keyword);
            }
        ));
    }
    
    public function codeExists(CourseCode $code, ?CourseId $excludeId = null): bool
    {
        foreach ($this->courses as $course) {
            if ($course->getCode()->toString() === $code->toString()) {
                if ($excludeId === null || $course->getId()->toString() !== $excludeId->toString()) {
                    return true;
                }
            }
        }
        
        return false;
    }
    
    public function delete(Course $course): void
    {
        unset($this->courses[$course->getId()->toString()]);
    }
    
    public function getNextCourseCode(): CourseCode
    {
        $maxNumber = 0;
        
        foreach ($this->courses as $course) {
            $code = $course->getCode()->toString();
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