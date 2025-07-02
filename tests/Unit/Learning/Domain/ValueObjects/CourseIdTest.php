<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Domain\ValueObjects;

use Learning\Domain\ValueObjects\CourseId;
use PHPUnit\Framework\TestCase;
use InvalidArgumentException;

class CourseIdTest extends TestCase
{
    public function testCreateFromString(): void
    {
        // Arrange
        $id = 'course-123';
        
        // Act
        $courseId = CourseId::fromString($id);
        
        // Assert
        $this->assertInstanceOf(CourseId::class, $courseId);
        $this->assertEquals($id, $courseId->getValue());
        $this->assertEquals($id, (string)$courseId);
    }
    
    public function testGenerate(): void
    {
        // Act
        $courseId1 = CourseId::generate();
        $courseId2 = CourseId::generate();
        
        // Assert
        $this->assertInstanceOf(CourseId::class, $courseId1);
        $this->assertInstanceOf(CourseId::class, $courseId2);
        $this->assertNotEquals($courseId1->getValue(), $courseId2->getValue());
        $this->assertMatchesRegularExpression('/^[a-f0-9\-]{36}$/', $courseId1->getValue());
    }
    
    public function testEquals(): void
    {
        // Arrange
        $id = 'course-123';
        $courseId1 = CourseId::fromString($id);
        $courseId2 = CourseId::fromString($id);
        $courseId3 = CourseId::generate();
        
        // Act & Assert
        $this->assertTrue($courseId1->equals($courseId2));
        $this->assertFalse($courseId1->equals($courseId3));
    }
    
    public function testThrowsExceptionForEmptyId(): void
    {
        // Arrange & Assert
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Course ID cannot be empty');
        
        // Act
        CourseId::fromString('');
    }
    
    public function testThrowsExceptionForInvalidId(): void
    {
        // Arrange & Assert
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Course ID can only contain letters, numbers, and hyphens');
        
        // Act
        CourseId::fromString('course@123');
    }
    
    public function testSerializationAndDeserialization(): void
    {
        // Arrange
        $courseId = CourseId::generate();
        
        // Act
        $serialized = serialize($courseId);
        $deserialized = unserialize($serialized);
        
        // Assert
        $this->assertTrue($courseId->equals($deserialized));
    }
} 