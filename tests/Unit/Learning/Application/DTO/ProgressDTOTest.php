<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Application\DTO;

use Learning\Application\DTO\ProgressDTO;
use Learning\Domain\Progress;
use Learning\Domain\ValueObjects\EnrollmentId;
use Learning\Domain\ValueObjects\LessonId;
use PHPUnit\Framework\TestCase;

class ProgressDTOTest extends TestCase
{
    public function testCanBeCreatedFromArray(): void
    {
        $data = [
            'id' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            'enrollmentId' => 'e1d2e3f4-a5b6-4789-0123-456789abcdef',
            'lessonId' => 'l1d2e3f4-a5b6-4789-0123-456789abcdef',
            'status' => 'in_progress',
            'percentage' => 75.5,
            'score' => 85.0,
            'highestScore' => 90.0,
            'attemptCount' => 2,
            'timeSpentMinutes' => 45,
            'startedAt' => '2024-01-15T10:00:00+00:00',
            'completedAt' => null
        ];
        
        $dto = ProgressDTO::fromArray($data);
        
        $this->assertEquals($data['id'], $dto->id);
        $this->assertEquals($data['enrollmentId'], $dto->enrollmentId);
        $this->assertEquals($data['lessonId'], $dto->lessonId);
        $this->assertEquals($data['status'], $dto->status);
        $this->assertEquals($data['percentage'], $dto->percentage);
        $this->assertEquals($data['score'], $dto->score);
        $this->assertEquals($data['highestScore'], $dto->highestScore);
        $this->assertEquals($data['attemptCount'], $dto->attemptCount);
        $this->assertEquals($data['timeSpentMinutes'], $dto->timeSpentMinutes);
        $this->assertEquals($data['startedAt'], $dto->startedAt);
        $this->assertNull($dto->completedAt);
    }
    
    public function testCanBeCreatedFromDomainEntity(): void
    {
        $progress = $this->createTestProgress();
        $progress->start();
        $progress->updatePercentage(50.0);
        $progress->recordScore(80.0);
        $progress->addTimeSpent(30);
        
        $dto = ProgressDTO::fromEntity($progress);
        
        $this->assertEquals($progress->getId()->getValue(), $dto->id);
        $this->assertEquals($progress->getEnrollmentId()->getValue(), $dto->enrollmentId);
        $this->assertEquals($progress->getLessonId()->getValue(), $dto->lessonId);
        $this->assertEquals('in_progress', $dto->status);
        $this->assertEquals(50.0, $dto->percentage);
        $this->assertEquals(80.0, $dto->score);
        $this->assertEquals(80.0, $dto->highestScore);
        $this->assertEquals(1, $dto->attemptCount);
        $this->assertEquals(30, $dto->timeSpentMinutes);
        $this->assertNotNull($dto->startedAt);
    }
    
    public function testCanConvertToArray(): void
    {
        $dto = new ProgressDTO(
            id: 'progress-123',
            enrollmentId: 'enrollment-456',
            lessonId: 'lesson-789',
            status: 'completed',
            percentage: 100.0,
            score: 95.0,
            highestScore: 95.0,
            attemptCount: 3,
            timeSpentMinutes: 60,
            startedAt: '2024-01-01T10:00:00+00:00',
            completedAt: '2024-01-01T11:00:00+00:00',
            failedAt: null,
            createdAt: '2024-01-01T09:00:00+00:00',
            updatedAt: '2024-01-01T11:00:00+00:00'
        );
        
        $array = $dto->toArray();
        
        $this->assertIsArray($array);
        $this->assertEquals($dto->id, $array['id']);
        $this->assertEquals('completed', $array['status']);
        $this->assertEquals(100.0, $array['percentage']);
        $this->assertEquals(95.0, $array['score']);
        $this->assertEquals(3, $array['attemptCount']);
        $this->assertNotNull($array['completedAt']);
    }
    
    public function testCanDetermineIfPassed(): void
    {
        // Completed with good score
        $passedDto = new ProgressDTO(
            id: '1',
            enrollmentId: 'e1',
            lessonId: 'l1',
            status: 'completed',
            percentage: 100.0,
            score: 85.0,
            highestScore: 85.0,
            attemptCount: 1,
            timeSpentMinutes: 30,
            startedAt: '2024-01-01T10:00:00+00:00',
            completedAt: '2024-01-01T10:30:00+00:00',
            failedAt: null,
            createdAt: null,
            updatedAt: null
        );
        $this->assertTrue($passedDto->isPassed(80.0));
        $this->assertFalse($passedDto->isPassed(90.0));
        
        // Failed status
        $failedDto = new ProgressDTO(
            id: '2',
            enrollmentId: 'e1',
            lessonId: 'l2',
            status: 'failed',
            percentage: 50.0,
            score: 45.0,
            highestScore: 45.0,
            attemptCount: 3,
            timeSpentMinutes: 90,
            startedAt: '2024-01-01T10:00:00+00:00',
            completedAt: null,
            failedAt: '2024-01-01T11:30:00+00:00',
            createdAt: null,
            updatedAt: null
        );
        $this->assertFalse($failedDto->isPassed(60.0));
    }
    
    private function createTestProgress(): Progress
    {
        return Progress::create(
            enrollmentId: EnrollmentId::generate(),
            lessonId: LessonId::generate()
        );
    }
} 