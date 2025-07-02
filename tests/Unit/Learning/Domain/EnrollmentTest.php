<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Domain;

use Learning\Domain\Enrollment;
use Learning\Domain\ValueObjects\EnrollmentId;
use Learning\Domain\ValueObjects\EnrollmentStatus;
use Learning\Domain\ValueObjects\CourseId;
use User\Domain\ValueObjects\UserId;
use PHPUnit\Framework\TestCase;

class EnrollmentTest extends TestCase
{
    public function testCanBeCreated(): void
    {
        $userId = UserId::generate();
        $courseId = CourseId::generate();
        
        $enrollment = Enrollment::create(
            userId: $userId,
            courseId: $courseId,
            enrolledBy: $userId
        );
        
        $this->assertInstanceOf(Enrollment::class, $enrollment);
        $this->assertInstanceOf(EnrollmentId::class, $enrollment->getId());
        $this->assertTrue($enrollment->getUserId()->equals($userId));
        $this->assertTrue($enrollment->getCourseId()->equals($courseId));
        $this->assertEquals(EnrollmentStatus::PENDING, $enrollment->getStatus());
        $this->assertNull($enrollment->getCompletedAt());
        $this->assertNull($enrollment->getCancelledAt());
        $this->assertNull($enrollment->getExpiredAt());
    }
    
    public function testCanBeActivated(): void
    {
        $enrollment = $this->createTestEnrollment();
        $this->assertEquals(EnrollmentStatus::PENDING, $enrollment->getStatus());
        
        $enrollment->activate();
        
        $this->assertEquals(EnrollmentStatus::ACTIVE, $enrollment->getStatus());
        $this->assertNotNull($enrollment->getActivatedAt());
    }
    
    public function testCannotBeActivatedFromInvalidStatus(): void
    {
        $enrollment = $this->createTestEnrollment();
        $enrollment->activate();
        $enrollment->complete(100);
        
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Cannot transition from completed to active');
        
        $enrollment->activate();
    }
    
    public function testCanBeCompleted(): void
    {
        $enrollment = $this->createTestEnrollment();
        $enrollment->activate();
        
        $completionScore = 95.5;
        $enrollment->complete($completionScore);
        
        $this->assertEquals(EnrollmentStatus::COMPLETED, $enrollment->getStatus());
        $this->assertNotNull($enrollment->getCompletedAt());
        $this->assertEquals($completionScore, $enrollment->getCompletionScore());
    }
    
    public function testCannotBeCompletedWithInvalidScore(): void
    {
        $enrollment = $this->createTestEnrollment();
        $enrollment->activate();
        
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Completion score must be between 0 and 100');
        
        $enrollment->complete(150);
    }
    
    public function testCanBeCancelled(): void
    {
        $enrollment = $this->createTestEnrollment();
        
        $reason = 'Student request';
        $enrollment->cancel($reason);
        
        $this->assertEquals(EnrollmentStatus::CANCELLED, $enrollment->getStatus());
        $this->assertNotNull($enrollment->getCancelledAt());
        $this->assertEquals($reason, $enrollment->getCancellationReason());
    }
    
    public function testCanBeExpired(): void
    {
        $enrollment = $this->createTestEnrollment();
        $enrollment->activate();
        
        $enrollment->expire();
        
        $this->assertEquals(EnrollmentStatus::EXPIRED, $enrollment->getStatus());
        $this->assertNotNull($enrollment->getExpiredAt());
    }
    
    public function testCannotTransitionFromFinalStatus(): void
    {
        $enrollment = $this->createTestEnrollment();
        $enrollment->cancel('Test');
        
        $this->expectException(\DomainException::class);
        
        $enrollment->activate();
    }
    
    public function testCanCalculateDuration(): void
    {
        $enrollment = $this->createTestEnrollment();
        
        // Not started yet
        $this->assertNull($enrollment->getDurationInDays());
        
        // Active enrollment
        $enrollment->activate();
        $this->assertGreaterThanOrEqual(0, $enrollment->getDurationInDays());
        
        // Completed enrollment
        $enrollment->complete(100);
        $this->assertIsInt($enrollment->getDurationInDays());
    }
    
    public function testCanCheckIfExpired(): void
    {
        $enrollment = $this->createTestEnrollment();
        
        // Set expiry date in future
        $futureDate = new \DateTimeImmutable('+30 days');
        $enrollment->setExpiryDate($futureDate);
        $this->assertFalse($enrollment->isExpired());
        
        // Set expiry date in past
        $pastDate = new \DateTimeImmutable('-1 day');
        $enrollment->setExpiryDate($pastDate);
        $this->assertTrue($enrollment->isExpired());
    }
    
    public function testCanUpdateProgress(): void
    {
        $enrollment = $this->createTestEnrollment();
        $enrollment->activate();
        
        $enrollment->updateProgress(25.5);
        $this->assertEquals(25.5, $enrollment->getProgressPercentage());
        
        $enrollment->updateProgress(75.0);
        $this->assertEquals(75.0, $enrollment->getProgressPercentage());
    }
    
    public function testCannotUpdateProgressWithInvalidValue(): void
    {
        $enrollment = $this->createTestEnrollment();
        
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Progress must be between 0 and 100');
        
        $enrollment->updateProgress(-10);
    }
    
    private function createTestEnrollment(): Enrollment
    {
        return Enrollment::create(
            userId: UserId::generate(),
            courseId: CourseId::generate(),
            enrolledBy: UserId::generate()
        );
    }
} 