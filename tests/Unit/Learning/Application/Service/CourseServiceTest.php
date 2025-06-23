<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Application\Service;

use App\Learning\Application\Service\CourseService;
use App\Learning\Application\DTO\CourseDTO;
use App\Learning\Domain\Course;
use App\Learning\Domain\Repository\CourseRepositoryInterface;
use App\Learning\Domain\ValueObjects\CourseId;
use App\Learning\Domain\ValueObjects\CourseCode;
use App\Learning\Domain\ValueObjects\CourseType;
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
        
        $dto = $this->service->findById($courseId->toString());
        
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
        
        $dto = $this->service->findById($courseId->toString());
        
        $this->assertNull($dto);
    }
    
    public function testCanCreateNewCourse(): void
    {
        $dto = new CourseDTO(
            id: null,
            code: 'CRS-999',
            title: 'New Course',
            description: 'New Description',
            type: 'online',
            status: 'draft',
            durationHours: 40,
            maxStudents: null,
            price: null,
            tags: ['tag1', 'tag2'],
            prerequisites: [],
            imageUrl: null,
            createdAt: null,
            updatedAt: null
        );
        
        $this->courseRepository
            ->expects($this->once())
            ->method('save')
            ->with($this->callback(function (Course $course) use ($dto) {
                return $course->getCode()->toString() === $dto->code
                    && $course->getTitle() === $dto->title
                    && $course->getTags() === $dto->tags;
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
        
        $updateDto = CourseDTO::fromEntity($course);
        
        $this->courseRepository
            ->expects($this->once())
            ->method('findById')
            ->with($courseId)
            ->willReturn($course);
        
        $this->courseRepository
            ->expects($this->once())
            ->method('save')
            ->with($course);
        
        $result = $this->service->update($courseId->toString(), [
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
        
        $this->courseRepository
            ->expects($this->once())
            ->method('findById')
            ->with($courseId)
            ->willReturn($course);
        
        $this->courseRepository
            ->expects($this->once())
            ->method('save')
            ->with($course);
        
        $result = $this->service->publish($courseId->toString());
        
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
        
        $this->expectException(\App\Common\Exceptions\NotFoundException::class);
        
        $this->service->update($courseId->toString(), ['title' => 'New Title']);
    }
    
    private function createTestCourse(): Course
    {
        return Course::create(
            code: CourseCode::fromString('CRS-001'),
            title: 'Test Course',
            description: 'Test Description',
            type: CourseType::ONLINE,
            durationHours: 40
        );
    }
} 