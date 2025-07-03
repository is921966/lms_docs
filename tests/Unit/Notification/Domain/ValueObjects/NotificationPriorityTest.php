<?php

declare(strict_types=1);

namespace Tests\Unit\Notification\Domain\ValueObjects;

use PHPUnit\Framework\TestCase;
use Notification\Domain\ValueObjects\NotificationPriority;

class NotificationPriorityTest extends TestCase
{
    public function testCanBeCreatedWithValidPriority(): void
    {
        $priority = NotificationPriority::fromString('high');
        
        $this->assertInstanceOf(NotificationPriority::class, $priority);
        $this->assertEquals('high', $priority->getValue());
    }
    
    public function testPredefinedPrioritiesCanBeCreated(): void
    {
        $high = NotificationPriority::high();
        $medium = NotificationPriority::medium();
        $low = NotificationPriority::low();
        
        $this->assertEquals('high', $high->getValue());
        $this->assertEquals('medium', $medium->getValue());
        $this->assertEquals('low', $low->getValue());
    }
    
    public function testThrowsExceptionForEmptyPriority(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Notification priority cannot be empty');
        
        NotificationPriority::fromString('');
    }
    
    public function testThrowsExceptionForInvalidPriority(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid notification priority');
        
        NotificationPriority::fromString('urgent');
    }
    
    public function testCanBeCompared(): void
    {
        $priority1 = NotificationPriority::fromString('high');
        $priority2 = NotificationPriority::fromString('high');
        $priority3 = NotificationPriority::fromString('low');
        
        $this->assertTrue($priority1->equals($priority2));
        $this->assertFalse($priority1->equals($priority3));
    }
    
    public function testCanBeConvertedToString(): void
    {
        $priority = NotificationPriority::fromString('high');
        
        $this->assertEquals('high', (string) $priority);
    }
    
    public function testCanGetNumericValue(): void
    {
        $high = NotificationPriority::high();
        $medium = NotificationPriority::medium();
        $low = NotificationPriority::low();
        
        $this->assertEquals(3, $high->getNumericValue());
        $this->assertEquals(2, $medium->getNumericValue());
        $this->assertEquals(1, $low->getNumericValue());
    }
    
    public function testCanCompareByPriority(): void
    {
        $high = NotificationPriority::high();
        $medium = NotificationPriority::medium();
        $low = NotificationPriority::low();
        
        $this->assertTrue($high->isHigherThan($medium));
        $this->assertTrue($high->isHigherThan($low));
        $this->assertTrue($medium->isHigherThan($low));
        
        $this->assertFalse($low->isHigherThan($medium));
        $this->assertFalse($low->isHigherThan($high));
        $this->assertFalse($medium->isHigherThan($high));
    }
} 