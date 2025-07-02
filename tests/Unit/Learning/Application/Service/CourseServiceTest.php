<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Application\Service;

use Learning\Application\Service\CourseService;
use Learning\Application\DTO\CourseDTO;
use Learning\Domain\Course;
use Learning\Domain\Repository\CourseRepositoryInterface;
use Learning\Domain\ValueObjects\CourseId;
use Learning\Domain\ValueObjects\CourseCode;
use Learning\Domain\ValueObjects\Duration;
use PHPUnit\Framework\TestCase;
use PHPUnit\Framework\MockObject\MockObject;

class CourseServiceTest extends TestCase
{
    private CourseRepositoryInterface&MockObject $courseRepository;
    private CourseService $service;
    
    protected function setUp(): void
    {
        $this->courseRepository = $this->createMock(CourseRepositoryInterface::class);
        $this->service = new CourseService($this->courseRepository);
    }
    
    public function testCanFindCourseById(): void
    {
        $courseId = CourseId::generate();
        $course = $this->createTestCourse();
        
        $this->courseRepository
            ->expects($this->once())
            ->method('findById')
            ->with($courseId)
            ->willReturn($course);
        
        $dto = $this->service->findById($courseId->getValue());
        
        $this->assertNotNull($dto);
        $this->assertInstanceOf(CourseDTO::class, $dto);
        $this->assertEquals($course->getTitle(), $dto->title);
    }
    
    public function testReturnsNullWhenCourseNotFound(): void
    {
        $courseId = CourseId::generate();
        
        $this->courseRepository
            ->expects($this->once())
            ->method('findById')
            ->with($courseId)
            ->willReturn(null);
        
        $dto = $this->service->findById($courseId->getValue());
        
        $this->assertNull($dto);
    }
    
    public function testCanCreateNewCourse(): void
    {
        $dto = new CourseDTO(
            id: '',
            courseCode: 'CRS-999',
            title: 'New Course',
            description: 'New Description',
            durationHours: 40,
            instructorId: 'instructor-123',
            status: 'draft',
            metadata: ['tags' => ['tag1', 'tag2']],
            createdAt: null,
            updatedAt: null
        );
        
        $this->courseRepository
            ->expects($this->once())
            ->method('save')
            ->with($this->callback(function (Course $course) use ($dto) {
                return $course->getCode()->getValue() === $dto->courseCode
                    && $course->getTitle() === $dto->title;
            }));
        
        $resultDto = $this->service->create($dto);
        
        $this->assertInstanceOf(CourseDTO::class, $resultDto);
        $this->assertNotNull($resultDto->id);
        $this->assertEquals($dto->title, $resultDto->title);
    }
    
    public function testCanUpdateCourse(): void
    {
        $courseId = CourseId::generate();
        $course = $this->createTestCourse();
        
        // Update DTO would be created from course
        
        $this->courseRepository
            ->expects($this->once())
            ->method('findById')
            ->with($courseId)
            ->willReturn($course);
        
        $this->courseRepository
            ->expects($this->once())
            ->method('save')
            ->with($course);
        
        $result = $this->service->update($courseId->getValue(), [
            'title' => 'Updated Title',
            'description' => 'Updated Description',
            'durationHours' => 50
        ]);
        
        $this->assertInstanceOf(CourseDTO::class, $result);
        $this->assertEquals('Updated Title', $result->title);
    }
    
    public function testCanFindPublishedCourses(): void
    {
        $courses = [
            $this->createTestCourse(),
            $this->createTestCourse()
        ];
        
        $this->courseRepository
            ->expects($this->once())
            ->method('findPublished')
            ->with(10, 0)
            ->willReturn($courses);
        
        $dtos = $this->service->findPublished(10, 0);
        
        $this->assertCount(2, $dtos);
        $this->assertContainsOnlyInstancesOf(CourseDTO::class, $dtos);
    }
    
    public function testCanPublishCourse(): void
    {
        $courseId = CourseId::generate();
        $course = $this->createTestCourse();
        
        // Add module to allow publishing
        $course->addModule([
            'title' => 'Module 1',
            'duration' => 60,
            'description' => 'First module'
        ]);
        
        $this->courseRepository
            ->expects($this->once())
            ->method('findById')
            ->with($courseId)
            ->willReturn($course);
        
        $this->courseRepository
            ->expects($this->once())
            ->method('save')
            ->with($course);
        
        $result = $this->service->publish($courseId->getValue());
        
        $this->assertTrue($result);
    }
    
    public function testThrowsExceptionWhenCourseNotFoundForUpdate(): void
    {
        $courseId = CourseId::generate();
        
        $this->courseRepository
            ->expects($this->once())
            ->method('findById')
            ->with($courseId)
            ->willReturn(null);
        
        $this->expectException(\Common\Exceptions\NotFoundException::class);
        
        $this->service->update($courseId->getValue(), ['title' => 'New Title']);
    }
    
    private function createTestCourse(): Course
    {
        return Course::create(
            id: CourseId::generate(),
            code: CourseCode::fromString('CRS-001'),
            title: 'Test Course',
            description: 'Test Description',
            duration: Duration::fromHours(40)
        );
    }
} 