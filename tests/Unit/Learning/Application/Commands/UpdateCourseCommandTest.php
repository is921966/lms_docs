<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Application\Commands;

use Learning\Application\Commands\UpdateCourseCommand;
use PHPUnit\Framework\TestCase;
use InvalidArgumentException;

class UpdateCourseCommandTest extends TestCase
{
    public function testCreateCommand(): void
    {
        // Arrange
        $courseId = 'course-123';
        $updates = [
            'title' => 'Updated Title',
            'description' => 'Updated Description',
            'duration_hours' => 15,
            'metadata' => ['level' => 'intermediate']
        ];
        $updatedBy = 'user-456';
        
        // Act
        $command = new UpdateCourseCommand($courseId, $updates, $updatedBy);
        
        // Assert
        $this->assertEquals($courseId, $command->getCourseId());
        $this->assertEquals($updates, $command->getUpdates());
        $this->assertEquals($updatedBy, $command->getUpdatedBy());
        $this->assertNotEmpty($command->getCommandId());
    }
    
    public function testValidation(): void
    {
        // Empty course ID
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Course ID cannot be empty');
        
        new UpdateCourseCommand('', ['title' => 'New'], 'user-123');
    }
    
    public function testEmptyUpdates(): void
    {
        // Empty updates
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('No updates provided');
        
        new UpdateCourseCommand('course-123', [], 'user-123');
    }
    
    public function testInvalidDuration(): void
    {
        // Invalid duration in updates
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Duration must be positive');
        
        new UpdateCourseCommand(
            'course-123',
            ['duration_hours' => 0],
            'user-123'
        );
    }
    
    public function testGetSpecificUpdate(): void
    {
        // Arrange
        $command = new UpdateCourseCommand(
            'course-123',
            ['title' => 'New Title', 'description' => 'New Desc'],
            'user-123'
        );
        
        // Act & Assert
        $this->assertEquals('New Title', $command->getUpdate('title'));
        $this->assertNull($command->getUpdate('non_existent'));
    }
    
    public function testHasUpdate(): void
    {
        // Arrange
        $command = new UpdateCourseCommand(
            'course-123',
            ['title' => 'New Title'],
            'user-123'
        );
        
        // Act & Assert
        $this->assertTrue($command->hasUpdate('title'));
        $this->assertFalse($command->hasUpdate('description'));
    }
} 