<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Application\Queries;

use Learning\Application\Queries\GetCourseByIdQuery;
use PHPUnit\Framework\TestCase;
use InvalidArgumentException;

class GetCourseByIdQueryTest extends TestCase
{
    public function testCreateQuery(): void
    {
        // Arrange & Act
        $courseId = 'course-123';
        $requestedBy = 'user-456';
        
        $query = new GetCourseByIdQuery($courseId, $requestedBy);
        
        // Assert
        $this->assertEquals($courseId, $query->getCourseId());
        $this->assertEquals($requestedBy, $query->getRequestedBy());
        $this->assertNotEmpty($query->getQueryId());
        $this->assertInstanceOf(\DateTimeImmutable::class, $query->getCreatedAt());
    }
    
    public function testCourseIdValidation(): void
    {
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Course ID cannot be empty');
        
        new GetCourseByIdQuery('', 'user-123');
    }
    
    public function testRequestedByValidation(): void
    {
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Requested by cannot be empty');
        
        new GetCourseByIdQuery('course-123', '');
    }
    
    public function testImmutability(): void
    {
        // Arrange
        $query = new GetCourseByIdQuery('course-123', 'user-456');
        $queryId = $query->getQueryId();
        $createdAt = $query->getCreatedAt();
        
        // Act
        sleep(1); // Ensure time passes
        
        // Assert - values should not change
        $this->assertEquals($queryId, $query->getQueryId());
        $this->assertEquals($createdAt, $query->getCreatedAt());
    }
} 