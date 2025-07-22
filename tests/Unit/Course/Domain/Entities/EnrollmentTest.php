<?php

declare(strict_types=1);

namespace Tests\Unit\Course\Domain\Entities;

use PHPUnit\Framework\TestCase;
use App\Course\Domain\Entities\Enrollment;
use App\Course\Domain\ValueObjects\CourseId;
use App\Course\Domain\Events\EnrollmentStarted;
use App\Course\Domain\Events\CourseCompleted;
use App\Common\Exceptions\InvalidArgumentException;

class EnrollmentTest extends TestCase
{
    public function testCanCreateEnrollment(): void
    {
        // Given
        $courseId = CourseId::generate();
        $userId = 'USR-123e4567-e89b-12d3-a456-426614174000';
        
        // When
        $enrollment = new Enrollment($courseId, $userId);
        
        // Then
        $this->assertEquals($courseId, $enrollment->courseId());
        $this->assertEquals($userId, $enrollment->userId());
        $this->assertEquals('active', $enrollment->status());
        $this->assertEquals(0, $enrollment->progressPercent());
        $this->assertInstanceOf(\DateTimeImmutable::class, $enrollment->enrolledAt());
        $this->assertNull($enrollment->completedAt());
        
        // Check domain events
        $events = $enrollment->pullDomainEvents();
        $this->assertCount(1, $events);
        $this->assertInstanceOf(EnrollmentStarted::class, $events[0]);
    }
    
    public function testCanUpdateProgress(): void
    {
        // Given
        $enrollment = $this->createValidEnrollment();
        
        // When
        $enrollment->updateProgress(50);
        
        // Then
        $this->assertEquals(50, $enrollment->progressPercent());
        $this->assertInstanceOf(\DateTimeImmutable::class, $enrollment->lastActivityAt());
    }
    
    public function testThrowsExceptionForInvalidProgress(): void
    {
        // Given
        $enrollment = $this->createValidEnrollment();
        
        // Then
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Progress must be between 0 and 100');
        
        // When
        $enrollment->updateProgress(101);
    }
    
    public function testCanCompleteCourse(): void
    {
        // Given
        $enrollment = $this->createValidEnrollment();
        $enrollment->updateProgress(100);
        
        // When
        $enrollment->complete();
        
        // Then
        $this->assertEquals('completed', $enrollment->status());
        $this->assertInstanceOf(\DateTimeImmutable::class, $enrollment->completedAt());
        
        // Check domain events
        $events = $enrollment->pullDomainEvents();
        $this->assertCount(2, $events); // EnrollmentStarted + CourseCompleted
        $this->assertInstanceOf(CourseCompleted::class, $events[1]);
    }
    
    public function testCannotCompleteIfNotFullyProgressed(): void
    {
        // Given
        $enrollment = $this->createValidEnrollment();
        $enrollment->updateProgress(99);
        
        // Then
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Cannot complete course with progress less than 100%');
        
        // When
        $enrollment->complete();
    }
    
    public function testCanSuspendEnrollment(): void
    {
        // Given
        $enrollment = $this->createValidEnrollment();
        
        // When
        $enrollment->suspend();
        
        // Then
        $this->assertEquals('suspended', $enrollment->status());
    }
    
    public function testCanResumeEnrollment(): void
    {
        // Given
        $enrollment = $this->createValidEnrollment();
        $enrollment->suspend();
        
        // When
        $enrollment->resume();
        
        // Then
        $this->assertEquals('active', $enrollment->status());
    }
    
    public function testCannotResumeActiveEnrollment(): void
    {
        // Given
        $enrollment = $this->createValidEnrollment();
        
        // Then
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Can only resume suspended enrollments');
        
        // When
        $enrollment->resume();
    }
    
    private function createValidEnrollment(): Enrollment
    {
        return new Enrollment(
            CourseId::generate(),
            'USR-123e4567-e89b-12d3-a456-426614174000'
        );
    }
} 