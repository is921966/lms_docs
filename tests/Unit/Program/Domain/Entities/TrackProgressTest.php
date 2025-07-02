<?php

declare(strict_types=1);

namespace Tests\Unit\Program\Domain\Entities;

use Program\Domain\TrackProgress;
use Program\Domain\ValueObjects\TrackId;
use User\Domain\ValueObjects\UserId;
use Learning\Domain\ValueObjects\CourseId;
use PHPUnit\Framework\TestCase;

class TrackProgressTest extends TestCase
{
    public function testCanBeCreated(): void
    {
        // Arrange
        $userId = UserId::generate();
        $trackId = TrackId::generate();
        $totalCourses = 5;
        
        // Act
        $progress = TrackProgress::create($userId, $trackId, $totalCourses);
        
        // Assert
        $this->assertInstanceOf(TrackProgress::class, $progress);
        $this->assertTrue($userId->equals($progress->getUserId()));
        $this->assertTrue($trackId->equals($progress->getTrackId()));
        $this->assertEquals($totalCourses, $progress->getTotalCourses());
        $this->assertEquals(0, $progress->getCompletedCourses());
        $this->assertEquals(0, $progress->getProgressPercentage());
        $this->assertFalse($progress->isCompleted());
    }
    
    public function testCanMarkCourseAsCompleted(): void
    {
        // Arrange
        $progress = $this->createTrackProgress(3);
        $courseId = CourseId::generate();
        
        // Act
        $progress->markCourseCompleted($courseId);
        
        // Assert
        $this->assertEquals(1, $progress->getCompletedCourses());
        $this->assertEquals(33, $progress->getProgressPercentage());
        $this->assertTrue($progress->hasCourseCompleted($courseId));
    }
    
    public function testCannotMarkSameCourseCompletedTwice(): void
    {
        // Arrange
        $progress = $this->createTrackProgress(3);
        $courseId = CourseId::generate();
        $progress->markCourseCompleted($courseId);
        
        // Assert
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Course already completed');
        
        // Act
        $progress->markCourseCompleted($courseId);
    }
    
    public function testCanCompleteTrack(): void
    {
        // Arrange
        $progress = $this->createTrackProgress(2);
        $course1 = CourseId::generate();
        $course2 = CourseId::generate();
        
        // Act
        $progress->markCourseCompleted($course1);
        $this->assertFalse($progress->isCompleted());
        
        $progress->markCourseCompleted($course2);
        
        // Assert
        $this->assertTrue($progress->isCompleted());
        $this->assertEquals(100, $progress->getProgressPercentage());
        $this->assertInstanceOf(\DateTimeImmutable::class, $progress->getCompletedAt());
    }
    
    public function testCanCalculateProgressPercentage(): void
    {
        // Arrange
        $progress = $this->createTrackProgress(4);
        
        // Act & Assert
        $this->assertEquals(0, $progress->getProgressPercentage());
        
        $progress->markCourseCompleted(CourseId::generate());
        $this->assertEquals(25, $progress->getProgressPercentage());
        
        $progress->markCourseCompleted(CourseId::generate());
        $this->assertEquals(50, $progress->getProgressPercentage());
        
        $progress->markCourseCompleted(CourseId::generate());
        $this->assertEquals(75, $progress->getProgressPercentage());
        
        $progress->markCourseCompleted(CourseId::generate());
        $this->assertEquals(100, $progress->getProgressPercentage());
    }
    
    public function testCanGetCompletedCourseIds(): void
    {
        // Arrange
        $progress = $this->createTrackProgress(3);
        $course1 = CourseId::generate();
        $course2 = CourseId::generate();
        
        // Act
        $progress->markCourseCompleted($course1);
        $progress->markCourseCompleted($course2);
        
        // Assert
        $completedIds = $progress->getCompletedCourseIds();
        $this->assertCount(2, $completedIds);
        $this->assertTrue($course1->equals($completedIds[0]));
        $this->assertTrue($course2->equals($completedIds[1]));
    }
    
    public function testCanResetProgress(): void
    {
        // Arrange
        $progress = $this->createTrackProgress(2);
        $progress->markCourseCompleted(CourseId::generate());
        $progress->markCourseCompleted(CourseId::generate());
        
        // Act
        $progress->reset();
        
        // Assert
        $this->assertEquals(0, $progress->getCompletedCourses());
        $this->assertEquals(0, $progress->getProgressPercentage());
        $this->assertFalse($progress->isCompleted());
        $this->assertNull($progress->getCompletedAt());
        $this->assertCount(0, $progress->getCompletedCourseIds());
    }
    
    public function testCanBeConvertedToArray(): void
    {
        // Arrange
        $progress = $this->createTrackProgress(2);
        $courseId = CourseId::generate();
        $progress->markCourseCompleted($courseId);
        
        // Act
        $array = $progress->toArray();
        
        // Assert
        $this->assertArrayHasKey('userId', $array);
        $this->assertArrayHasKey('trackId', $array);
        $this->assertArrayHasKey('totalCourses', $array);
        $this->assertArrayHasKey('completedCourses', $array);
        $this->assertArrayHasKey('progressPercentage', $array);
        $this->assertArrayHasKey('isCompleted', $array);
        $this->assertArrayHasKey('completedCourseIds', $array);
        $this->assertArrayHasKey('startedAt', $array);
        $this->assertArrayHasKey('completedAt', $array);
    }
    
    private function createTrackProgress(int $totalCourses = 5): TrackProgress
    {
        return TrackProgress::create(
            UserId::generate(),
            TrackId::generate(),
            $totalCourses
        );
    }
} 