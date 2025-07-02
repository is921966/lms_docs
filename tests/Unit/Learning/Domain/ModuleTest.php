<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Domain;

use Learning\Domain\Module;
use Learning\Domain\Lesson;
use Learning\Domain\ValueObjects\ModuleId;
use Learning\Domain\ValueObjects\CourseId;
use Learning\Domain\ValueObjects\LessonId;
use Learning\Domain\ValueObjects\LessonType;
use PHPUnit\Framework\TestCase;

class ModuleTest extends TestCase
{
    public function testCanBeCreated(): void
    {
        $courseId = CourseId::generate();
        $module = Module::create(
            courseId: $courseId,
            title: 'Introduction Module',
            description: 'Learn the basics',
            orderIndex: 1,
            durationMinutes: 120,
            isRequired: true
        );
        
        $this->assertInstanceOf(Module::class, $module);
        $this->assertInstanceOf(ModuleId::class, $module->getId());
        $this->assertTrue($module->getCourseId()->equals($courseId));
        $this->assertEquals('Introduction Module', $module->getTitle());
        $this->assertEquals('Learn the basics', $module->getDescription());
        $this->assertEquals(1, $module->getOrderIndex());
        $this->assertEquals(120, $module->getDurationMinutes());
        $this->assertTrue($module->isRequired());
        $this->assertCount(0, $module->getLessons());
    }
    
    public function testCanUpdateBasicInfo(): void
    {
        $module = $this->createTestModule();
        
        $module->updateBasicInfo(
            title: 'Advanced Module',
            description: 'Master the concepts',
            durationMinutes: 180
        );
        
        $this->assertEquals('Advanced Module', $module->getTitle());
        $this->assertEquals('Master the concepts', $module->getDescription());
        $this->assertEquals(180, $module->getDurationMinutes());
    }
    
    public function testCanChangeRequiredStatus(): void
    {
        $module = $this->createTestModule();
        $this->assertTrue($module->isRequired());
        
        $module->setRequired(false);
        $this->assertFalse($module->isRequired());
        
        $module->setRequired(true);
        $this->assertTrue($module->isRequired());
    }
    
    public function testCanReorder(): void
    {
        $module = $this->createTestModule();
        $this->assertEquals(1, $module->getOrderIndex());
        
        $module->setOrderIndex(3);
        $this->assertEquals(3, $module->getOrderIndex());
    }
    
    public function testCannotSetNegativeOrderIndex(): void
    {
        $module = $this->createTestModule();
        
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Order index must be positive');
        
        $module->setOrderIndex(-1);
    }
    
    public function testCanAddLesson(): void
    {
        $module = $this->createTestModule();
        
        $lesson1 = $this->createLesson('Lesson 1', 1);
        $lesson2 = $this->createLesson('Lesson 2', 2);
        
        $module->addLesson($lesson1);
        $module->addLesson($lesson2);
        
        $this->assertCount(2, $module->getLessons());
        $this->assertTrue($module->hasLesson($lesson1->getId()));
        $this->assertTrue($module->hasLesson($lesson2->getId()));
    }
    
    public function testCannotAddDuplicateLesson(): void
    {
        $module = $this->createTestModule();
        $lesson = $this->createLesson('Lesson 1', 1);
        
        $module->addLesson($lesson);
        $module->addLesson($lesson); // Should be ignored
        
        $this->assertCount(1, $module->getLessons());
    }
    
    public function testCanRemoveLesson(): void
    {
        $module = $this->createTestModule();
        $lesson = $this->createLesson('Lesson 1', 1);
        
        $module->addLesson($lesson);
        $this->assertTrue($module->hasLesson($lesson->getId()));
        
        $module->removeLesson($lesson->getId());
        $this->assertFalse($module->hasLesson($lesson->getId()));
        $this->assertCount(0, $module->getLessons());
    }
    
    public function testCanReorderLessons(): void
    {
        $module = $this->createTestModule();
        
        $lesson1 = $this->createLesson('Lesson 1', 1);
        $lesson2 = $this->createLesson('Lesson 2', 2);
        $lesson3 = $this->createLesson('Lesson 3', 3);
        
        $module->addLesson($lesson1);
        $module->addLesson($lesson2);
        $module->addLesson($lesson3);
        
        // Reorder: [lesson1, lesson3, lesson2]
        $newOrder = [
            $lesson1->getId(),
            $lesson3->getId(),
            $lesson2->getId()
        ];
        
        $module->reorderLessons($newOrder);
        
        $lessons = $module->getLessons();
        $this->assertEquals(1, $lessons[0]->getOrderIndex());
        $this->assertEquals(2, $lessons[1]->getOrderIndex());
        $this->assertEquals(3, $lessons[2]->getOrderIndex());
    }
    
    public function testCalculatesTotalDuration(): void
    {
        $module = $this->createTestModule();
        
        $module->addLesson($this->createLesson('Lesson 1', 1, 30));
        $module->addLesson($this->createLesson('Lesson 2', 2, 45));
        $module->addLesson($this->createLesson('Lesson 3', 3, 25));
        
        $this->assertEquals(100, $module->calculateTotalDuration());
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
    
    private function createLesson(string $title, int $orderIndex, int $duration = 30): Lesson
    {
        return Lesson::create(
            moduleId: ModuleId::generate(),
            title: $title,
            type: LessonType::VIDEO,
            content: 'Test content',
            orderIndex: $orderIndex,
            durationMinutes: $duration
        );
    }
} 