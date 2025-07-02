<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Application\DTO;

use Learning\Application\DTO\CourseDTO;
use Learning\Domain\Course;
use Learning\Domain\ValueObjects\CourseId;
use Learning\Domain\ValueObjects\CourseCode;
use Learning\Domain\ValueObjects\Duration;
use Learning\Domain\ValueObjects\CourseStatus;
use PHPUnit\Framework\TestCase;

class CourseDTOTest extends TestCase
{
    public function testCreateFromArray(): void
    {
        // Arrange
        $data = [
            'id' => 'course-123',
            'course_code' => 'PHP-101',
            'title' => 'PHP Basics',
            'description' => 'Learn PHP from scratch',
            'duration_hours' => 20,
            'instructor_id' => 'instructor-456',
            'status' => 'published',
            'metadata' => ['level' => 'beginner', 'tags' => ['php', 'web']],
            'created_at' => '2025-07-01 10:00:00',
            'updated_at' => '2025-07-01 11:00:00'
        ];
        
        // Act
        $dto = CourseDTO::fromArray($data);
        
        // Assert
        $this->assertEquals('course-123', $dto->id);
        $this->assertEquals('PHP-101', $dto->courseCode);
        $this->assertEquals('PHP Basics', $dto->title);
        $this->assertEquals('Learn PHP from scratch', $dto->description);
        $this->assertEquals(20, $dto->durationHours);
        $this->assertEquals('instructor-456', $dto->instructorId);
        $this->assertEquals('published', $dto->status);
        $this->assertEquals(['level' => 'beginner', 'tags' => ['php', 'web']], $dto->metadata);
        $this->assertEquals('2025-07-01 10:00:00', $dto->createdAt);
        $this->assertEquals('2025-07-01 11:00:00', $dto->updatedAt);
    }
    
    public function testCreateWithDefaults(): void
    {
        // Arrange
        $data = [
            'id' => 'course-123',
            'course_code' => 'PHP-101',
            'title' => 'PHP Basics',
            'description' => 'Learn PHP',
            'duration_hours' => 10,
            'instructor_id' => 'instructor-456',
            'status' => 'draft'
        ];
        
        // Act
        $dto = CourseDTO::fromArray($data);
        
        // Assert
        $this->assertEquals([], $dto->metadata);
        $this->assertNull($dto->createdAt);
        $this->assertNull($dto->updatedAt);
    }
    
    public function testToArray(): void
    {
        // Arrange
        $data = [
            'id' => 'course-123',
            'course_code' => 'PHP-101',
            'title' => 'PHP Basics',
            'description' => 'Learn PHP',
            'duration_hours' => 20,
            'instructor_id' => 'instructor-456',
            'status' => 'published',
            'metadata' => ['level' => 'beginner']
        ];
        
        $dto = CourseDTO::fromArray($data);
        
        // Act
        $array = $dto->toArray();
        
        // Assert
        $this->assertArrayHasKey('id', $array);
        $this->assertArrayHasKey('course_code', $array);
        $this->assertArrayHasKey('title', $array);
        $this->assertArrayHasKey('description', $array);
        $this->assertArrayHasKey('duration_hours', $array);
        $this->assertArrayHasKey('instructor_id', $array);
        $this->assertArrayHasKey('status', $array);
        $this->assertArrayHasKey('metadata', $array);
        
        $this->assertEquals($data['id'], $array['id']);
        $this->assertEquals($data['title'], $array['title']);
    }
    
    public function testJsonSerializable(): void
    {
        // Arrange
        $dto = CourseDTO::fromArray([
            'id' => 'course-123',
            'course_code' => 'PHP-101',
            'title' => 'PHP Basics',
            'description' => 'Learn PHP',
            'duration_hours' => 10,
            'instructor_id' => 'instructor-456',
            'status' => 'draft'
        ]);
        
        // Act
        $json = json_encode($dto);
        $decoded = json_decode($json, true);
        
        // Assert
        $this->assertIsString($json);
        $this->assertEquals('course-123', $decoded['id']);
        $this->assertEquals('PHP-101', $decoded['course_code']);
    }
    
    public function testCanBeCreatedFromDomainEntity(): void
    {
        // Create a domain Course entity
        $course = Course::create(
            id: CourseId::fromString('f47ac10b-58cc-4372-a567-0e02b2c3d479'),
            code: CourseCode::fromString('CRS-001'),
            title: 'Test Course',
            description: 'Test Description',
            duration: Duration::fromHours(40)
        );
        
        // Create DTO from domain entity
        $dto = new CourseDTO(
            id: $course->getId()->getValue(),
            courseCode: $course->getCode()->getValue(),
            title: $course->getTitle(),
            description: $course->getDescription(),
            durationHours: $course->getDuration()->getHours(),
            instructorId: 'instructor-123', // Would come from repository/service
            status: $course->getStatus()->getValue(),
            metadata: $course->getMetadata(),
            createdAt: $course->getCreatedAt()->format('Y-m-d H:i:s'),
            updatedAt: null
        );
        
        // Assert
        $this->assertEquals($course->getId()->getValue(), $dto->id);
        $this->assertEquals($course->getCode()->getValue(), $dto->courseCode);
        $this->assertEquals($course->getTitle(), $dto->title);
        $this->assertEquals($course->getDescription(), $dto->description);
        $this->assertEquals($course->getDuration()->getHours(), $dto->durationHours);
        $this->assertEquals($course->getStatus()->getValue(), $dto->status);
    }
    
    public function testCanConvertToArray(): void
    {
        $dto = new CourseDTO(
            id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            courseCode: 'CRS-001',
            title: 'PHP Course',
            description: 'Learn PHP',
            durationHours: 20,
            instructorId: 'instructor-123',
            status: 'draft',
            metadata: ['tags' => ['PHP', 'Backend']],
            createdAt: '2025-07-01 10:00:00',
            updatedAt: null
        );
        
        $array = $dto->toArray();
        
        $this->assertIsArray($array);
        $this->assertEquals($dto->id, $array['id']);
        $this->assertEquals($dto->courseCode, $array['course_code']);
        $this->assertEquals($dto->title, $array['title']);
        $this->assertEquals($dto->description, $array['description']);
        $this->assertEquals($dto->durationHours, $array['duration_hours']);
        $this->assertEquals($dto->instructorId, $array['instructor_id']);
        $this->assertEquals($dto->status, $array['status']);
        $this->assertEquals($dto->metadata, $array['metadata']);
        $this->assertEquals($dto->createdAt, $array['created_at']);
        $this->assertNull($array['updated_at']);
    }
    
    public function testCanCreateNewEntity(): void
    {
        $dto = new CourseDTO(
            id: '', // Empty for new entity
            courseCode: 'CRS-002',
            title: 'New Course',
            description: 'Brand new course',
            durationHours: 30,
            instructorId: 'instructor-456',
            status: 'draft',
            metadata: [],
            createdAt: null,
            updatedAt: null
        );
        
        // Create domain entity from DTO
        $course = Course::create(
            id: CourseId::generate(),
            code: CourseCode::fromString($dto->courseCode),
            title: $dto->title,
            description: $dto->description,
            duration: Duration::fromHours($dto->durationHours)
        );
        
        $this->assertInstanceOf(Course::class, $course);
        $this->assertEquals($dto->courseCode, $course->getCode()->getValue());
        $this->assertEquals($dto->title, $course->getTitle());
        $this->assertEquals($dto->description, $course->getDescription());
        $this->assertEquals($dto->durationHours, $course->getDuration()->getHours());
        $this->assertEquals('draft', $course->getStatus()->getValue());
    }
} 