<?php

declare(strict_types=1);

namespace Tests\Unit\Course\Domain\Entities;

use PHPUnit\Framework\TestCase;
use App\Course\Domain\Entities\Course;
use App\Course\Domain\ValueObjects\CourseId;
use App\Course\Domain\ValueObjects\CourseCode;
use App\Course\Domain\ValueObjects\Duration;
use App\Course\Domain\ValueObjects\Price;
use App\Course\Domain\Events\CourseCreated;
use App\Course\Domain\Events\CoursePublished;
use App\Common\Exceptions\InvalidArgumentException;

class CourseTest extends TestCase
{
    public function testCanCreateCourse(): void
    {
        // Given
        $id = CourseId::generate();
        $code = new CourseCode('CS101');
        $title = 'Introduction to Computer Science';
        $description = 'Basic course covering fundamentals of CS';
        $duration = new Duration(480); // 8 hours
        $price = new Price(99.99, 'USD');
        
        // When
        $course = new Course(
            $id,
            $code,
            $title,
            $description,
            $duration,
            $price
        );
        
        // Then
        $this->assertEquals($id, $course->id());
        $this->assertEquals($code, $course->code());
        $this->assertEquals($title, $course->title());
        $this->assertEquals($description, $course->description());
        $this->assertEquals($duration, $course->duration());
        $this->assertEquals($price, $course->price());
        $this->assertEquals('draft', $course->status());
        $this->assertInstanceOf(\DateTimeImmutable::class, $course->createdAt());
        
        // Check domain events
        $events = $course->pullDomainEvents();
        $this->assertCount(1, $events);
        $this->assertInstanceOf(CourseCreated::class, $events[0]);
        $this->assertEquals($id->value(), $events[0]->courseId);
        $this->assertEquals($code->value(), $events[0]->courseCode);
        $this->assertEquals($title, $events[0]->title);
    }
    
    public function testThrowsExceptionForEmptyTitle(): void
    {
        // Then
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Course title cannot be empty');
        
        // When
        new Course(
            CourseId::generate(),
            new CourseCode('CS101'),
            '',  // Empty title
            'Description',
            new Duration(480),
            new Price(99.99)
        );
    }
    
    public function testThrowsExceptionForEmptyDescription(): void
    {
        // Then
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Course description cannot be empty');
        
        // When
        new Course(
            CourseId::generate(),
            new CourseCode('CS101'),
            'Valid Title',
            '',  // Empty description
            new Duration(480),
            new Price(99.99)
        );
    }
    
    public function testCanPublishCourse(): void
    {
        // Given
        $course = $this->createValidCourse();
        
        // When
        $course->publish();
        
        // Then
        $this->assertEquals('published', $course->status());
        $this->assertInstanceOf(\DateTimeImmutable::class, $course->publishedAt());
        
        // Check domain events
        $events = $course->pullDomainEvents();
        $this->assertCount(2, $events); // CourseCreated + CoursePublished
        $this->assertInstanceOf(CoursePublished::class, $events[1]);
    }
    
    public function testCannotPublishAlreadyPublishedCourse(): void
    {
        // Given
        $course = $this->createValidCourse();
        $course->publish();
        $course->pullDomainEvents(); // Clear events
        
        // Then
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Course is already published');
        
        // When
        $course->publish();
    }
    
    public function testCanArchiveCourse(): void
    {
        // Given
        $course = $this->createValidCourse();
        $course->publish();
        
        // When
        $course->archive();
        
        // Then
        $this->assertEquals('archived', $course->status());
    }
    
    public function testCanUpdateCourseDetails(): void
    {
        // Given
        $course = $this->createValidCourse();
        $newTitle = 'Advanced Computer Science';
        $newDescription = 'Advanced topics in CS';
        $newPrice = new Price(149.99, 'USD');
        
        // When
        $course->updateDetails($newTitle, $newDescription, $newPrice);
        
        // Then
        $this->assertEquals($newTitle, $course->title());
        $this->assertEquals($newDescription, $course->description());
        $this->assertEquals($newPrice, $course->price());
    }
    
    public function testCannotUpdatePublishedCourse(): void
    {
        // Given
        $course = $this->createValidCourse();
        $course->publish();
        
        // Then
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Cannot update published course');
        
        // When
        $course->updateDetails('New Title', 'New Description', new Price(199.99));
    }
    
    private function createValidCourse(): Course
    {
        return new Course(
            CourseId::generate(),
            new CourseCode('CS101'),
            'Introduction to Computer Science',
            'Basic course covering fundamentals of CS',
            new Duration(480),
            new Price(99.99, 'USD')
        );
    }
} 