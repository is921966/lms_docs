<?php

declare(strict_types=1);

namespace App\Learning\Application\Service;

use App\Common\Exceptions\NotFoundException;
use App\Learning\Application\DTO\CourseDTO;
use App\Learning\Domain\Course;
use App\Learning\Domain\Repository\CourseRepositoryInterface;
use App\Learning\Domain\ValueObjects\CourseCode;
use App\Learning\Domain\ValueObjects\CourseId;
use App\Learning\Domain\ValueObjects\CourseType;
use App\Learning\Domain\ValueObjects\CourseStatus;

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
            code: CourseCode::fromString($dto->code),
            title: $dto->title,
            description: $dto->description,
            type: CourseType::from(strtoupper($dto->type)),
            durationHours: $dto->durationHours
        );
        
        if ($dto->tags) {
            foreach ($dto->tags as $tag) {
                $course->addTag($tag);
            }
        }
        
        if ($dto->prerequisites) {
            foreach ($dto->prerequisites as $prerequisiteId) {
                $course->addPrerequisite(CourseId::fromString($prerequisiteId));
            }
        }
        
        if ($dto->imageUrl) {
            $course->setImageUrl($dto->imageUrl);
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
        
        if (isset($data['title']) || isset($data['description']) || isset($data['durationHours'])) {
            $course->updateBasicInfo(
                $data['title'] ?? $course->getTitle(),
                $data['description'] ?? $course->getDescription(),
                $data['durationHours'] ?? $course->getDurationHours()
            );
        }
        
        if (isset($data['imageUrl'])) {
            $course->setImageUrl($data['imageUrl']);
        }
        
        if (isset($data['tags'])) {
            // Clear existing tags and add new ones
            foreach ($course->getTags() as $tag) {
                $course->removeTag($tag);
            }
            foreach ($data['tags'] as $tag) {
                $course->addTag($tag);
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