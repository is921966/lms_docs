<?php

declare(strict_types=1);

namespace Tests\Unit\Course\Domain\Entities;

use PHPUnit\Framework\TestCase;
use App\Course\Domain\Entities\Lesson;
use App\Course\Domain\ValueObjects\Duration;
use App\Common\Exceptions\InvalidArgumentException;
use Ramsey\Uuid\Uuid;

class LessonTest extends TestCase
{
    public function testCanCreateLesson(): void
    {
        // Given
        $moduleId = Uuid::uuid4()->toString();
        $title = 'Variables and Data Types';
        $description = 'Learn about variables';
        $content = 'Lesson content here';
        $duration = new Duration(30);
        $order = 1;
        
        // When
        $lesson = new Lesson(
            $moduleId,
            $title,
            $description,
            $content,
            $duration,
            $order
        );
        
        // Then
        $this->assertEquals($moduleId, $lesson->moduleId());
        $this->assertEquals($title, $lesson->title());
        $this->assertEquals($description, $lesson->description());
        $this->assertEquals($content, $lesson->content());
        $this->assertEquals($duration, $lesson->duration());
        $this->assertEquals($order, $lesson->order());
        $this->assertEquals('text', $lesson->type());
        $this->assertNotNull($lesson->id());
    }
    
    public function testCanCreateVideoLesson(): void
    {
        // Given
        $lesson = new Lesson(
            Uuid::uuid4()->toString(),
            'Video Lesson',
            'Video description',
            'https://video.url',
            new Duration(45),
            1,
            'video'
        );
        
        // Then
        $this->assertEquals('video', $lesson->type());
    }
    
    public function testThrowsExceptionForInvalidType(): void
    {
        // Then
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid lesson type');
        
        // When
        new Lesson(
            Uuid::uuid4()->toString(),
            'Lesson',
            'Description',
            'Content',
            new Duration(30),
            1,
            'invalid'
        );
    }
    
    public function testCanMarkAsCompleted(): void
    {
        // Given
        $lesson = $this->createValidLesson();
        $userId = 'USR-' . Uuid::uuid4()->toString();
        
        // When
        $completed = $lesson->markAsCompleted($userId);
        
        // Then
        $this->assertTrue($completed);
    }
    
    public function testCanUpdateContent(): void
    {
        // Given
        $lesson = $this->createValidLesson();
        $newContent = 'Updated content';
        $newDuration = new Duration(45);
        
        // When
        $lesson->updateContent($newContent, $newDuration);
        
        // Then
        $this->assertEquals($newContent, $lesson->content());
        $this->assertEquals($newDuration, $lesson->duration());
    }
    
    private function createValidLesson(): Lesson
    {
        return new Lesson(
            Uuid::uuid4()->toString(),
            'Test Lesson',
            'Test Description',
            'Test Content',
            new Duration(30),
            1
        );
    }
} 