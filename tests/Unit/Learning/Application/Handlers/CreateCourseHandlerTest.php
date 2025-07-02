<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Application\Handlers;

use Learning\Application\Commands\CreateCourseCommand;
use Learning\Application\Handlers\CreateCourseHandler;
use Learning\Domain\Course;
use Learning\Domain\Repositories\CourseRepositoryInterface;
use Learning\Domain\Services\EventDispatcherInterface;
use Learning\Domain\Events\CourseCreated;
use Learning\Domain\ValueObjects\CourseId;
use Learning\Domain\ValueObjects\CourseCode;
use Learning\Domain\ValueObjects\Duration;
use PHPUnit\Framework\TestCase;

class CreateCourseHandlerTest extends TestCase
{
    private CourseRepositoryInterface $repository;
    private EventDispatcherInterface $eventDispatcher;
    private CreateCourseHandler $handler;
    
    protected function setUp(): void
    {
        $this->repository = $this->createMock(CourseRepositoryInterface::class);
        $this->eventDispatcher = $this->createMock(EventDispatcherInterface::class);
        $this->handler = new CreateCourseHandler(
            $this->repository,
            $this->eventDispatcher
        );
    }
    
    public function testHandleCreatesCourse(): void
    {
        // Arrange
        $command = new CreateCourseCommand(
            'PHP-101',
            'PHP Basics',
            'Learn PHP from scratch',
            20,
            'instructor-123',
            ['level' => 'beginner']
        );
        
        $this->repository->expects($this->once())
            ->method('findByCourseCode')
            ->with($this->isInstanceOf(CourseCode::class))
            ->willReturn(null);
        
        $this->repository->expects($this->once())
            ->method('save')
            ->with($this->callback(function (Course $course) {
                return $course->getCode()->getValue() === 'PHP-101' &&
                       $course->getTitle() === 'PHP Basics' &&
                       $course->getDescription() === 'Learn PHP from scratch' &&
                       $course->getDuration()->getHours() === 20;
            }));
        
        $this->eventDispatcher->expects($this->once())
            ->method('dispatch')
            ->with($this->isInstanceOf(CourseCreated::class));
        
        // Act
        $courseId = $this->handler->handle($command);
        
        // Assert
        $this->assertInstanceOf(CourseId::class, $courseId);
    }
    
    public function testHandleThrowsExceptionIfCourseCodeExists(): void
    {
        // Arrange
        $command = new CreateCourseCommand(
            'PHP-101',
            'PHP Basics',
            'Description',
            20,
            'instructor-123'
        );
        
        $existingCourse = $this->createMock(Course::class);
        
        $this->repository->expects($this->once())
            ->method('findByCourseCode')
            ->willReturn($existingCourse);
        
        $this->repository->expects($this->never())
            ->method('save');
        
        $this->eventDispatcher->expects($this->never())
            ->method('dispatch');
        
        // Act & Assert
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Course with code PHP-101 already exists');
        
        $this->handler->handle($command);
    }
    
    public function testHandleWithMetadata(): void
    {
        // Arrange
        $command = new CreateCourseCommand(
            'JAVA-201',
            'Advanced Java',
            'Deep dive into Java',
            40,
            'instructor-456',
            [
                'level' => 'advanced',
                'prerequisites' => ['JAVA-101'],
                'tags' => ['programming', 'backend']
            ]
        );
        
        $this->repository->expects($this->once())
            ->method('findByCourseCode')
            ->willReturn(null);
        
        $this->repository->expects($this->once())
            ->method('save')
            ->with($this->callback(function (Course $course) {
                $metadata = $course->getMetadata();
                return $metadata['level'] === 'advanced' &&
                       $metadata['prerequisites'] === ['JAVA-101'] &&
                       $metadata['tags'] === ['programming', 'backend'];
            }));
        
        // Act
        $courseId = $this->handler->handle($command);
        
        // Assert
        $this->assertNotNull($courseId);
    }
} 