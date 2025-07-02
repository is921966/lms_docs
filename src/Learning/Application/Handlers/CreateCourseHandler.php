<?php

declare(strict_types=1);

namespace Learning\Application\Handlers;

use Learning\Application\Commands\CreateCourseCommand;
use Learning\Domain\Course;
use Learning\Domain\Events\CourseCreated;
use Learning\Domain\Repositories\CourseRepositoryInterface;
use Learning\Domain\Services\EventDispatcherInterface;
use Learning\Domain\ValueObjects\CourseId;
use Learning\Domain\ValueObjects\CourseCode;
use Learning\Domain\ValueObjects\Duration;
use Learning\Domain\ValueObjects\CourseStatus;
use DomainException;

final class CreateCourseHandler
{
    public function __construct(
        private readonly CourseRepositoryInterface $repository,
        private readonly EventDispatcherInterface $eventDispatcher
    ) {
    }
    
    public function handle(CreateCourseCommand $command): CourseId
    {
        // Check if course code already exists
        $courseCode = CourseCode::fromString($command->getCourseCode());
        
        $existingCourse = $this->repository->findByCourseCode($courseCode);
        if ($existingCourse !== null) {
            throw new DomainException(
                sprintf('Course with code %s already exists', $command->getCourseCode())
            );
        }
        
        // Create new course
        $course = Course::create(
            id: CourseId::generate(),
            code: $courseCode,
            title: $command->getTitle(),
            description: $command->getDescription(),
            duration: Duration::fromHours($command->getDurationHours())
        );
        
        // Set metadata if provided
        $metadata = $command->getMetadata();
        if (!empty($metadata)) {
            foreach ($metadata as $key => $value) {
                $course->setMetadata($key, $value);
            }
        }
        
        // Save course
        $this->repository->save($course);
        
        // Dispatch event
        $event = CourseCreated::create(
            $course->getId(),
            $course->getCode(),
            $course->getTitle(),
            $course->getDescription(),
            $course->getStatus()
        );
        
        $this->eventDispatcher->dispatch($event);
        
        return $course->getId();
    }
} 