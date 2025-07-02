<?php

declare(strict_types=1);

namespace Tests\Unit\Program\Domain\ValueObjects;

use Program\Domain\ValueObjects\TrackOrder;
use PHPUnit\Framework\TestCase;

class TrackOrderTest extends TestCase
{
    public function testCanBeCreatedFromValidInteger(): void
    {
        // Arrange
        $order = 1;
        
        // Act
        $trackOrder = TrackOrder::fromInt($order);
        
        // Assert
        $this->assertInstanceOf(TrackOrder::class, $trackOrder);
        $this->assertEquals($order, $trackOrder->getValue());
    }
    
    public function testThrowsExceptionForZeroOrder(): void
    {
        // Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Track order must be greater than zero');
        
        // Act
        TrackOrder::fromInt(0);
    }
    
    public function testThrowsExceptionForNegativeOrder(): void
    {
        // Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Track order must be greater than zero');
        
        // Act
        TrackOrder::fromInt(-1);
    }
    
    public function testCanCreateFirstOrder(): void
    {
        // Act
        $trackOrder = TrackOrder::first();
        
        // Assert
        $this->assertEquals(1, $trackOrder->getValue());
        $this->assertTrue($trackOrder->isFirst());
    }
    
    public function testCanCreateNextOrder(): void
    {
        // Arrange
        $currentOrder = TrackOrder::fromInt(3);
        
        // Act
        $nextOrder = $currentOrder->next();
        
        // Assert
        $this->assertEquals(4, $nextOrder->getValue());
    }
    
    public function testCanCheckIfIsFirst(): void
    {
        // Arrange
        $firstOrder = TrackOrder::fromInt(1);
        $secondOrder = TrackOrder::fromInt(2);
        
        // Act & Assert
        $this->assertTrue($firstOrder->isFirst());
        $this->assertFalse($secondOrder->isFirst());
    }
    
    public function testCanBeCompared(): void
    {
        // Arrange
        $order1 = TrackOrder::fromInt(1);
        $order2 = TrackOrder::fromInt(2);
        $order3 = TrackOrder::fromInt(1);
        
        // Act & Assert
        $this->assertTrue($order1->equals($order3));
        $this->assertFalse($order1->equals($order2));
        
        $this->assertTrue($order1->isLessThan($order2));
        $this->assertFalse($order2->isLessThan($order1));
        
        $this->assertTrue($order2->isGreaterThan($order1));
        $this->assertFalse($order1->isGreaterThan($order2));
    }
    
    public function testCanBeConvertedToString(): void
    {
        // Arrange
        $order = TrackOrder::fromInt(5);
        
        // Act & Assert
        $this->assertEquals('5', (string)$order);
        $this->assertEquals('5', $order->toString());
    }
    
    public function testIsJsonSerializable(): void
    {
        // Arrange
        $order = TrackOrder::fromInt(3);
        
        // Act
        $json = json_encode(['order' => $order]);
        
        // Assert
        $this->assertEquals('{"order":3}', $json);
    }
} 