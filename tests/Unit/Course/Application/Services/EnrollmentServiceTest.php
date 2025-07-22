<?php

declare(strict_types=1);

namespace Tests\Unit\Course\Application\Services;

use PHPUnit\Framework\TestCase;
use App\Course\Application\Services\EnrollmentService;
use App\Course\Application\DTO\EnrollmentDTO;
use App\Course\Domain\Repository\CourseRepositoryInterface;
use App\Course\Domain\Repository\EnrollmentRepositoryInterface;
use App\Course\Domain\Entities\Course;
use App\Course\Domain\Entities\Enrollment;
use App\Course\Domain\ValueObjects\CourseId;
use App\Course\Domain\ValueObjects\CourseCode;
use App\Course\Domain\ValueObjects\Duration;
use App\Course\Domain\ValueObjects\Price;
use App\Common\Exceptions\InvalidArgumentException;

class EnrollmentServiceTest extends TestCase
{
    private CourseRepositoryInterface $courseRepository;
    private EnrollmentRepositoryInterface $enrollmentRepository;
    private EnrollmentService $service;
    
    protected function setUp(): void
    {
        $this->courseRepository = $this->createMock(CourseRepositoryInterface::class);
        $this->enrollmentRepository = $this->createMock(EnrollmentRepositoryInterface::class);
        $this->service = new EnrollmentService($this->courseRepository, $this->enrollmentRepository);
    }
    
    public function testCanEnrollUser(): void
    {
        // Given
        $courseId = CourseId::generate();
        $userId = 'USR-123';
        $course = $this->createPublishedCourse($courseId);
        
        $this->courseRepository->expects($this->once())
            ->method('findById')
            ->with($courseId)
            ->willReturn($course);
            
        $this->enrollmentRepository->expects($this->once())
            ->method('exists')
            ->with($userId, $courseId)
            ->willReturn(false);
            
        $this->enrollmentRepository->expects($this->once())
            ->method('save')
            ->with($this->isInstanceOf(Enrollment::class));
        
        // When
        $dto = $this->service->enrollUser($userId, $courseId->value());
        
        // Then
        $this->assertInstanceOf(EnrollmentDTO::class, $dto);
        $this->assertEquals($userId, $dto->userId);
        $this->assertEquals($courseId->value(), $dto->courseId);
        $this->assertEquals('active', $dto->status);
        $this->assertEquals(0, $dto->progressPercent);
    }
    
    public function testCannotEnrollInNonExistentCourse(): void
    {
        // Given
        $courseId = CourseId::generate();
        $userId = 'USR-123';
        
        $this->courseRepository->expects($this->once())
            ->method('findById')
            ->with($this->isInstanceOf(CourseId::class))
            ->willReturn(null);
        
        // Then
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Course not found');
        
        // When
        $this->service->enrollUser($userId, $courseId->value());
    }
    
    public function testCannotEnrollInUnpublishedCourse(): void
    {
        // Given
        $courseId = CourseId::generate();
        $userId = 'USR-123';
        $course = $this->createDraftCourse($courseId); // Not published
        
        $this->courseRepository->expects($this->once())
            ->method('findById')
            ->with($courseId)
            ->willReturn($course);
        
        // Then
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Can only enroll in published courses');
        
        // When
        $this->service->enrollUser($userId, $courseId->value());
    }
    
    public function testCannotEnrollTwice(): void
    {
        // Given
        $courseId = CourseId::generate();
        $userId = 'USR-123';
        $course = $this->createPublishedCourse($courseId);
        
        $this->courseRepository->expects($this->once())
            ->method('findById')
            ->with($courseId)
            ->willReturn($course);
            
        $this->enrollmentRepository->expects($this->once())
            ->method('exists')
            ->with($userId, $courseId)
            ->willReturn(true);
        
        // Then
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('User is already enrolled in this course');
        
        // When
        $this->service->enrollUser($userId, $courseId->value());
    }
    
    public function testCanUpdateProgress(): void
    {
        // Given
        $courseId = CourseId::generate();
        $userId = 'USR-123';
        $enrollment = new Enrollment($courseId, $userId);
        
        $this->enrollmentRepository->expects($this->once())
            ->method('findByUserAndCourse')
            ->with($userId, $courseId)
            ->willReturn($enrollment);
            
        $this->enrollmentRepository->expects($this->once())
            ->method('save')
            ->with($enrollment);
        
        // When
        $this->service->updateProgress($userId, $courseId->value(), 75);
        
        // Then
        $this->assertEquals(75, $enrollment->progressPercent());
    }
    
    public function testCanCompleteCourse(): void
    {
        // Given
        $courseId = CourseId::generate();
        $userId = 'USR-123';
        $enrollment = new Enrollment($courseId, $userId);
        $enrollment->updateProgress(100);
        
        $this->enrollmentRepository->expects($this->once())
            ->method('findByUserAndCourse')
            ->with($userId, $courseId)
            ->willReturn($enrollment);
            
        $this->enrollmentRepository->expects($this->once())
            ->method('save')
            ->with($enrollment);
        
        // When
        $this->service->completeCourse($userId, $courseId->value());
        
        // Then
        $this->assertEquals('completed', $enrollment->status());
    }
    
    private function createPublishedCourse(CourseId $courseId): Course
    {
        $course = new Course(
            $courseId,
            new CourseCode('CS101'),
            'Test Course',
            'Test Description',
            new Duration(480),
            new Price(99.99, 'USD')
        );
        $course->publish();
        return $course;
    }
    
    private function createDraftCourse(CourseId $courseId): Course
    {
        return new Course(
            $courseId,
            new CourseCode('CS101'),
            'Test Course',
            'Test Description',
            new Duration(480),
            new Price(99.99, 'USD')
        );
    }
} 