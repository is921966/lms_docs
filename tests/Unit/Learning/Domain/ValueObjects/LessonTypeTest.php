<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Domain\ValueObjects;

use App\Learning\Domain\ValueObjects\LessonType;
use PHPUnit\Framework\TestCase;

class LessonTypeTest extends TestCase
{
    public function testCanBeCreatedFromValidType(): void
    {
        $video = LessonType::VIDEO;
        $text = LessonType::TEXT;
        $quiz = LessonType::QUIZ;
        $assignment = LessonType::ASSIGNMENT;
        
        $this->assertEquals('VIDEO', $video->value);
        $this->assertEquals('TEXT', $text->value);
        $this->assertEquals('QUIZ', $quiz->value);
        $this->assertEquals('ASSIGNMENT', $assignment->value);
    }
    
    public function testCanGetLabel(): void
    {
        $this->assertEquals('Video Lesson', LessonType::VIDEO->getLabel());
        $this->assertEquals('Text Lesson', LessonType::TEXT->getLabel());
        $this->assertEquals('Quiz', LessonType::QUIZ->getLabel());
        $this->assertEquals('Assignment', LessonType::ASSIGNMENT->getLabel());
    }
    
    public function testCanGetIcon(): void
    {
        $this->assertEquals('🎥', LessonType::VIDEO->getIcon());
        $this->assertEquals('📄', LessonType::TEXT->getIcon());
        $this->assertEquals('❓', LessonType::QUIZ->getIcon());
        $this->assertEquals('📝', LessonType::ASSIGNMENT->getIcon());
    }
    
    public function testCanCheckIfInteractive(): void
    {
        $this->assertFalse(LessonType::VIDEO->isInteractive());
        $this->assertFalse(LessonType::TEXT->isInteractive());
        $this->assertTrue(LessonType::QUIZ->isInteractive());
        $this->assertTrue(LessonType::ASSIGNMENT->isInteractive());
    }
    
    public function testCanCheckIfGradable(): void
    {
        $this->assertFalse(LessonType::VIDEO->isGradable());
        $this->assertFalse(LessonType::TEXT->isGradable());
        $this->assertTrue(LessonType::QUIZ->isGradable());
        $this->assertTrue(LessonType::ASSIGNMENT->isGradable());
    }
} 