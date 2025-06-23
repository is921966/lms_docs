<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Domain\ValueObjects;

use App\Learning\Domain\ValueObjects\ProgressStatus;
use PHPUnit\Framework\TestCase;

class ProgressStatusTest extends TestCase
{
    public function testCanBeCreatedWithValidStatuses(): void
    {
        $notStarted = ProgressStatus::NOT_STARTED;
        $inProgress = ProgressStatus::IN_PROGRESS;
        $completed = ProgressStatus::COMPLETED;
        $failed = ProgressStatus::FAILED;
        
        $this->assertEquals('not_started', $notStarted->value);
        $this->assertEquals('in_progress', $inProgress->value);
        $this->assertEquals('completed', $completed->value);
        $this->assertEquals('failed', $failed->value);
    }
    
    public function testCanGetLabel(): void
    {
        $this->assertEquals('Не начато', ProgressStatus::NOT_STARTED->label());
        $this->assertEquals('В процессе', ProgressStatus::IN_PROGRESS->label());
        $this->assertEquals('Завершено', ProgressStatus::COMPLETED->label());
        $this->assertEquals('Провалено', ProgressStatus::FAILED->label());
    }
    
    public function testCanCheckIfCompleted(): void
    {
        $this->assertFalse(ProgressStatus::NOT_STARTED->isCompleted());
        $this->assertFalse(ProgressStatus::IN_PROGRESS->isCompleted());
        $this->assertTrue(ProgressStatus::COMPLETED->isCompleted());
        $this->assertFalse(ProgressStatus::FAILED->isCompleted());
    }
    
    public function testCanCheckIfActive(): void
    {
        $this->assertFalse(ProgressStatus::NOT_STARTED->isActive());
        $this->assertTrue(ProgressStatus::IN_PROGRESS->isActive());
        $this->assertFalse(ProgressStatus::COMPLETED->isActive());
        $this->assertFalse(ProgressStatus::FAILED->isActive());
    }
    
    public function testCanGetFromPercentage(): void
    {
        $this->assertEquals(ProgressStatus::NOT_STARTED, ProgressStatus::fromPercentage(0));
        $this->assertEquals(ProgressStatus::IN_PROGRESS, ProgressStatus::fromPercentage(1));
        $this->assertEquals(ProgressStatus::IN_PROGRESS, ProgressStatus::fromPercentage(50));
        $this->assertEquals(ProgressStatus::IN_PROGRESS, ProgressStatus::fromPercentage(99));
        $this->assertEquals(ProgressStatus::COMPLETED, ProgressStatus::fromPercentage(100));
    }
    
    public function testThrowsExceptionForInvalidPercentage(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Percentage must be between 0 and 100');
        
        ProgressStatus::fromPercentage(-1);
    }
} 