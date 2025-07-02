<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Domain\ValueObjects;

use Learning\Domain\ValueObjects\CourseCode;
use PHPUnit\Framework\TestCase;
use InvalidArgumentException;

class CourseCodeTest extends TestCase
{
    public function testCreateFromString(): void
    {
        // Arrange
        $code = 'PHP-101';
        
        // Act
        $courseCode = CourseCode::fromString($code);
        
        // Assert
        $this->assertInstanceOf(CourseCode::class, $courseCode);
        $this->assertEquals($code, $courseCode->getValue());
        $this->assertEquals($code, (string)$courseCode);
    }
    
    public function testGenerate(): void
    {
        // Act
        $courseCode1 = CourseCode::generate('PHP');
        $courseCode2 = CourseCode::generate('PHP');
        
        // Assert
        $this->assertInstanceOf(CourseCode::class, $courseCode1);
        $this->assertInstanceOf(CourseCode::class, $courseCode2);
        $this->assertStringStartsWith('PHP-', $courseCode1->getValue());
        $this->assertNotEquals($courseCode1->getValue(), $courseCode2->getValue());
        $this->assertMatchesRegularExpression('/^[A-Z]+-\d{3,6}$/', $courseCode1->getValue());
    }
    
    public function testGenerateWithoutPrefix(): void
    {
        // Act
        $courseCode = CourseCode::generate();
        
        // Assert
        $this->assertMatchesRegularExpression('/^CRS-\d{3,6}$/', $courseCode->getValue());
    }
    
    public function testEquals(): void
    {
        // Arrange
        $code = 'PHP-101';
        $courseCode1 = CourseCode::fromString($code);
        $courseCode2 = CourseCode::fromString($code);
        $courseCode3 = CourseCode::fromString('JAVA-101');
        
        // Act & Assert
        $this->assertTrue($courseCode1->equals($courseCode2));
        $this->assertFalse($courseCode1->equals($courseCode3));
    }
    
    public function testThrowsExceptionForEmptyCode(): void
    {
        // Arrange & Assert
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Course code cannot be empty');
        
        // Act
        CourseCode::fromString('');
    }
    
    public function testThrowsExceptionForInvalidFormat(): void
    {
        // Arrange & Assert
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Course code must be in format: PREFIX-NUMBER (e.g., PHP-101)');
        
        // Act
        CourseCode::fromString('invalid_code');
    }
    
    public function testThrowsExceptionForTooLongCode(): void
    {
        // Arrange & Assert
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Course code cannot exceed 20 characters');
        
        // Act
        CourseCode::fromString('VERYLONGPREFIX-123456789');
    }
    
    public function testNormalizeCode(): void
    {
        // Arrange
        $code = 'php-101';
        
        // Act
        $courseCode = CourseCode::fromString($code);
        
        // Assert
        $this->assertEquals('PHP-101', $courseCode->getValue());
    }
} 