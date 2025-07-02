<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Domain\Events;

use Learning\Domain\Events\LessonCompleted;
use Learning\Domain\ValueObjects\CourseId;
use PHPUnit\Framework\TestCase;

class LessonCompletedTest extends TestCase
{
    public function testCreateEvent(): void
    {
        // Arrange
        $userId = 'user-123';
        $courseId = CourseId::generate();
        $lessonId = 'lesson-456';
        $completedAt = new \DateTimeImmutable();
        $timeSpent = 45; // minutes
        
        // Act
        $event = new LessonCompleted(
            $userId,
            $courseId,
            $lessonId,
            $completedAt,
            $timeSpent
        );
        
        // Assert
        $this->assertInstanceOf(LessonCompleted::class, $event);
        $this->assertEquals($userId, $event->getUserId());
        $this->assertTrue($courseId->equals($event->getCourseId()));
        $this->assertEquals($lessonId, $event->getLessonId());
        $this->assertEquals($completedAt, $event->getCompletedAt());
        $this->assertEquals($timeSpent, $event->getTimeSpentMinutes());
        $this->assertEquals('lesson.completed', $event->getEventName());
    }
    
    public function testCreateWithFactory(): void
    {
        // Arrange
        $userId = 'user-123';
        $courseId = CourseId::generate();
        $lessonId = 'lesson-456';
        $timeSpent = 30;
        $beforeCreation = new \DateTimeImmutable();
        
        // Act
        $event = LessonCompleted::create(
            $userId,
            $courseId,
            $lessonId,
            $timeSpent
        );
        
        $afterCreation = new \DateTimeImmutable();
        
        // Assert
        $this->assertGreaterThanOrEqual($beforeCreation, $event->getCompletedAt());
        $this->assertLessThanOrEqual($afterCreation, $event->getCompletedAt());
        $this->assertEquals($event->getCompletedAt(), $event->getOccurredAt());
    }
    
    public function testSerializeToArray(): void
    {
        // Arrange
        $userId = 'user-123';
        $courseId = CourseId::generate();
        $lessonId = 'lesson-456';
        $completedAt = new \DateTimeImmutable('2025-07-01 15:30:00');
        $timeSpent = 60;
        
        $event = new LessonCompleted(
            $userId,
            $courseId,
            $lessonId,
            $completedAt,
            $timeSpent
        );
        
        // Act
        $data = $event->toArray();
        
        // Assert
        $this->assertEquals([
            'event_name' => 'lesson.completed',
            'user_id' => $userId,
            'course_id' => $courseId->getValue(),
            'lesson_id' => $lessonId,
            'completed_at' => $completedAt->format('Y-m-d H:i:s'),
            'time_spent_minutes' => $timeSpent,
            'occurred_at' => $completedAt->format('Y-m-d H:i:s')
        ], $data);
    }
    
    public function testGetAggregateId(): void
    {
        // Arrange
        $userId = 'user-123';
        $courseId = CourseId::generate();
        $lessonId = 'lesson-456';
        
        $event = LessonCompleted::create($userId, $courseId, $lessonId, 45);
        
        // Act & Assert
        // For lesson completion, aggregate ID is combined user+course
        $this->assertEquals("{$userId}:{$courseId->getValue()}", $event->getAggregateId());
    }
} 