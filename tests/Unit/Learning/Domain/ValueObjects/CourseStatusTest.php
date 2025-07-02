<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Domain\ValueObjects;

use Learning\Domain\ValueObjects\CourseStatus;
use PHPUnit\Framework\TestCase;
use InvalidArgumentException;

class CourseStatusTest extends TestCase
{
    public function testCreateStatuses(): void
    {
        // Act & Assert
        $draft = CourseStatus::draft();
        $this->assertEquals('draft', $draft->getValue());
        $this->assertEquals('Draft', $draft->getDisplayName());
        $this->assertTrue($draft->isDraft());
        $this->assertFalse($draft->isPublished());
        $this->assertTrue($draft->canEnroll());
        
        $published = CourseStatus::published();
        $this->assertEquals('published', $published->getValue());
        $this->assertEquals('Published', $published->getDisplayName());
        $this->assertTrue($published->isPublished());
        $this->assertTrue($published->canEnroll());
        
        $archived = CourseStatus::archived();
        $this->assertEquals('archived', $archived->getValue());
        $this->assertEquals('Archived', $archived->getDisplayName());
        $this->assertTrue($archived->isArchived());
        $this->assertFalse($archived->canEnroll());
        
        $underReview = CourseStatus::underReview();
        $this->assertEquals('under_review', $underReview->getValue());
        $this->assertEquals('Under Review', $underReview->getDisplayName());
        $this->assertTrue($underReview->isUnderReview());
        $this->assertFalse($underReview->canEnroll());
    }
    
    public function testFromString(): void
    {
        // Act & Assert
        $draft = CourseStatus::fromString('draft');
        $this->assertTrue($draft->isDraft());
        
        // Test case insensitive
        $published = CourseStatus::fromString('PUBLISHED');
        $this->assertTrue($published->isPublished());
        
        // Test with spaces
        $underReview = CourseStatus::fromString(' under_review ');
        $this->assertTrue($underReview->isUnderReview());
    }
    
    public function testTransitions(): void
    {
        // Arrange
        $draft = CourseStatus::draft();
        $published = CourseStatus::published();
        $archived = CourseStatus::archived();
        $underReview = CourseStatus::underReview();
        
        // Act & Assert
        // Draft can transition to under_review or published
        $this->assertTrue($draft->canTransitionTo($underReview));
        $this->assertTrue($draft->canTransitionTo($published));
        $this->assertFalse($draft->canTransitionTo($archived));
        
        // Under review can transition to draft or published
        $this->assertTrue($underReview->canTransitionTo($draft));
        $this->assertTrue($underReview->canTransitionTo($published));
        $this->assertFalse($underReview->canTransitionTo($archived));
        
        // Published can only transition to archived
        $this->assertFalse($published->canTransitionTo($draft));
        $this->assertFalse($published->canTransitionTo($underReview));
        $this->assertTrue($published->canTransitionTo($archived));
        
        // Archived cannot transition
        $this->assertFalse($archived->canTransitionTo($draft));
        $this->assertFalse($archived->canTransitionTo($published));
        $this->assertFalse($archived->canTransitionTo($underReview));
    }
    
    public function testEquals(): void
    {
        // Arrange
        $draft1 = CourseStatus::draft();
        $draft2 = CourseStatus::draft();
        $published = CourseStatus::published();
        
        // Act & Assert
        $this->assertTrue($draft1->equals($draft2));
        $this->assertFalse($draft1->equals($published));
    }
    
    public function testGetAllStatuses(): void
    {
        // Act
        $statuses = CourseStatus::getAllStatuses();
        
        // Assert
        $this->assertCount(4, $statuses);
        $this->assertContains('draft', $statuses);
        $this->assertContains('published', $statuses);
        $this->assertContains('archived', $statuses);
        $this->assertContains('under_review', $statuses);
    }
    
    public function testThrowsExceptionForInvalidStatus(): void
    {
        // Arrange & Assert
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid course status: invalid');
        
        // Act
        CourseStatus::fromString('invalid');
    }
    
    public function testStringConversion(): void
    {
        // Arrange
        $published = CourseStatus::published();
        
        // Act & Assert
        $this->assertEquals('published', (string)$published);
    }
} 