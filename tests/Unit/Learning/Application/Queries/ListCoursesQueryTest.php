<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Application\Queries;

use Learning\Application\Queries\ListCoursesQuery;
use PHPUnit\Framework\TestCase;
use InvalidArgumentException;

class ListCoursesQueryTest extends TestCase
{
    public function testCreateQuery(): void
    {
        // Arrange & Act
        $query = new ListCoursesQuery(
            requestedBy: 'user-123',
            filters: ['status' => 'published', 'instructor' => 'instructor-456'],
            page: 2,
            perPage: 20,
            sortBy: 'title',
            sortOrder: 'asc'
        );
        
        // Assert
        $this->assertEquals('user-123', $query->getRequestedBy());
        $this->assertEquals(['status' => 'published', 'instructor' => 'instructor-456'], $query->getFilters());
        $this->assertEquals(2, $query->getPage());
        $this->assertEquals(20, $query->getPerPage());
        $this->assertEquals('title', $query->getSortBy());
        $this->assertEquals('asc', $query->getSortOrder());
    }
    
    public function testCreateWithDefaults(): void
    {
        // Arrange & Act
        $query = new ListCoursesQuery('user-123');
        
        // Assert
        $this->assertEquals([], $query->getFilters());
        $this->assertEquals(1, $query->getPage());
        $this->assertEquals(10, $query->getPerPage());
        $this->assertEquals('created_at', $query->getSortBy());
        $this->assertEquals('desc', $query->getSortOrder());
    }
    
    public function testInvalidPage(): void
    {
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Page must be positive');
        
        new ListCoursesQuery('user-123', page: 0);
    }
    
    public function testInvalidPerPage(): void
    {
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Per page must be between 1 and 100');
        
        new ListCoursesQuery('user-123', perPage: 101);
    }
    
    public function testInvalidSortOrder(): void
    {
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Sort order must be asc or desc');
        
        new ListCoursesQuery('user-123', sortOrder: 'invalid');
    }
    
    public function testGetOffset(): void
    {
        // Arrange
        $query = new ListCoursesQuery('user-123', page: 3, perPage: 20);
        
        // Act & Assert
        $this->assertEquals(40, $query->getOffset()); // (3-1) * 20
    }
    
    public function testHasFilter(): void
    {
        // Arrange
        $query = new ListCoursesQuery(
            'user-123',
            filters: ['status' => 'published', 'level' => 'beginner']
        );
        
        // Act & Assert
        $this->assertTrue($query->hasFilter('status'));
        $this->assertTrue($query->hasFilter('level'));
        $this->assertFalse($query->hasFilter('instructor'));
    }
    
    public function testGetFilter(): void
    {
        // Arrange
        $query = new ListCoursesQuery(
            'user-123',
            filters: ['status' => 'published']
        );
        
        // Act & Assert
        $this->assertEquals('published', $query->getFilter('status'));
        $this->assertNull($query->getFilter('non_existent'));
    }
} 