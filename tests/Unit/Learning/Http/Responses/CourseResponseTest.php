<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Http\Responses;

use PHPUnit\Framework\TestCase;
use Learning\Http\Responses\CourseResponse;
use Learning\Application\DTO\CourseDTO;

class CourseResponseTest extends TestCase
{
    public function testFromDtoCreatesCorrectResponse(): void
    {
        // Arrange
        $courseDto = new CourseDTO(
            id: '123e4567-e89b-12d3-a456-426614174000',
            courseCode: 'PHP-101',
            title: 'PHP Basics',
            description: 'Learn PHP fundamentals',
            durationHours: 20,
            instructorId: '550e8400-e29b-41d4-a716-446655440000',
            status: 'published',
            metadata: ['level' => 'beginner'],
            createdAt: '2023-01-01T00:00:00+00:00',
            updatedAt: '2023-01-15T00:00:00+00:00'
        );

        // Act
        $response = CourseResponse::fromDto($courseDto);

        // Assert
        $this->assertInstanceOf(CourseResponse::class, $response);
        $this->assertEquals('123e4567-e89b-12d3-a456-426614174000', $response->getId());
        $this->assertEquals('PHP-101', $response->getCourseCode());
        $this->assertEquals('PHP Basics', $response->getTitle());
        $this->assertEquals('Learn PHP fundamentals', $response->getDescription());
        $this->assertEquals(20, $response->getDurationHours());
        $this->assertEquals('550e8400-e29b-41d4-a716-446655440000', $response->getInstructorId());
        $this->assertEquals('published', $response->getStatus());
        $this->assertEquals(['level' => 'beginner'], $response->getMetadata());
        $this->assertEquals('2023-01-01T00:00:00+00:00', $response->getCreatedAt());
        $this->assertEquals('2023-01-15T00:00:00+00:00', $response->getUpdatedAt());
    }

    public function testToArrayReturnsCorrectStructure(): void
    {
        // Arrange
        $courseDto = new CourseDTO(
            id: '123e4567-e89b-12d3-a456-426614174000',
            courseCode: 'PHP-101',
            title: 'PHP Basics',
            description: 'Learn PHP fundamentals',
            durationHours: 20,
            instructorId: '550e8400-e29b-41d4-a716-446655440000',
            status: 'published',
            metadata: ['level' => 'beginner'],
            createdAt: '2023-01-01T00:00:00+00:00',
            updatedAt: '2023-01-15T00:00:00+00:00'
        );
        $response = CourseResponse::fromDto($courseDto);

        // Act
        $array = $response->toArray();

        // Assert
        $this->assertIsArray($array);
        $this->assertArrayHasKey('id', $array);
        $this->assertArrayHasKey('course_code', $array);
        $this->assertArrayHasKey('title', $array);
        $this->assertArrayHasKey('description', $array);
        $this->assertArrayHasKey('duration_hours', $array);
        $this->assertArrayHasKey('instructor_id', $array);
        $this->assertArrayHasKey('status', $array);
        $this->assertArrayHasKey('metadata', $array);
        $this->assertArrayHasKey('created_at', $array);
        $this->assertArrayHasKey('updated_at', $array);

        // Verify values
        $this->assertEquals('123e4567-e89b-12d3-a456-426614174000', $array['id']);
        $this->assertEquals('PHP-101', $array['course_code']);
        $this->assertEquals('PHP Basics', $array['title']);
        $this->assertEquals('Learn PHP fundamentals', $array['description']);
        $this->assertEquals(20, $array['duration_hours']);
        $this->assertEquals('550e8400-e29b-41d4-a716-446655440000', $array['instructor_id']);
        $this->assertEquals('published', $array['status']);
        $this->assertEquals(['level' => 'beginner'], $array['metadata']);
        $this->assertEquals('2023-01-01T00:00:00+00:00', $array['created_at']);
        $this->assertEquals('2023-01-15T00:00:00+00:00', $array['updated_at']);
    }

    public function testJsonSerializeReturnsArray(): void
    {
        // Arrange
        $courseDto = new CourseDTO(
            id: '123e4567-e89b-12d3-a456-426614174000',
            courseCode: 'PHP-101',
            title: 'PHP Basics',
            description: 'Learn PHP fundamentals',
            durationHours: 20,
            instructorId: '550e8400-e29b-41d4-a716-446655440000',
            status: 'draft',
            metadata: []
        );
        $response = CourseResponse::fromDto($courseDto);

        // Act
        $json = json_encode($response);
        $decoded = json_decode($json, true);

        // Assert
        $this->assertIsArray($decoded);
        $this->assertEquals('123e4567-e89b-12d3-a456-426614174000', $decoded['id']);
        $this->assertEquals('PHP-101', $decoded['course_code']);
        $this->assertEquals('PHP Basics', $decoded['title']);
    }

    public function testFromCollectionCreatesMultipleResponses(): void
    {
        // Arrange
        $dtos = [
            new CourseDTO(
                id: '123e4567-e89b-12d3-a456-426614174000',
                courseCode: 'PHP-101',
                title: 'PHP Basics',
                description: 'Learn PHP',
                durationHours: 20,
                instructorId: 'inst-1',
                status: 'published',
                metadata: []
            ),
            new CourseDTO(
                id: '223e4567-e89b-12d3-a456-426614174000',
                courseCode: 'JS-101',
                title: 'JavaScript Basics',
                description: 'Learn JS',
                durationHours: 15,
                instructorId: 'inst-2',
                status: 'draft',
                metadata: []
            )
        ];

        // Act
        $responses = CourseResponse::fromCollection($dtos);

        // Assert
        $this->assertIsArray($responses);
        $this->assertCount(2, $responses);
        $this->assertInstanceOf(CourseResponse::class, $responses[0]);
        $this->assertInstanceOf(CourseResponse::class, $responses[1]);
        $this->assertEquals('PHP-101', $responses[0]->getCourseCode());
        $this->assertEquals('JS-101', $responses[1]->getCourseCode());
    }

    public function testHandlesNullTimestamps(): void
    {
        // Arrange
        $courseDto = new CourseDTO(
            id: '123e4567-e89b-12d3-a456-426614174000',
            courseCode: 'PHP-101',
            title: 'PHP Basics',
            description: 'Learn PHP fundamentals',
            durationHours: 20,
            instructorId: '550e8400-e29b-41d4-a716-446655440000',
            status: 'draft',
            metadata: [],
            createdAt: null,
            updatedAt: null
        );

        // Act
        $response = CourseResponse::fromDto($courseDto);
        $array = $response->toArray();

        // Assert
        $this->assertNull($response->getCreatedAt());
        $this->assertNull($response->getUpdatedAt());
        $this->assertNull($array['created_at']);
        $this->assertNull($array['updated_at']);
    }
} 