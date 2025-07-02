<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Domain;

use Learning\Domain\Course;
use Learning\Domain\ValueObjects\CourseId;
use Learning\Domain\ValueObjects\CourseCode;
use Learning\Domain\ValueObjects\CourseType;
use Learning\Domain\ValueObjects\CourseStatus;
use Learning\Domain\ValueObjects\Duration;
use PHPUnit\Framework\TestCase;

class CourseTest extends TestCase
{
    public function testCanBeCreated(): void
    {
        $courseId = CourseId::generate();
        $course = Course::create(
            id: $courseId,
            code: CourseCode::fromString('CRS-001'),
            title: 'Introduction to PHP',
            description: 'Learn PHP basics',
            duration: Duration::fromHours(40)
        );
        
        $this->assertInstanceOf(Course::class, $course);
        $this->assertEquals($courseId, $course->getId());
        $this->assertEquals('CRS-001', $course->getCode()->getValue());
        $this->assertEquals('Introduction to PHP', $course->getTitle());
        $this->assertEquals('Learn PHP basics', $course->getDescription());
        $this->assertEquals(40, $course->getDuration()->getHours());
        $this->assertEquals(CourseStatus::draft(), $course->getStatus());
        $this->assertCount(0, $course->getModules());
        $this->assertCount(0, $course->getPrerequisites());
    }
    
    public function testCanUpdateBasicInfo(): void
    {
        $course = $this->createTestCourse();
        
        $course->updateDetails(
            title: 'Advanced PHP',
            description: 'Master PHP programming'
        );
        
        $this->assertEquals('Advanced PHP', $course->getTitle());
        $this->assertEquals('Master PHP programming', $course->getDescription());
    }
    
    public function testCannotUpdatePublishedCourse(): void
    {
        $course = $this->createTestCourse();
        $course->addModule(['title' => 'Module 1', 'duration' => 60]); // Add module to allow publishing
        $course->publish();
        
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Cannot update archived course');
        
        $course->archive();
        $course->updateDetails(
            title: 'New Title',
            description: 'New Description'
        );
    }
    
    public function testCanAddModule(): void
    {
        $course = $this->createTestCourse();
        
        $module = [
            'title' => 'Module 1: Basics',
            'description' => 'Learn the basics',
            'duration' => 120
        ];
        
        $course->addModule($module);
        
        $this->assertCount(1, $course->getModules());
        $this->assertEquals($module, $course->getModules()[0]);
    }
    
    public function testCanSetPrerequisites(): void
    {
        $course = $this->createTestCourse();
        $prerequisiteIds = [
            CourseId::generate()->getValue(),
            CourseId::generate()->getValue()
        ];
        
        $course->setPrerequisites($prerequisiteIds);
        
        $this->assertCount(2, $course->getPrerequisites());
        $this->assertEquals($prerequisiteIds, $course->getPrerequisites());
    }
    
    public function testCannotAddModuleToArchivedCourse(): void
    {
        $course = $this->createTestCourse();
        $course->addModule(['title' => 'Module 1', 'duration' => 60]);
        $course->publish();
        $course->archive();
        
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Cannot add modules to archived course');
        
        $course->addModule(['title' => 'Module 2', 'duration' => 60]);
    }
    
    public function testCanAddMetadata(): void
    {
        $course = $this->createTestCourse();
        
        $course->addMetadata('level', 'beginner');
        $course->addMetadata('language', 'en');
        
        $metadata = $course->getMetadata();
        $this->assertEquals('beginner', $metadata['level']);
        $this->assertEquals('en', $metadata['language']);
    }
    
    public function testCanPublishCourse(): void
    {
        $course = $this->createTestCourse();
        $course->addModule(['title' => 'Module 1', 'duration' => 60]);
        
        $this->assertEquals(CourseStatus::draft(), $course->getStatus());
        
        $course->publish();
        
        $this->assertEquals(CourseStatus::published(), $course->getStatus());
        $this->assertNotNull($course->getPublishedAt());
    }
    
    public function testCannotPublishWithoutModules(): void
    {
        $course = $this->createTestCourse();
        
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Cannot publish course without modules');
        
        $course->publish();
    }
    
    public function testCanArchiveCourse(): void
    {
        $course = $this->createTestCourse();
        $course->addModule(['title' => 'Module 1', 'duration' => 60]);
        $course->publish();
        
        $course->archive();
        
        $this->assertEquals(CourseStatus::archived(), $course->getStatus());
    }
    
    public function testCannotArchiveUnpublishedCourse(): void
    {
        $course = $this->createTestCourse();
        
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Only published courses can be archived');
        
        $course->archive();
    }
    
    public function testCanCalculateTotalDuration(): void
    {
        $course = $this->createTestCourse();
        
        $course->addModule(['title' => 'Module 1', 'duration' => 120]);
        $course->addModule(['title' => 'Module 2', 'duration' => 180]);
        
        $totalDuration = $course->calculateTotalDuration();
        $this->assertEquals(300, $totalDuration->getMinutes());
        $this->assertEquals(5, $totalDuration->getHours());
    }
    
    public function testCanCheckEnrollmentStatus(): void
    {
        $course = $this->createTestCourse();
        
        // Draft course can be enrolled
        $this->assertTrue($course->canEnroll());
        
        // Published course can be enrolled
        $course->addModule(['title' => 'Module 1', 'duration' => 60]);
        $course->publish();
        $this->assertTrue($course->canEnroll());
        
        // Archived course cannot be enrolled
        $course->archive();
        $this->assertFalse($course->canEnroll());
    }
    
    private function createTestCourse(): Course
    {
        return Course::create(
            id: CourseId::generate(),
            code: CourseCode::fromString('CRS-001'),
            title: 'Test Course',
            description: 'Test Description',
            duration: Duration::fromHours(40)
        );
    }
} 