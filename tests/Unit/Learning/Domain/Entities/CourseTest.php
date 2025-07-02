<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Domain\Entities;

use Learning\Domain\Course;
use Learning\Domain\Events\CourseCreated;
use Learning\Domain\ValueObjects\CourseId;
use Learning\Domain\ValueObjects\CourseCode;
use Learning\Domain\ValueObjects\CourseStatus;
use Learning\Domain\ValueObjects\Duration;
use PHPUnit\Framework\TestCase;

class CourseTest extends TestCase
{
    public function testCreateCourse(): void
    {
        // Arrange
        $courseId = CourseId::generate();
        $courseCode = CourseCode::fromString('PHP-101');
        $title = 'PHP for Beginners';
        $description = 'Learn PHP from scratch';
        $duration = Duration::fromHours(10);
        
        // Act
        $course = Course::create(
            $courseId,
            $courseCode,
            $title,
            $description,
            $duration
        );
        
        // Assert
        $this->assertInstanceOf(Course::class, $course);
        $this->assertTrue($courseId->equals($course->getId()));
        $this->assertTrue($courseCode->equals($course->getCode()));
        $this->assertEquals($title, $course->getTitle());
        $this->assertEquals($description, $course->getDescription());
        $this->assertTrue($duration->equals($course->getDuration()));
        $this->assertTrue(CourseStatus::draft()->equals($course->getStatus()));
        $this->assertCount(0, $course->getModules());
        
        // Check domain event
        $events = $course->pullDomainEvents();
        $this->assertCount(1, $events);
        $this->assertInstanceOf(CourseCreated::class, $events[0]);
    }
    
    public function testUpdateCourseDetails(): void
    {
        // Arrange
        $course = $this->createTestCourse();
        $newTitle = 'Advanced PHP';
        $newDescription = 'Master PHP programming';
        
        // Act
        $course->updateDetails($newTitle, $newDescription);
        
        // Assert
        $this->assertEquals($newTitle, $course->getTitle());
        $this->assertEquals($newDescription, $course->getDescription());
    }
    
    public function testPublishCourse(): void
    {
        // Arrange
        $course = $this->createTestCourse();
        $this->addModulesToCourse($course);
        
        // Act
        $course->publish();
        
        // Assert
        $this->assertTrue(CourseStatus::published()->equals($course->getStatus()));
        $this->assertTrue($course->canEnroll());
    }
    
    public function testCannotPublishEmptyCourse(): void
    {
        // Arrange
        $course = $this->createTestCourse();
        
        // Act & Assert
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Cannot publish course without modules');
        
        $course->publish();
    }
    
    public function testArchiveCourse(): void
    {
        // Arrange
        $course = $this->createTestCourse();
        $this->addModulesToCourse($course);
        $course->publish();
        
        // Act
        $course->archive();
        
        // Assert
        $this->assertTrue(CourseStatus::archived()->equals($course->getStatus()));
        $this->assertFalse($course->canEnroll());
    }
    
    public function testCannotArchiveUnpublishedCourse(): void
    {
        // Arrange
        $course = $this->createTestCourse();
        
        // Act & Assert
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Only published courses can be archived');
        
        $course->archive();
    }
    
    public function testSetPrerequisites(): void
    {
        // Arrange
        $course = $this->createTestCourse();
        $prerequisite1 = CourseId::generate();
        $prerequisite2 = CourseId::generate();
        
        // Act
        $course->setPrerequisites([$prerequisite1, $prerequisite2]);
        
        // Assert
        $prerequisites = $course->getPrerequisites();
        $this->assertCount(2, $prerequisites);
        $this->assertTrue($prerequisite1->equals($prerequisites[0]));
        $this->assertTrue($prerequisite2->equals($prerequisites[1]));
    }
    
    public function testAddMetadata(): void
    {
        // Arrange
        $course = $this->createTestCourse();
        
        // Act
        $course->addMetadata('level', 'beginner');
        $course->addMetadata('language', 'en');
        
        // Assert
        $metadata = $course->getMetadata();
        $this->assertEquals('beginner', $metadata['level']);
        $this->assertEquals('en', $metadata['language']);
    }
    
    public function testCalculateTotalDuration(): void
    {
        // Arrange
        $course = $this->createTestCourse();
        $this->addModulesToCourse($course);
        
        // Act
        $totalDuration = $course->calculateTotalDuration();
        
        // Assert
        $this->assertEquals(180, $totalDuration->getMinutes()); // 3 hours
    }
    
    private function createTestCourse(): Course
    {
        return Course::create(
            CourseId::generate(),
            CourseCode::fromString('TEST-001'),
            'Test Course',
            'Test Description',
            Duration::fromHours(5)
        );
    }
    
    private function addModulesToCourse(Course $course): void
    {
        // This would normally use Module entity
        // For now, using a simple array structure
        $modules = [
            ['title' => 'Module 1', 'duration' => 60],
            ['title' => 'Module 2', 'duration' => 120]
        ];
        
        foreach ($modules as $module) {
            $course->addModule($module);
        }
    }
} 