<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Application\Commands;

use Learning\Application\Commands\PublishCourseCommand;
use PHPUnit\Framework\TestCase;
use InvalidArgumentException;

class PublishCourseCommandTest extends TestCase
{
    public function testCreateCommand(): void
    {
        // Arrange
        $courseId = 'course-123';
        $publishedBy = 'admin-456';
        $publishDate = new \DateTimeImmutable('+1 hour');
        $notifyStudents = true;
        
        // Act
        $command = new PublishCourseCommand(
            $courseId,
            $publishedBy,
            $publishDate,
            $notifyStudents
        );
        
        // Assert
        $this->assertEquals($courseId, $command->getCourseId());
        $this->assertEquals($publishedBy, $command->getPublishedBy());
        $this->assertEquals($publishDate, $command->getPublishDate());
        $this->assertTrue($command->shouldNotifyStudents());
        $this->assertNotEmpty($command->getCommandId());
    }
    
    public function testCreateWithDefaults(): void
    {
        // Arrange & Act
        $command = new PublishCourseCommand(
            'course-123',
            'admin-456'
        );
        
        // Assert
        $this->assertInstanceOf(\DateTimeImmutable::class, $command->getPublishDate());
        $this->assertFalse($command->shouldNotifyStudents());
    }
    
    public function testValidation(): void
    {
        // Empty course ID
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Course ID cannot be empty');
        
        new PublishCourseCommand('', 'admin-123');
    }
    
    public function testPublishedByValidation(): void
    {
        // Empty published by
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Published by cannot be empty');
        
        new PublishCourseCommand('course-123', '');
    }
    
    public function testPastPublishDate(): void
    {
        // Past publish date
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Publish date cannot be in the past');
        
        new PublishCourseCommand(
            'course-123',
            'admin-456',
            new \DateTimeImmutable('2020-01-01')
        );
    }
} 