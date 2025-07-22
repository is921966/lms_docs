<?php

declare(strict_types=1);

namespace Tests\Unit\Course\Domain\ValueObjects;

use PHPUnit\Framework\TestCase;
use App\Course\Domain\ValueObjects\Duration;
use App\Common\Exceptions\InvalidArgumentException;

class DurationTest extends TestCase
{
    public function testCanCreateValidDuration(): void
    {
        // Given
        $minutes = 90;
        
        // When
        $duration = new Duration($minutes);
        
        // Then
        $this->assertEquals(90, $duration->inMinutes());
        $this->assertEquals(1.5, $duration->inHours());
        $this->assertEquals('1h 30m', (string)$duration);
    }
    
    public function testCanCreateFromHours(): void
    {
        // When
        $duration = Duration::fromHours(2.5);
        
        // Then
        $this->assertEquals(150, $duration->inMinutes());
        $this->assertEquals(2.5, $duration->inHours());
        $this->assertEquals('2h 30m', (string)$duration);
    }
    
    public function testThrowsExceptionForNegativeDuration(): void
    {
        // Then
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Duration cannot be negative');
        
        // When
        new Duration(-1);
    }
    
    public function testThrowsExceptionForZeroDuration(): void
    {
        // Then
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Duration must be greater than zero');
        
        // When
        new Duration(0);
    }
    
    public function testFormatsCorrectly(): void
    {
        // Given
        $testCases = [
            [30, '30m'],
            [60, '1h'],
            [75, '1h 15m'],
            [120, '2h'],
            [480, '8h']
        ];
        
        foreach ($testCases as [$minutes, $expected]) {
            // When
            $duration = new Duration($minutes);
            
            // Then
            $this->assertEquals($expected, (string)$duration);
        }
    }
    
    public function testEquality(): void
    {
        // Given
        $duration1 = new Duration(90);
        $duration2 = new Duration(90);
        $duration3 = new Duration(120);
        
        // Then
        $this->assertTrue($duration1->equals($duration2));
        $this->assertFalse($duration1->equals($duration3));
    }
    
    public function testCanAdd(): void
    {
        // Given
        $duration1 = new Duration(60);
        $duration2 = new Duration(30);
        
        // When
        $result = $duration1->add($duration2);
        
        // Then
        $this->assertEquals(90, $result->inMinutes());
        $this->assertEquals('1h 30m', (string)$result);
    }
} 