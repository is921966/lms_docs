<?php

declare(strict_types=1);

namespace Tests\Unit\Program\Domain\ValueObjects;

use Program\Domain\ValueObjects\CompletionCriteria;
use PHPUnit\Framework\TestCase;

class CompletionCriteriaTest extends TestCase
{
    public function testCanBeCreatedWithValidPercentage(): void
    {
        // Arrange
        $percentage = 80;
        
        // Act
        $criteria = CompletionCriteria::fromPercentage($percentage);
        
        // Assert
        $this->assertInstanceOf(CompletionCriteria::class, $criteria);
        $this->assertEquals($percentage, $criteria->getRequiredPercentage());
        $this->assertFalse($criteria->requiresAllCourses());
    }
    
    public function testCanCreateRequireAllCriteria(): void
    {
        // Act
        $criteria = CompletionCriteria::requireAll();
        
        // Assert
        $this->assertEquals(100, $criteria->getRequiredPercentage());
        $this->assertTrue($criteria->requiresAllCourses());
    }
    
    public function testThrowsExceptionForNegativePercentage(): void
    {
        // Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Percentage must be between 0 and 100');
        
        // Act
        CompletionCriteria::fromPercentage(-1);
    }
    
    public function testThrowsExceptionForPercentageOver100(): void
    {
        // Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Percentage must be between 0 and 100');
        
        // Act
        CompletionCriteria::fromPercentage(101);
    }
    
    public function testCanCheckIfMet(): void
    {
        // Arrange
        $criteria80 = CompletionCriteria::fromPercentage(80);
        $criteriaAll = CompletionCriteria::requireAll();
        
        // Act & Assert
        // 8 out of 10 courses completed = 80%
        $this->assertTrue($criteria80->isMet(8, 10));
        $this->assertFalse($criteria80->isMet(7, 10));
        
        // Require all - only 100% satisfies
        $this->assertTrue($criteriaAll->isMet(10, 10));
        $this->assertFalse($criteriaAll->isMet(9, 10));
    }
    
    public function testCanCalculateProgress(): void
    {
        // Arrange
        $criteria = CompletionCriteria::fromPercentage(80);
        
        // Act
        $progress = $criteria->calculateProgress(6, 10);
        
        // Assert
        $this->assertEquals(60.0, $progress);
    }
    
    public function testCanBeCompared(): void
    {
        // Arrange
        $criteria1 = CompletionCriteria::fromPercentage(80);
        $criteria2 = CompletionCriteria::fromPercentage(80);
        $criteria3 = CompletionCriteria::fromPercentage(90);
        
        // Act & Assert
        $this->assertTrue($criteria1->equals($criteria2));
        $this->assertFalse($criteria1->equals($criteria3));
    }
    
    public function testCanBeConvertedToString(): void
    {
        // Arrange
        $criteria = CompletionCriteria::fromPercentage(75);
        
        // Act & Assert
        $this->assertEquals('75%', (string)$criteria);
        $this->assertEquals('75%', $criteria->toString());
    }
    
    public function testIsJsonSerializable(): void
    {
        // Arrange
        $criteria = CompletionCriteria::fromPercentage(90);
        
        // Act
        $json = json_encode(['criteria' => $criteria]);
        
        // Assert
        $this->assertEquals('{"criteria":{"percentage":90,"requireAll":false}}', $json);
    }
} 