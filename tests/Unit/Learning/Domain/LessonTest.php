<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Domain;

use Learning\Domain\Lesson;
use Learning\Domain\ValueObjects\LessonId;
use Learning\Domain\ValueObjects\ModuleId;
use Learning\Domain\ValueObjects\LessonType;
use PHPUnit\Framework\TestCase;

class LessonTest extends TestCase
{
    public function testCanBeCreated(): void
    {
        $moduleId = ModuleId::generate();
        $lesson = Lesson::create(
            moduleId: $moduleId,
            title: 'Introduction to PHP',
            type: LessonType::VIDEO,
            content: 'https://video.url/lesson1.mp4',
            orderIndex: 1,
            durationMinutes: 45
        );
        
        $this->assertInstanceOf(Lesson::class, $lesson);
        $this->assertInstanceOf(LessonId::class, $lesson->getId());
        $this->assertTrue($lesson->getModuleId()->equals($moduleId));
        $this->assertEquals('Introduction to PHP', $lesson->getTitle());
        $this->assertEquals(LessonType::VIDEO, $lesson->getType());
        $this->assertEquals('https://video.url/lesson1.mp4', $lesson->getContent());
        $this->assertEquals(1, $lesson->getOrderIndex());
        $this->assertEquals(45, $lesson->getDurationMinutes());
        $this->assertCount(0, $lesson->getResources());
    }
    
    public function testCanUpdateBasicInfo(): void
    {
        $lesson = $this->createTestLesson();
        
        $lesson->updateBasicInfo(
            title: 'Advanced PHP',
            content: 'https://video.url/lesson2.mp4',
            durationMinutes: 60
        );
        
        $this->assertEquals('Advanced PHP', $lesson->getTitle());
        $this->assertEquals('https://video.url/lesson2.mp4', $lesson->getContent());
        $this->assertEquals(60, $lesson->getDurationMinutes());
    }
    
    public function testCanChangeOrderIndex(): void
    {
        $lesson = $this->createTestLesson();
        $this->assertEquals(1, $lesson->getOrderIndex());
        
        $lesson->setOrderIndex(5);
        $this->assertEquals(5, $lesson->getOrderIndex());
    }
    
    public function testCannotSetNegativeOrderIndex(): void
    {
        $lesson = $this->createTestLesson();
        
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Order index must be positive');
        
        $lesson->setOrderIndex(-1);
    }
    
    public function testCanAddResources(): void
    {
        $lesson = $this->createTestLesson();
        
        $lesson->addResource('slides.pdf', 'https://resources.url/slides.pdf');
        $lesson->addResource('code-examples.zip', 'https://resources.url/examples.zip');
        
        $resources = $lesson->getResources();
        $this->assertCount(2, $resources);
        $this->assertArrayHasKey('slides.pdf', $resources);
        $this->assertEquals('https://resources.url/slides.pdf', $resources['slides.pdf']);
    }
    
    public function testCanRemoveResource(): void
    {
        $lesson = $this->createTestLesson();
        
        $lesson->addResource('slides.pdf', 'https://resources.url/slides.pdf');
        $lesson->addResource('examples.zip', 'https://resources.url/examples.zip');
        
        $lesson->removeResource('slides.pdf');
        
        $resources = $lesson->getResources();
        $this->assertCount(1, $resources);
        $this->assertArrayNotHasKey('slides.pdf', $resources);
        $this->assertArrayHasKey('examples.zip', $resources);
    }
    
    public function testCanCheckIfInteractive(): void
    {
        $videoLesson = $this->createTestLesson(LessonType::VIDEO);
        $textLesson = $this->createTestLesson(LessonType::TEXT);
        $quizLesson = $this->createTestLesson(LessonType::QUIZ);
        $assignmentLesson = $this->createTestLesson(LessonType::ASSIGNMENT);
        
        $this->assertFalse($videoLesson->isInteractive());
        $this->assertFalse($textLesson->isInteractive());
        $this->assertTrue($quizLesson->isInteractive());
        $this->assertTrue($assignmentLesson->isInteractive());
    }
    
    public function testCanCheckIfGradable(): void
    {
        $videoLesson = $this->createTestLesson(LessonType::VIDEO);
        $quizLesson = $this->createTestLesson(LessonType::QUIZ);
        
        $this->assertFalse($videoLesson->isGradable());
        $this->assertTrue($quizLesson->isGradable());
    }
    
    private function createTestLesson(LessonType $type = LessonType::VIDEO): Lesson
    {
        return Lesson::create(
            moduleId: ModuleId::generate(),
            title: 'Test Lesson',
            type: $type,
            content: 'Test content',
            orderIndex: 1,
            durationMinutes: 30
        );
    }
} 