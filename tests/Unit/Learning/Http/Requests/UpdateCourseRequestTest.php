<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Http\Requests;

use PHPUnit\Framework\TestCase;
use Learning\Http\Requests\UpdateCourseRequest;

class UpdateCourseRequestTest extends TestCase
{
    public function testValidRequestPassesValidation(): void
    {
        // Arrange
        $data = [
            'title' => 'Updated Course Title',
            'description' => 'Updated description',
            'duration_hours' => 20,
            'price' => 99.99,
            'category_id' => '550e8400-e29b-41d4-a716-446655440000',
            'tags' => ['php', 'testing'],
            'status' => 'published'
        ];
        $request = new UpdateCourseRequest($data);

        // Act & Assert
        $this->assertTrue($request->isValid());
        $this->assertEmpty($request->getErrors());
    }

    public function testTitleValidationFailsWhenTooLong(): void
    {
        // Arrange
        $data = ['title' => str_repeat('a', 256)];
        $request = new UpdateCourseRequest($data);

        // Act & Assert
        $this->assertFalse($request->isValid());
        $this->assertArrayHasKey('title', $request->getErrors());
        $this->assertEquals('Title must not exceed 255 characters', $request->getErrors()['title']);
    }

    public function testDescriptionValidationAcceptsString(): void
    {
        // Arrange
        $data = ['description' => 'Valid description'];
        $request = new UpdateCourseRequest($data);

        // Act & Assert
        $this->assertTrue($request->isValid());
        $this->assertEmpty($request->getErrors());
    }

    public function testDurationValidationFailsWhenLessThanOne(): void
    {
        // Arrange
        $data = ['duration_hours' => 0];
        $request = new UpdateCourseRequest($data);

        // Act & Assert
        $this->assertFalse($request->isValid());
        $this->assertArrayHasKey('duration_hours', $request->getErrors());
        $this->assertEquals('Duration must be at least 1 hour', $request->getErrors()['duration_hours']);
    }

    public function testPriceValidationFailsWhenNegative(): void
    {
        // Arrange
        $data = ['price' => -10];
        $request = new UpdateCourseRequest($data);

        // Act & Assert
        $this->assertFalse($request->isValid());
        $this->assertArrayHasKey('price', $request->getErrors());
        $this->assertEquals('Price cannot be negative', $request->getErrors()['price']);
    }

    public function testCategoryIdValidationFailsWithInvalidUuid(): void
    {
        // Arrange
        $data = ['category_id' => 'invalid-uuid'];
        $request = new UpdateCourseRequest($data);

        // Act & Assert
        $this->assertFalse($request->isValid());
        $this->assertArrayHasKey('category_id', $request->getErrors());
        $this->assertEquals('Category ID must be a valid UUID', $request->getErrors()['category_id']);
    }

    public function testTagsValidationFailsWhenNotArray(): void
    {
        // Arrange
        $data = ['tags' => 'not-an-array'];
        $request = new UpdateCourseRequest($data);

        // Act & Assert
        $this->assertFalse($request->isValid());
        $this->assertArrayHasKey('tags', $request->getErrors());
        $this->assertEquals('Tags must be an array', $request->getErrors()['tags']);
    }

    public function testTagValidationFailsWhenTooLong(): void
    {
        // Arrange
        $data = ['tags' => ['valid', str_repeat('a', 51)]];
        $request = new UpdateCourseRequest($data);

        // Act & Assert
        $this->assertFalse($request->isValid());
        $this->assertArrayHasKey('tags.1', $request->getErrors());
        $this->assertEquals('Tag must not exceed 50 characters', $request->getErrors()['tags.1']);
    }

    public function testStatusValidationFailsWithInvalidStatus(): void
    {
        // Arrange
        $data = ['status' => 'invalid-status'];
        $request = new UpdateCourseRequest($data);

        // Act & Assert
        $this->assertFalse($request->isValid());
        $this->assertArrayHasKey('status', $request->getErrors());
        $this->assertEquals('Invalid course status', $request->getErrors()['status']);
    }

    public function testGettersReturnCorrectValues(): void
    {
        // Arrange
        $data = [
            'title' => 'Test Title',
            'description' => 'Test Description',
            'duration_hours' => 10,
            'price' => 50.0,
            'category_id' => '550e8400-e29b-41d4-a716-446655440000',
            'tags' => ['tag1', 'tag2'],
            'status' => 'draft'
        ];
        $request = new UpdateCourseRequest($data);

        // Act & Assert
        $this->assertEquals('Test Title', $request->getTitle());
        $this->assertEquals('Test Description', $request->getDescription());
        $this->assertEquals(10, $request->getDurationHours());
        $this->assertEquals(50.0, $request->getPrice());
        $this->assertEquals('550e8400-e29b-41d4-a716-446655440000', $request->getCategoryId());
        $this->assertEquals(['tag1', 'tag2'], $request->getTags());
        $this->assertEquals('draft', $request->getStatus());
    }

    public function testGettersReturnNullForMissingFields(): void
    {
        // Arrange
        $request = new UpdateCourseRequest([]);

        // Act & Assert
        $this->assertNull($request->getTitle());
        $this->assertNull($request->getDescription());
        $this->assertNull($request->getDurationHours());
        $this->assertNull($request->getPrice());
        $this->assertNull($request->getCategoryId());
        $this->assertNull($request->getTags());
        $this->assertNull($request->getStatus());
    }

    public function testToArrayIncludesOnlyProvidedFields(): void
    {
        // Arrange
        $data = [
            'title' => 'Test Title',
            'price' => 100.0
        ];
        $request = new UpdateCourseRequest($data);

        // Act
        $result = $request->toArray();

        // Assert
        $this->assertCount(2, $result);
        $this->assertArrayHasKey('title', $result);
        $this->assertArrayHasKey('price', $result);
        $this->assertEquals('Test Title', $result['title']);
        $this->assertEquals(100.0, $result['price']);
    }
} 