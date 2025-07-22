<?php

declare(strict_types=1);

namespace Tests\Unit\Course\Application\Services;

use PHPUnit\Framework\TestCase;
use App\Course\Application\Services\CourseService;
use App\Course\Application\DTO\CourseDTO;
use App\Course\Domain\Repository\CourseRepositoryInterface;
use App\Course\Domain\Repository\EnrollmentRepositoryInterface;
use App\Course\Domain\Entities\Course;
use App\Course\Domain\ValueObjects\CourseId;
use App\Course\Domain\ValueObjects\CourseCode;
use App\Course\Domain\ValueObjects\Duration;
use App\Course\Domain\ValueObjects\Price;
use App\Common\Exceptions\InvalidArgumentException;

class CourseServiceTest extends TestCase
{
    private CourseRepositoryInterface $courseRepository;
    private EnrollmentRepositoryInterface $enrollmentRepository;
    private CourseService $service;
    
    protected function setUp(): void
    {
        $this->courseRepository = $this->createMock(CourseRepositoryInterface::class);
        $this->enrollmentRepository = $this->createMock(EnrollmentRepositoryInterface::class);
        $this->service = new CourseService($this->courseRepository, $this->enrollmentRepository);
    }
    
    public function testCanCreateCourse(): void
    {
        // Given
        $code = 'CS101';
        $title = 'Introduction to Computer Science';
        $description = 'Basic CS course';
        $durationMinutes = 480;
        $priceAmount = 99.99;
        $priceCurrency = 'USD';
        
        $this->courseRepository->expects($this->once())
            ->method('findByCode')
            ->with($this->isInstanceOf(CourseCode::class))
            ->willReturn(null);
            
        $this->courseRepository->expects($this->once())
            ->method('save')
            ->with($this->isInstanceOf(Course::class));
        
        // When
        $dto = $this->service->createCourse(
            $code,
            $title,
            $description,
            $durationMinutes,
            $priceAmount,
            $priceCurrency
        );
        
        // Then
        $this->assertInstanceOf(CourseDTO::class, $dto);
        $this->assertEquals($code, $dto->code);
        $this->assertEquals($title, $dto->title);
        $this->assertEquals($description, $dto->description);
        $this->assertEquals($durationMinutes, $dto->durationMinutes);
        $this->assertEquals($priceAmount, $dto->priceAmount);
        $this->assertEquals($priceCurrency, $dto->priceCurrency);
        $this->assertEquals('draft', $dto->status);
    }
    
    public function testCannotCreateDuplicateCourse(): void
    {
        // Given
        $code = 'CS101';
        $existingCourse = $this->createValidCourse();
        
        $this->courseRepository->expects($this->once())
            ->method('findByCode')
            ->with($this->isInstanceOf(CourseCode::class))
            ->willReturn($existingCourse);
        
        // Then
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Course with code CS101 already exists');
        
        // When
        $this->service->createCourse(
            $code,
            'Title',
            'Description',
            480,
            99.99,
            'USD'
        );
    }
    
    public function testCanGetCourseById(): void
    {
        // Given
        $courseId = CourseId::generate();
        $course = $this->createValidCourse();
        
        $this->courseRepository->expects($this->once())
            ->method('findById')
            ->with($courseId)
            ->willReturn($course);
            
        $this->enrollmentRepository->expects($this->once())
            ->method('countByCourse')
            ->with($courseId)
            ->willReturn(25);
            
        $this->enrollmentRepository->expects($this->once())
            ->method('countCompletedByCourse')
            ->with($courseId)
            ->willReturn(15);
        
        // When
        $dto = $this->service->getCourseById($courseId->value());
        
        // Then
        $this->assertInstanceOf(CourseDTO::class, $dto);
        $this->assertEquals(25, $dto->enrollmentCount);
        $this->assertEquals(15, $dto->completionCount);
    }
    
    public function testThrowsExceptionForNonExistentCourse(): void
    {
        // Given
        $courseId = CourseId::generate();
        
        $this->courseRepository->expects($this->once())
            ->method('findById')
            ->with($this->isInstanceOf(CourseId::class))
            ->willReturn(null);
        
        // Then
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Course not found');
        
        // When
        $this->service->getCourseById($courseId->value());
    }
    
    public function testCanPublishCourse(): void
    {
        // Given
        $courseId = CourseId::generate();
        $course = $this->createValidCourse();
        
        $this->courseRepository->expects($this->once())
            ->method('findById')
            ->with($this->isInstanceOf(CourseId::class))
            ->willReturn($course);
            
        $this->courseRepository->expects($this->once())
            ->method('save')
            ->with($course);
        
        // When
        $this->service->publishCourse($courseId->value());
        
        // Then
        $this->assertEquals('published', $course->status());
    }
    
    private function createValidCourse(): Course
    {
        return new Course(
            CourseId::generate(),
            new CourseCode('CS101'),
            'Introduction to Computer Science',
            'Basic course covering fundamentals of CS',
            new Duration(480),
            new Price(99.99, 'USD')
        );
    }
} 