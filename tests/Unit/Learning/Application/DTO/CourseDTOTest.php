<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Application\DTO;

use App\Learning\Application\DTO\CourseDTO;
use App\Learning\Domain\Course;
use App\Learning\Domain\ValueObjects\CourseId;
use App\Learning\Domain\ValueObjects\CourseCode;
use App\Learning\Domain\ValueObjects\CourseType;
use App\Learning\Domain\ValueObjects\CourseStatus;
use PHPUnit\Framework\TestCase;

class CourseDTOTest extends TestCase
{
    public function testCanBeCreatedFromArray(): void
    {
        $data = [
            'id' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            'code' => 'CRS-001',
            'title' => 'PHP Advanced Course',
            'description' => 'Learn advanced PHP concepts',
            'type' => 'online',
            'status' => 'published',
            'durationHours' => 40,
            'maxStudents' => 30,
            'price' => 99.99,
            'tags' => ['PHP', 'Backend', 'Advanced'],
            'prerequisites' => ['e4d8c9a0-1234-4567-8901-234567890123']
        ];
        
        $dto = CourseDTO::fromArray($data);
        
        $this->assertEquals($data['id'], $dto->id);
        $this->assertEquals($data['code'], $dto->code);
        $this->assertEquals($data['title'], $dto->title);
        $this->assertEquals($data['description'], $dto->description);
        $this->assertEquals($data['type'], $dto->type);
        $this->assertEquals($data['status'], $dto->status);
        $this->assertEquals($data['durationHours'], $dto->durationHours);
        $this->assertEquals($data['maxStudents'], $dto->maxStudents);
        $this->assertEquals($data['price'], $dto->price);
        $this->assertEquals($data['tags'], $dto->tags);
        $this->assertEquals($data['prerequisites'], $dto->prerequisites);
    }
    
    public function testCanBeCreatedFromDomainEntity(): void
    {
        $course = $this->createTestCourse();
        $course->addTag('PHP');
        $course->addTag('Advanced');
        $course->addPrerequisite(CourseId::fromString('e4d8c9a0-1234-4567-8901-234567890123'));
        
        $dto = CourseDTO::fromEntity($course);
        
        $this->assertEquals($course->getId()->toString(), $dto->id);
        $this->assertEquals($course->getCode()->toString(), $dto->code);
        $this->assertEquals($course->getTitle(), $dto->title);
        $this->assertEquals($course->getDescription(), $dto->description);
        $this->assertEquals('online', $dto->type);
        $this->assertEquals($course->getStatus()->value, $dto->status);
        $this->assertEquals($course->getDurationHours(), $dto->durationHours);
        $this->assertNull($dto->maxStudents);
        $this->assertNull($dto->price);
        $this->assertEquals($course->getTags(), $dto->tags);
        $this->assertCount(1, $dto->prerequisites);
    }
    
    public function testCanConvertToArray(): void
    {
        $dto = new CourseDTO(
            id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            code: 'CRS-001',
            title: 'PHP Course',
            description: 'Learn PHP',
            type: 'online',
            status: 'draft',
            durationHours: 20,
            maxStudents: 25,
            price: 49.99,
            tags: ['PHP'],
            prerequisites: []
        );
        
        $array = $dto->toArray();
        
        $this->assertIsArray($array);
        $this->assertEquals($dto->id, $array['id']);
        $this->assertEquals($dto->code, $array['code']);
        $this->assertEquals($dto->title, $array['title']);
        $this->assertEquals($dto->description, $array['description']);
        $this->assertEquals($dto->type, $array['type']);
        $this->assertEquals($dto->status, $array['status']);
        $this->assertEquals($dto->durationHours, $array['durationHours']);
        $this->assertEquals($dto->maxStudents, $array['maxStudents']);
        $this->assertEquals($dto->price, $array['price']);
        $this->assertEquals($dto->tags, $array['tags']);
        $this->assertEquals($dto->prerequisites, $array['prerequisites']);
    }
    
    public function testCanCreateNewEntity(): void
    {
        $dto = new CourseDTO(
            id: null, // New entity
            code: 'CRS-002',
            title: 'New Course',
            description: 'Brand new course',
            type: 'online',
            status: 'draft',
            durationHours: 30,
            maxStudents: 20,
            price: 79.99,
            tags: [],
            prerequisites: []
        );
        
        $course = $dto->toNewEntity();
        
        $this->assertInstanceOf(Course::class, $course);
        $this->assertEquals($dto->code, $course->getCode()->toString());
        $this->assertEquals($dto->title, $course->getTitle());
        $this->assertEquals($dto->description, $course->getDescription());
        $this->assertEquals(CourseType::from(strtoupper($dto->type)), $course->getType());
        $this->assertEquals(CourseStatus::DRAFT, $course->getStatus());
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