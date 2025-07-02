<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Application\Commands;

use Learning\Application\Commands\EnrollUserCommand;
use PHPUnit\Framework\TestCase;
use InvalidArgumentException;

class EnrollUserCommandTest extends TestCase
{
    public function testCreateCommand(): void
    {
        // Arrange
        $userId = 'user-123';
        $courseId = 'course-456';
        $enrolledBy = 'admin-789';
        $enrollmentType = 'mandatory';
        $metadata = ['department' => 'IT', 'reason' => 'job_requirement'];
        
        // Act
        $command = new EnrollUserCommand(
            $userId,
            $courseId,
            $enrolledBy,
            $enrollmentType,
            $metadata
        );
        
        // Assert
        $this->assertEquals($userId, $command->getUserId());
        $this->assertEquals($courseId, $command->getCourseId());
        $this->assertEquals($enrolledBy, $command->getEnrolledBy());
        $this->assertEquals($enrollmentType, $command->getEnrollmentType());
        $this->assertEquals($metadata, $command->getMetadata());
        $this->assertNotEmpty($command->getCommandId());
    }
    
    public function testCreateWithDefaults(): void
    {
        // Arrange & Act
        $command = new EnrollUserCommand(
            'user-123',
            'course-456',
            'admin-789'
        );
        
        // Assert
        $this->assertEquals('voluntary', $command->getEnrollmentType());
        $this->assertEquals([], $command->getMetadata());
    }
    
    public function testSelfEnrollment(): void
    {
        // Arrange & Act
        $command = new EnrollUserCommand(
            'user-123',
            'course-456',
            'user-123' // Same as userId
        );
        
        // Assert
        $this->assertTrue($command->isSelfEnrollment());
    }
    
    public function testUserIdValidation(): void
    {
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('User ID cannot be empty');
        
        new EnrollUserCommand('', 'course-456', 'admin-789');
    }
    
    public function testCourseIdValidation(): void
    {
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Course ID cannot be empty');
        
        new EnrollUserCommand('user-123', '', 'admin-789');
    }
    
    public function testInvalidEnrollmentType(): void
    {
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid enrollment type');
        
        new EnrollUserCommand(
            'user-123',
            'course-456',
            'admin-789',
            'invalid_type'
        );
    }
} 