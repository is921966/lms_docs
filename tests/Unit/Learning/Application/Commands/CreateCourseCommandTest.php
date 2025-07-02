<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Application\Commands;

use Learning\Application\Commands\CreateCourseCommand;
use PHPUnit\Framework\TestCase;
use InvalidArgumentException;

class CreateCourseCommandTest extends TestCase
{
    public function testCreateCommand(): void
    {
        // Arrange
        $courseCode = 'PHP-101';
        $title = 'PHP for Beginners';
        $description = 'Learn PHP from scratch';
        $durationHours = 10;
        $instructorId = 'instructor-123';
        $metadata = ['level' => 'beginner', 'language' => 'en'];
        
        // Act
        $command = new CreateCourseCommand(
            $courseCode,
            $title,
            $description,
            $durationHours,
            $instructorId,
            $metadata
        );
        
        // Assert
        $this->assertInstanceOf(CreateCourseCommand::class, $command);
        $this->assertEquals($courseCode, $command->getCourseCode());
        $this->assertEquals($title, $command->getTitle());
        $this->assertEquals($description, $command->getDescription());
        $this->assertEquals($durationHours, $command->getDurationHours());
        $this->assertEquals($instructorId, $command->getInstructorId());
        $this->assertEquals($metadata, $command->getMetadata());
        $this->assertIsString($command->getCommandId());
        $this->assertNotEmpty($command->getCommandId());
    }
    
    public function testCreateWithMinimalData(): void
    {
        // Arrange & Act
        $command = new CreateCourseCommand(
            'PHP-101',
            'PHP Course',
            'Description',
            5,
            'instructor-123'
        );
        
        // Assert
        $this->assertEquals([], $command->getMetadata());
    }
    
    public function testValidation(): void
    {
        // Empty course code
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Course code cannot be empty');
        
        new CreateCourseCommand(
            '',
            'Title',
            'Description',
            10,
            'instructor-123'
        );
    }
    
    public function testTitleValidation(): void
    {
        // Empty title
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Title cannot be empty');
        
        new CreateCourseCommand(
            'PHP-101',
            '',
            'Description',
            10,
            'instructor-123'
        );
    }
    
    public function testDurationValidation(): void
    {
        // Invalid duration
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Duration must be positive');
        
        new CreateCourseCommand(
            'PHP-101',
            'Title',
            'Description',
            0,
            'instructor-123'
        );
    }
    
    public function testInstructorValidation(): void
    {
        // Empty instructor
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Instructor ID cannot be empty');
        
        new CreateCourseCommand(
            'PHP-101',
            'Title',
            'Description',
            10,
            ''
        );
    }
    
    public function testToArray(): void
    {
        // Arrange
        $command = new CreateCourseCommand(
            'PHP-101',
            'PHP Course',
            'Learn PHP',
            10,
            'instructor-123',
            ['level' => 'beginner']
        );
        
        // Act
        $array = $command->toArray();
        
        // Assert
        $this->assertArrayHasKey('command_id', $array);
        $this->assertArrayHasKey('course_code', $array);
        $this->assertArrayHasKey('title', $array);
        $this->assertArrayHasKey('description', $array);
        $this->assertArrayHasKey('duration_hours', $array);
        $this->assertArrayHasKey('instructor_id', $array);
        $this->assertArrayHasKey('metadata', $array);
        $this->assertArrayHasKey('created_at', $array);
        
        $this->assertEquals('PHP-101', $array['course_code']);
        $this->assertEquals('PHP Course', $array['title']);
        $this->assertEquals(['level' => 'beginner'], $array['metadata']);
    }
    
    public function testImmutability(): void
    {
        // Arrange
        $metadata = ['level' => 'beginner'];
        $command = new CreateCourseCommand(
            'PHP-101',
            'Title',
            'Description',
            10,
            'instructor-123',
            $metadata
        );
        
        // Act - Try to modify original array
        $metadata['level'] = 'advanced';
        
        // Assert - Command should not be affected
        $this->assertEquals(['level' => 'beginner'], $command->getMetadata());
    }
} 