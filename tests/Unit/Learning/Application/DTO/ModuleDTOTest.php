<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Application\DTO;

use Learning\Application\DTO\ModuleDTO;
use Learning\Domain\Module;
use Learning\Domain\ValueObjects\CourseId;
use PHPUnit\Framework\TestCase;

class ModuleDTOTest extends TestCase
{
    public function testCanBeCreatedFromArray(): void
    {
        $data = [
            'id' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            'courseId' => 'c1d2e3f4-a5b6-4789-0123-456789abcdef',
            'title' => 'Introduction to PHP',
            'description' => 'Learn PHP basics',
            'orderIndex' => 1,
            'durationMinutes' => 120,
            'isRequired' => true,
            'lessonCount' => 5,
            'completedLessons' => 0
        ];
        
        $dto = ModuleDTO::fromArray($data);
        
        $this->assertEquals($data['id'], $dto->id);
        $this->assertEquals($data['courseId'], $dto->courseId);
        $this->assertEquals($data['title'], $dto->title);
        $this->assertEquals($data['description'], $dto->description);
        $this->assertEquals($data['orderIndex'], $dto->orderIndex);
        $this->assertEquals($data['durationMinutes'], $dto->durationMinutes);
        $this->assertTrue($dto->isRequired);
        $this->assertEquals($data['lessonCount'], $dto->lessonCount);
        $this->assertEquals($data['completedLessons'], $dto->completedLessons);
    }
    
    public function testCanBeCreatedFromDomainEntity(): void
    {
        $module = $this->createTestModule();
        
        $dto = ModuleDTO::fromEntity($module);
        
        $this->assertEquals($module->getId()->getValue(), $dto->id);
        $this->assertEquals($module->getCourseId()->getValue(), $dto->courseId);
        $this->assertEquals($module->getTitle(), $dto->title);
        $this->assertEquals($module->getDescription(), $dto->description);
        $this->assertEquals($module->getOrderIndex(), $dto->orderIndex);
        $this->assertEquals($module->getDurationMinutes(), $dto->durationMinutes);
        $this->assertTrue($dto->isRequired);
        $this->assertEquals(0, $dto->lessonCount); // No lessons added
        $this->assertEquals(0, $dto->completedLessons);
    }
    
    public function testCanConvertToArray(): void
    {
        $dto = new ModuleDTO(
            id: 'module-123',
            courseId: 'course-456',
            title: 'Test Module',
            description: 'Test Description',
            orderIndex: 2,
            durationMinutes: 90,
            isRequired: false,
            lessonCount: 3,
            completedLessons: 1,
            createdAt: '2024-01-01T00:00:00+00:00',
            updatedAt: '2024-01-01T00:00:00+00:00'
        );
        
        $array = $dto->toArray();
        
        $this->assertIsArray($array);
        $this->assertEquals($dto->id, $array['id']);
        $this->assertEquals($dto->title, $array['title']);
        $this->assertEquals($dto->orderIndex, $array['orderIndex']);
        $this->assertFalse($array['isRequired']);
        $this->assertEquals(3, $array['lessonCount']);
        $this->assertEquals(1, $array['completedLessons']);
    }
    
    public function testCanCalculateProgress(): void
    {
        $dto = new ModuleDTO(
            id: 'module-123',
            courseId: 'course-456',
            title: 'Test Module',
            description: 'Test',
            orderIndex: 1,
            durationMinutes: 60,
            isRequired: true,
            lessonCount: 4,
            completedLessons: 3,
            createdAt: null,
            updatedAt: null
        );
        
        $this->assertEquals(75.0, $dto->getProgressPercentage());
        
        // Test with no lessons
        $emptyDto = new ModuleDTO(
            id: 'module-456',
            courseId: 'course-456',
            title: 'Empty Module',
            description: 'No lessons',
            orderIndex: 2,
            durationMinutes: 0,
            isRequired: false,
            lessonCount: 0,
            completedLessons: 0,
            createdAt: null,
            updatedAt: null
        );
        
        $this->assertEquals(0.0, $emptyDto->getProgressPercentage());
    }
    
    private function createTestModule(): Module
    {
        return Module::create(
            courseId: CourseId::generate(),
            title: 'Test Module',
            description: 'Test Description',
            orderIndex: 1,
            durationMinutes: 120,
            isRequired: true
        );
    }
} 