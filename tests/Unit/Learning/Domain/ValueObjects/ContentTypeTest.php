<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Domain\ValueObjects;

use Learning\Domain\ValueObjects\ContentType;
use PHPUnit\Framework\TestCase;
use InvalidArgumentException;

class ContentTypeTest extends TestCase
{
    public function testCreateValidTypes(): void
    {
        // Act & Assert
        $video = ContentType::video();
        $this->assertEquals('video', $video->getValue());
        $this->assertEquals('Video', $video->getDisplayName());
        $this->assertTrue($video->isVideo());
        $this->assertFalse($video->isText());
        
        $text = ContentType::text();
        $this->assertEquals('text', $text->getValue());
        $this->assertEquals('Text', $text->getDisplayName());
        $this->assertTrue($text->isText());
        $this->assertFalse($text->isVideo());
        
        $quiz = ContentType::quiz();
        $this->assertEquals('quiz', $quiz->getValue());
        $this->assertEquals('Quiz', $quiz->getDisplayName());
        $this->assertTrue($quiz->isQuiz());
        
        $assignment = ContentType::assignment();
        $this->assertEquals('assignment', $assignment->getValue());
        $this->assertEquals('Assignment', $assignment->getDisplayName());
        $this->assertTrue($assignment->isAssignment());
        
        $document = ContentType::document();
        $this->assertEquals('document', $document->getValue());
        $this->assertEquals('Document', $document->getDisplayName());
        $this->assertTrue($document->isDocument());
    }
    
    public function testFromString(): void
    {
        // Act & Assert
        $video = ContentType::fromString('video');
        $this->assertTrue($video->isVideo());
        
        $text = ContentType::fromString('text');
        $this->assertTrue($text->isText());
        
        // Test case insensitive
        $quiz = ContentType::fromString('QUIZ');
        $this->assertTrue($quiz->isQuiz());
    }
    
    public function testGetAllTypes(): void
    {
        // Act
        $types = ContentType::getAllTypes();
        
        // Assert
        $this->assertCount(5, $types);
        $this->assertContains('video', $types);
        $this->assertContains('text', $types);
        $this->assertContains('quiz', $types);
        $this->assertContains('assignment', $types);
        $this->assertContains('document', $types);
    }
    
    public function testEquals(): void
    {
        // Arrange
        $video1 = ContentType::video();
        $video2 = ContentType::video();
        $text = ContentType::text();
        
        // Act & Assert
        $this->assertTrue($video1->equals($video2));
        $this->assertFalse($video1->equals($text));
    }
    
    public function testIsInteractive(): void
    {
        // Act & Assert
        $this->assertFalse(ContentType::video()->isInteractive());
        $this->assertFalse(ContentType::text()->isInteractive());
        $this->assertTrue(ContentType::quiz()->isInteractive());
        $this->assertTrue(ContentType::assignment()->isInteractive());
        $this->assertFalse(ContentType::document()->isInteractive());
    }
    
    public function testIsAssessable(): void
    {
        // Act & Assert
        $this->assertFalse(ContentType::video()->isAssessable());
        $this->assertFalse(ContentType::text()->isAssessable());
        $this->assertTrue(ContentType::quiz()->isAssessable());
        $this->assertTrue(ContentType::assignment()->isAssessable());
        $this->assertFalse(ContentType::document()->isAssessable());
    }
    
    public function testThrowsExceptionForInvalidType(): void
    {
        // Arrange & Assert
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid content type: invalid');
        
        // Act
        ContentType::fromString('invalid');
    }
    
    public function testStringConversion(): void
    {
        // Arrange
        $video = ContentType::video();
        
        // Act & Assert
        $this->assertEquals('video', (string)$video);
    }
} 