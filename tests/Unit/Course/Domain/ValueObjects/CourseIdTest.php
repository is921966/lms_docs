<?php

declare(strict_types=1);

namespace Tests\Unit\Course\Domain\ValueObjects;

use PHPUnit\Framework\TestCase;
use App\Course\Domain\ValueObjects\CourseId;
use App\Common\Exceptions\InvalidArgumentException;

class CourseIdTest extends TestCase
{
    public function testCanCreateValidCourseId(): void
    {
        // Given
        $value = 'CRS-123e4567-e89b-12d3-a456-426614174000';
        
        // When
        $courseId = new CourseId($value);
        
        // Then
        $this->assertEquals($value, $courseId->value());
        $this->assertEquals($value, (string)$courseId);
    }
    
    public function testCanGenerateNewCourseId(): void
    {
        // When
        $courseId = CourseId::generate();
        
        // Then
        $this->assertStringStartsWith('CRS-', $courseId->value());
        $this->assertMatchesRegularExpression('/^CRS-[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i', $courseId->value());
    }
    
    public function testThrowsExceptionForEmptyValue(): void
    {
        // Then
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('CourseId cannot be empty');
        
        // When
        new CourseId('');
    }
    
    public function testThrowsExceptionForInvalidFormat(): void
    {
        // Then
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid CourseId format');
        
        // When
        new CourseId('invalid-id');
    }
    
    public function testEquality(): void
    {
        // Given
        $id1 = new CourseId('CRS-123e4567-e89b-12d3-a456-426614174000');
        $id2 = new CourseId('CRS-123e4567-e89b-12d3-a456-426614174000');
        $id3 = new CourseId('CRS-987e4567-e89b-12d3-a456-426614174000');
        
        // Then
        $this->assertTrue($id1->equals($id2));
        $this->assertFalse($id1->equals($id3));
    }
} 