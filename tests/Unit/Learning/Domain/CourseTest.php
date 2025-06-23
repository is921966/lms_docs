<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Domain;

use App\Learning\Domain\Course;
use App\Learning\Domain\ValueObjects\CourseId;
use App\Learning\Domain\ValueObjects\CourseCode;
use App\Learning\Domain\ValueObjects\CourseType;
use App\Learning\Domain\ValueObjects\CourseStatus;
use PHPUnit\Framework\TestCase;

class CourseTest extends TestCase
{
    public function testCanBeCreated(): void
    {
        $course = Course::create(
            code: CourseCode::fromString('CRS-001'),
            title: 'Introduction to PHP',
            description: 'Learn PHP basics',
            type: CourseType::ONLINE,
            durationHours: 40
        );
        
        $this->assertInstanceOf(Course::class, $course);
        $this->assertInstanceOf(CourseId::class, $course->getId());
        $this->assertEquals('CRS-001', $course->getCode()->toString());
        $this->assertEquals('Introduction to PHP', $course->getTitle());
        $this->assertEquals('Learn PHP basics', $course->getDescription());
        $this->assertEquals(CourseType::ONLINE, $course->getType());
        $this->assertEquals(40, $course->getDurationHours());
        $this->assertEquals(CourseStatus::DRAFT, $course->getStatus());
        $this->assertNull($course->getImageUrl());
        $this->assertCount(0, $course->getTags());
        $this->assertCount(0, $course->getPrerequisites());
    }
    
    public function testCanUpdateBasicInfo(): void
    {
        $course = $this->createTestCourse();
        
        $course->updateBasicInfo(
            title: 'Advanced PHP',
            description: 'Master PHP programming',
            durationHours: 60
        );
        
        $this->assertEquals('Advanced PHP', $course->getTitle());
        $this->assertEquals('Master PHP programming', $course->getDescription());
        $this->assertEquals(60, $course->getDurationHours());
    }
    
    public function testCannotUpdatePublishedCourse(): void
    {
        $course = $this->createTestCourse();
        $course->publish();
        
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Cannot update published course');
        
        $course->updateBasicInfo(
            title: 'New Title',
            description: 'New Description',
            durationHours: 50
        );
    }
    
    public function testCanSetImageUrl(): void
    {
        $course = $this->createTestCourse();
        $imageUrl = 'https://example.com/course-image.jpg';
        
        $course->setImageUrl($imageUrl);
        
        $this->assertEquals($imageUrl, $course->getImageUrl());
    }
    
    public function testCanAddAndRemoveTags(): void
    {
        $course = $this->createTestCourse();
        
        $course->addTag('php');
        $course->addTag('programming');
        $course->addTag('web');
        
        $this->assertCount(3, $course->getTags());
        $this->assertContains('php', $course->getTags());
        $this->assertContains('programming', $course->getTags());
        
        $course->removeTag('web');
        
        $this->assertCount(2, $course->getTags());
        $this->assertNotContains('web', $course->getTags());
    }
    
    public function testCannotAddDuplicateTags(): void
    {
        $course = $this->createTestCourse();
        
        $course->addTag('php');
        $course->addTag('php'); // Should be ignored
        
        $this->assertCount(1, $course->getTags());
    }
    
    public function testCanAddPrerequisites(): void
    {
        $course = $this->createTestCourse();
        $prerequisiteId = CourseId::generate();
        
        $course->addPrerequisite($prerequisiteId);
        
        $this->assertCount(1, $course->getPrerequisites());
        $this->assertTrue($course->hasPrerequisite($prerequisiteId));
    }
    
    public function testCannotAddSelfAsPrerequisite(): void
    {
        $course = $this->createTestCourse();
        
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Course cannot be its own prerequisite');
        
        $course->addPrerequisite($course->getId());
    }
    
    public function testCanPublishCourse(): void
    {
        $course = $this->createTestCourse();
        
        $this->assertEquals(CourseStatus::DRAFT, $course->getStatus());
        
        $course->publish();
        
        $this->assertEquals(CourseStatus::PUBLISHED, $course->getStatus());
    }
    
    public function testCannotPublishWithoutTitle(): void
    {
        $course = Course::create(
            code: CourseCode::fromString('CRS-001'),
            title: '',
            description: 'Description',
            type: CourseType::ONLINE,
            durationHours: 40
        );
        
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Cannot publish course without title');
        
        $course->publish();
    }
    
    public function testCanArchiveCourse(): void
    {
        $course = $this->createTestCourse();
        $course->publish();
        
        $course->archive();
        
        $this->assertEquals(CourseStatus::ARCHIVED, $course->getStatus());
    }
    
    public function testCanReactivateArchivedCourse(): void
    {
        $course = $this->createTestCourse();
        $course->publish();
        $course->archive();
        
        $course->reactivate();
        
        $this->assertEquals(CourseStatus::DRAFT, $course->getStatus());
    }
    
    private function createTestCourse(): Course
    {
        return Course::create(
            code: CourseCode::fromString('CRS-001'),
            title: 'Test Course',
            description: 'Test Description',
            type: CourseType::ONLINE,
            durationHours: 40
        );
    }
} 