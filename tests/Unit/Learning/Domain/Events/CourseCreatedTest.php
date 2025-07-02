<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Domain\Events;

use Learning\Domain\Events\CourseCreated;
use Learning\Domain\ValueObjects\CourseId;
use Learning\Domain\ValueObjects\CourseCode;
use Learning\Domain\ValueObjects\CourseStatus;
use PHPUnit\Framework\TestCase;

class CourseCreatedTest extends TestCase
{
    public function testCreateEvent(): void
    {
        // Arrange
        $courseId = CourseId::generate();
        $courseCode = CourseCode::fromString('PHP-101');
        $title = 'PHP for Beginners';
        $description = 'Learn PHP from scratch';
        $status = CourseStatus::draft();
        $occurredAt = new \DateTimeImmutable();
        
        // Act
        $event = new CourseCreated(
            $courseId,
            $courseCode,
            $title,
            $description,
            $status,
            $occurredAt
        );
        
        // Assert
        $this->assertInstanceOf(CourseCreated::class, $event);
        $this->assertTrue($courseId->equals($event->getCourseId()));
        $this->assertTrue($courseCode->equals($event->getCourseCode()));
        $this->assertEquals($title, $event->getTitle());
        $this->assertEquals($description, $event->getDescription());
        $this->assertTrue($status->equals($event->getStatus()));
        $this->assertEquals($occurredAt, $event->getOccurredAt());
        $this->assertEquals('course.created', $event->getEventName());
    }
    
    public function testCreateWithDefaultTimestamp(): void
    {
        // Arrange
        $courseId = CourseId::generate();
        $courseCode = CourseCode::fromString('PHP-101');
        $beforeCreation = new \DateTimeImmutable();
        
        // Act
        $event = CourseCreated::create(
            $courseId,
            $courseCode,
            'PHP Advanced',
            'Advanced PHP concepts',
            CourseStatus::draft()
        );
        
        $afterCreation = new \DateTimeImmutable();
        
        // Assert
        $this->assertGreaterThanOrEqual($beforeCreation, $event->getOccurredAt());
        $this->assertLessThanOrEqual($afterCreation, $event->getOccurredAt());
    }
    
    public function testSerializeToArray(): void
    {
        // Arrange
        $courseId = CourseId::generate();
        $courseCode = CourseCode::fromString('PHP-101');
        $title = 'PHP Course';
        $description = 'Course description';
        $status = CourseStatus::published();
        $occurredAt = new \DateTimeImmutable('2025-07-01 10:00:00');
        
        // Act
        $event = new CourseCreated(
            $courseId,
            $courseCode,
            $title,
            $description,
            $status,
            $occurredAt
        );
        
        $data = $event->toArray();
        
        // Assert
        $this->assertEquals([
            'event_name' => 'course.created',
            'course_id' => $courseId->getValue(),
            'course_code' => $courseCode->getValue(),
            'title' => $title,
            'description' => $description,
            'status' => $status->getValue(),
            'occurred_at' => $occurredAt->format('Y-m-d H:i:s')
        ], $data);
    }
    
    public function testGetAggregateId(): void
    {
        // Arrange
        $courseId = CourseId::generate();
        $event = CourseCreated::create(
            $courseId,
            CourseCode::fromString('PHP-101'),
            'Title',
            'Description',
            CourseStatus::draft()
        );
        
        // Act & Assert
        $this->assertEquals($courseId->getValue(), $event->getAggregateId());
    }
} 