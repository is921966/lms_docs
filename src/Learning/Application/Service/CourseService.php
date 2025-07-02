<?php

declare(strict_types=1);

namespace Learning\Application\Service;

use Common\Exceptions\NotFoundException;
use Learning\Application\DTO\CourseDTO;
use Learning\Domain\Course;
use Learning\Domain\Repository\CourseRepositoryInterface;
use Learning\Domain\ValueObjects\CourseCode;
use Learning\Domain\ValueObjects\CourseId;
use Learning\Domain\ValueObjects\CourseStatus;

class CourseService
{
    public function __construct(
        private readonly CourseRepositoryInterface $courseRepository
    ) {}
    
    public function findById(string $id): ?CourseDTO
    {
        $course = $this->courseRepository->findById(CourseId::fromString($id));
        
        return $course ? CourseDTO::fromEntity($course) : null;
    }
    
    public function create(CourseDTO $dto): CourseDTO
    {
        $course = Course::create(
            id: CourseId::generate(),
            code: CourseCode::fromString($dto->courseCode),
            title: $dto->title,
            description: $dto->description,
            duration: \Learning\Domain\ValueObjects\Duration::fromHours($dto->durationHours)
        );
        
        // Set metadata if provided
        if (!empty($dto->metadata)) {
            foreach ($dto->metadata as $key => $value) {
                $course->setMetadata($key, $value);
            }
        }
        
        $this->courseRepository->save($course);
        
        return CourseDTO::fromEntity($course);
    }
    
    public function update(string $id, array $data): CourseDTO
    {
        $courseId = CourseId::fromString($id);
        $course = $this->courseRepository->findById($courseId);
        
        if (!$course) {
            throw new NotFoundException("Course with ID {$id} not found");
        }
        
        if (isset($data['title']) || isset($data['description'])) {
            $course->updateDetails(
                $data['title'] ?? $course->getTitle(),
                $data['description'] ?? $course->getDescription()
            );
        }
        
        if (isset($data['metadata'])) {
            foreach ($data['metadata'] as $key => $value) {
                $course->setMetadata($key, $value);
            }
        }
        
        $this->courseRepository->save($course);
        
        return CourseDTO::fromEntity($course);
    }
    
    public function findPublished(int $limit = 10, int $offset = 0): array
    {
        $courses = $this->courseRepository->findPublished($limit, $offset);
        
        return array_map(
            fn(Course $course) => CourseDTO::fromEntity($course),
            $courses
        );
    }
    
    public function publish(string $id): bool
    {
        $courseId = CourseId::fromString($id);
        $course = $this->courseRepository->findById($courseId);
        
        if (!$course) {
            throw new NotFoundException("Course with ID {$id} not found");
        }
        
        $course->publish();
        $this->courseRepository->save($course);
        
        return true;
    }
    
    public function archive(string $id): bool
    {
        $courseId = CourseId::fromString($id);
        $course = $this->courseRepository->findById($courseId);
        
        if (!$course) {
            throw new NotFoundException("Course with ID {$id} not found");
        }
        
        $course->archive();
        $this->courseRepository->save($course);
        
        return true;
    }
} 