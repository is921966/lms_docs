<?php

declare(strict_types=1);

namespace Tests\Unit\Course\Domain\Entities;

use PHPUnit\Framework\TestCase;
use App\Course\Domain\Entities\Module;
use App\Course\Domain\ValueObjects\CourseId;
use App\Common\Exceptions\InvalidArgumentException;

class ModuleTest extends TestCase
{
    public function testCanCreateModule(): void
    {
        // Given
        $courseId = CourseId::generate();
        $title = 'Introduction to Programming';
        $description = 'Learn basic programming concepts';
        $order = 1;
        
        // When
        $module = new Module(
            $courseId,
            $title,
            $description,
            $order
        );
        
        // Then
        $this->assertEquals($courseId, $module->courseId());
        $this->assertEquals($title, $module->title());
        $this->assertEquals($description, $module->description());
        $this->assertEquals($order, $module->order());
        $this->assertNotNull($module->id());
        $this->assertInstanceOf(\DateTimeImmutable::class, $module->createdAt());
    }
    
    public function testThrowsExceptionForEmptyTitle(): void
    {
        // Then
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Module title cannot be empty');
        
        // When
        new Module(
            CourseId::generate(),
            '',
            'Description',
            1
        );
    }
    
    public function testThrowsExceptionForInvalidOrder(): void
    {
        // Then
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Module order must be positive');
        
        // When
        new Module(
            CourseId::generate(),
            'Title',
            'Description',
            0
        );
    }
    
    public function testCanUpdateOrder(): void
    {
        // Given
        $module = new Module(
            CourseId::generate(),
            'Module 1',
            'Description',
            1
        );
        
        // When
        $module->updateOrder(3);
        
        // Then
        $this->assertEquals(3, $module->order());
    }
    
    public function testCanUpdateDetails(): void
    {
        // Given
        $module = new Module(
            CourseId::generate(),
            'Old Title',
            'Old Description',
            1
        );
        
        // When
        $module->updateDetails('New Title', 'New Description');
        
        // Then
        $this->assertEquals('New Title', $module->title());
        $this->assertEquals('New Description', $module->description());
    }
} 