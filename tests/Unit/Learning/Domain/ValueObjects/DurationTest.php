<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Domain\ValueObjects;

use Learning\Domain\ValueObjects\Duration;
use PHPUnit\Framework\TestCase;
use InvalidArgumentException;

class DurationTest extends TestCase
{
    public function testCreateFromMinutes(): void
    {
        // Arrange
        $minutes = 90;
        
        // Act
        $duration = Duration::fromMinutes($minutes);
        
        // Assert
        $this->assertInstanceOf(Duration::class, $duration);
        $this->assertEquals(90, $duration->getMinutes());
        $this->assertEquals(1, $duration->getHours());
        $this->assertEquals(30, $duration->getRemainingMinutes());
        $this->assertEquals('1h 30m', $duration->format());
        $this->assertEquals('1h 30m', (string)$duration);
    }
    
    public function testCreateFromHours(): void
    {
        // Arrange
        $hours = 2.5;
        
        // Act
        $duration = Duration::fromHours($hours);
        
        // Assert
        $this->assertEquals(150, $duration->getMinutes());
        $this->assertEquals(2, $duration->getHours());
        $this->assertEquals(30, $duration->getRemainingMinutes());
        $this->assertEquals('2h 30m', $duration->format());
    }
    
    public function testFromString(): void
    {
        // Arrange & Act
        $duration1 = Duration::fromString('2h 30m');
        $duration2 = Duration::fromString('45m');
        $duration3 = Duration::fromString('3h');
        
        // Assert
        $this->assertEquals(150, $duration1->getMinutes());
        $this->assertEquals(45, $duration2->getMinutes());
        $this->assertEquals(180, $duration3->getMinutes());
    }
    
    public function testAdd(): void
    {
        // Arrange
        $duration1 = Duration::fromMinutes(60);
        $duration2 = Duration::fromMinutes(30);
        
        // Act
        $result = $duration1->add($duration2);
        
        // Assert
        $this->assertEquals(90, $result->getMinutes());
        $this->assertEquals('1h 30m', $result->format());
        // Ensure immutability
        $this->assertEquals(60, $duration1->getMinutes());
    }
    
    public function testSubtract(): void
    {
        // Arrange
        $duration1 = Duration::fromMinutes(90);
        $duration2 = Duration::fromMinutes(30);
        
        // Act
        $result = $duration1->subtract($duration2);
        
        // Assert
        $this->assertEquals(60, $result->getMinutes());
        $this->assertEquals('1h', $result->format());
    }
    
    public function testComparison(): void
    {
        // Arrange
        $duration1 = Duration::fromMinutes(60);
        $duration2 = Duration::fromMinutes(90);
        $duration3 = Duration::fromMinutes(60);
        
        // Act & Assert
        $this->assertTrue($duration1->isLessThan($duration2));
        $this->assertTrue($duration2->isGreaterThan($duration1));
        $this->assertTrue($duration1->equals($duration3));
        $this->assertFalse($duration1->equals($duration2));
    }
    
    public function testThrowsExceptionForNegativeMinutes(): void
    {
        // Arrange & Assert
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Duration cannot be negative');
        
        // Act
        Duration::fromMinutes(-30);
    }
    
    public function testThrowsExceptionForInvalidString(): void
    {
        // Arrange & Assert
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid duration format');
        
        // Act
        Duration::fromString('invalid');
    }
    
    public function testFormattingEdgeCases(): void
    {
        // Arrange & Act & Assert
        $this->assertEquals('0m', Duration::fromMinutes(0)->format());
        $this->assertEquals('1m', Duration::fromMinutes(1)->format());
        $this->assertEquals('59m', Duration::fromMinutes(59)->format());
        $this->assertEquals('1h', Duration::fromMinutes(60)->format());
        $this->assertEquals('2h', Duration::fromMinutes(120)->format());
        $this->assertEquals('2h 1m', Duration::fromMinutes(121)->format());
    }
} 