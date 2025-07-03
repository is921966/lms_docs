<?php

declare(strict_types=1);

namespace Tests\Unit\Notification\Domain\ValueObjects;

use PHPUnit\Framework\TestCase;
use Notification\Domain\ValueObjects\NotificationStatus;

class NotificationStatusTest extends TestCase
{
    public function testCanBeCreatedWithValidStatus(): void
    {
        $status = NotificationStatus::fromString('pending');
        
        $this->assertInstanceOf(NotificationStatus::class, $status);
        $this->assertEquals('pending', $status->getValue());
    }
    
    public function testPredefinedStatusesCanBeCreated(): void
    {
        $pending = NotificationStatus::pending();
        $sent = NotificationStatus::sent();
        $delivered = NotificationStatus::delivered();
        $failed = NotificationStatus::failed();
        $read = NotificationStatus::read();
        
        $this->assertEquals('pending', $pending->getValue());
        $this->assertEquals('sent', $sent->getValue());
        $this->assertEquals('delivered', $delivered->getValue());
        $this->assertEquals('failed', $failed->getValue());
        $this->assertEquals('read', $read->getValue());
    }
    
    public function testThrowsExceptionForEmptyStatus(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Notification status cannot be empty');
        
        NotificationStatus::fromString('');
    }
    
    public function testThrowsExceptionForInvalidStatus(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid notification status');
        
        NotificationStatus::fromString('cancelled');
    }
    
    public function testCanBeCompared(): void
    {
        $status1 = NotificationStatus::fromString('sent');
        $status2 = NotificationStatus::fromString('sent');
        $status3 = NotificationStatus::fromString('delivered');
        
        $this->assertTrue($status1->equals($status2));
        $this->assertFalse($status1->equals($status3));
    }
    
    public function testCanBeConvertedToString(): void
    {
        $status = NotificationStatus::fromString('sent');
        
        $this->assertEquals('sent', (string) $status);
    }
    
    public function testCanCheckIfStatusIsFinal(): void
    {
        $pending = NotificationStatus::pending();
        $sent = NotificationStatus::sent();
        $delivered = NotificationStatus::delivered();
        $failed = NotificationStatus::failed();
        $read = NotificationStatus::read();
        
        $this->assertFalse($pending->isFinal());
        $this->assertFalse($sent->isFinal());
        $this->assertFalse($delivered->isFinal());
        $this->assertTrue($failed->isFinal());
        $this->assertTrue($read->isFinal());
    }
    
    public function testCanTransitionToNextStatus(): void
    {
        $pending = NotificationStatus::pending();
        $sent = NotificationStatus::sent();
        $delivered = NotificationStatus::delivered();
        
        $this->assertTrue($pending->canTransitionTo($sent));
        $this->assertTrue($sent->canTransitionTo($delivered));
        $this->assertTrue($sent->canTransitionTo(NotificationStatus::failed()));
        $this->assertTrue($delivered->canTransitionTo(NotificationStatus::read()));
        
        $this->assertFalse($delivered->canTransitionTo($pending));
        $this->assertFalse($delivered->canTransitionTo($sent));
    }
} 