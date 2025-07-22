<?php

declare(strict_types=1);

namespace Tests\Unit\Course\Domain\ValueObjects;

use PHPUnit\Framework\TestCase;
use App\Course\Domain\ValueObjects\CourseCode;
use App\Common\Exceptions\InvalidArgumentException;

class CourseCodeTest extends TestCase
{
    public function testCanCreateValidCourseCode(): void
    {
        // Given
        $value = 'CS101';
        
        // When
        $courseCode = new CourseCode($value);
        
        // Then
        $this->assertEquals($value, $courseCode->value());
        $this->assertEquals($value, (string)$courseCode);
    }
    
    public function testConvertsToUpperCase(): void
    {
        // Given
        $value = 'cs101';
        
        // When
        $courseCode = new CourseCode($value);
        
        // Then
        $this->assertEquals('CS101', $courseCode->value());
    }
    
    public function testThrowsExceptionForEmptyValue(): void
    {
        // Then
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('CourseCode cannot be empty');
        
        // When
        new CourseCode('');
    }
    
    public function testThrowsExceptionForTooShortCode(): void
    {
        // Then
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('CourseCode must be at least 3 characters long');
        
        // When
        new CourseCode('AB');
    }
    
    public function testThrowsExceptionForTooLongCode(): void
    {
        // Then
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('CourseCode cannot exceed 20 characters');
        
        // When
        new CourseCode('VERYLONGCOURSECODETHATEXCEEDSLIMIT');
    }
    
    public function testThrowsExceptionForInvalidCharacters(): void
    {
        // Then
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('CourseCode can only contain letters, numbers, and hyphens');
        
        // When
        new CourseCode('CS@101');
    }
    
    public function testEquality(): void
    {
        // Given
        $code1 = new CourseCode('CS101');
        $code2 = new CourseCode('cs101'); // Should be converted to uppercase
        $code3 = new CourseCode('CS102');
        
        // Then
        $this->assertTrue($code1->equals($code2));
        $this->assertFalse($code1->equals($code3));
    }
} 