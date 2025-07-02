<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Domain;

use Learning\Domain\Progress;
use Learning\Domain\ValueObjects\ProgressId;
use Learning\Domain\ValueObjects\ProgressStatus;
use Learning\Domain\ValueObjects\EnrollmentId;
use Learning\Domain\ValueObjects\LessonId;
use PHPUnit\Framework\TestCase;

class ProgressTest extends TestCase
{
    public function testCanBeCreated(): void
    {
        $enrollmentId = EnrollmentId::generate();
        $lessonId = LessonId::generate();
        
        $progress = Progress::create(
            enrollmentId: $enrollmentId,
            lessonId: $lessonId
        );
        
        $this->assertInstanceOf(Progress::class, $progress);
        $this->assertInstanceOf(ProgressId::class, $progress->getId());
        $this->assertTrue($progress->getEnrollmentId()->equals($enrollmentId));
        $this->assertTrue($progress->getLessonId()->equals($lessonId));
        $this->assertEquals(ProgressStatus::NOT_STARTED, $progress->getStatus());
        $this->assertEquals(0.0, $progress->getPercentage());
        $this->assertNull($progress->getStartedAt());
        $this->assertNull($progress->getCompletedAt());
        $this->assertEquals(0, $progress->getAttemptCount());
    }
    
    public function testCanBeStarted(): void
    {
        $progress = $this->createTestProgress();
        
        $progress->start();
        
        $this->assertEquals(ProgressStatus::IN_PROGRESS, $progress->getStatus());
        $this->assertNotNull($progress->getStartedAt());
        $this->assertEquals(1, $progress->getAttemptCount());
    }
    
    public function testCanBeRestarted(): void
    {
        $progress = $this->createTestProgress();
        
        $progress->start();
        $firstStartTime = $progress->getStartedAt();
        
        sleep(1); // Ensure time difference
        $progress->restart();
        
        $this->assertEquals(ProgressStatus::IN_PROGRESS, $progress->getStatus());
        $this->assertNotEquals($firstStartTime, $progress->getStartedAt());
        $this->assertEquals(2, $progress->getAttemptCount());
        $this->assertEquals(0.0, $progress->getPercentage());
    }
    
    public function testCanUpdatePercentage(): void
    {
        $progress = $this->createTestProgress();
        $progress->start();
        
        $progress->updatePercentage(50.5);
        
        $this->assertEquals(50.5, $progress->getPercentage());
        $this->assertEquals(ProgressStatus::IN_PROGRESS, $progress->getStatus());
        
        $progress->updatePercentage(100);
        
        $this->assertEquals(100.0, $progress->getPercentage());
        $this->assertEquals(ProgressStatus::COMPLETED, $progress->getStatus());
        $this->assertNotNull($progress->getCompletedAt());
    }
    
    public function testCannotUpdatePercentageWithInvalidValue(): void
    {
        $progress = $this->createTestProgress();
        
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Percentage must be between 0 and 100');
        
        $progress->updatePercentage(150);
    }
    
    public function testCanRecordScore(): void
    {
        $progress = $this->createTestProgress();
        $progress->start();
        
        $progress->recordScore(85.5);
        
        $this->assertEquals(85.5, $progress->getScore());
        $this->assertEquals(85.5, $progress->getHighestScore());
        
        // Lower score doesn't update highest
        $progress->recordScore(70);
        $this->assertEquals(70.0, $progress->getScore());
        $this->assertEquals(85.5, $progress->getHighestScore());
        
        // Higher score updates highest
        $progress->recordScore(95);
        $this->assertEquals(95.0, $progress->getScore());
        $this->assertEquals(95.0, $progress->getHighestScore());
    }
    
    public function testCanMarkAsFailed(): void
    {
        $progress = $this->createTestProgress();
        $progress->start();
        
        $progress->markAsFailed();
        
        $this->assertEquals(ProgressStatus::FAILED, $progress->getStatus());
        $this->assertNotNull($progress->getFailedAt());
    }
    
    public function testCanCalculateTimeSpent(): void
    {
        $progress = $this->createTestProgress();
        
        // Not started
        $this->assertEquals(0, $progress->getTimeSpentMinutes());
        
        // In progress
        $progress->start();
        $this->assertGreaterThanOrEqual(0, $progress->getTimeSpentMinutes());
        
        // Add time
        $progress->addTimeSpent(30);
        $this->assertEquals(30, $progress->getTimeSpentMinutes());
        
        $progress->addTimeSpent(15);
        $this->assertEquals(45, $progress->getTimeSpentMinutes());
    }
    
    private function createTestProgress(): Progress
    {
        return Progress::create(
            enrollmentId: EnrollmentId::generate(),
            lessonId: LessonId::generate()
        );
    }
} 