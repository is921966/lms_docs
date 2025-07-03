<?php

declare(strict_types=1);

namespace Tests\Unit\Notification\Domain\ValueObjects;

use PHPUnit\Framework\TestCase;
use Notification\Domain\ValueObjects\NotificationId;

class NotificationIdTest extends TestCase
{
    public function testCanBeCreatedFromValidUuid(): void
    {
        $uuid = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
        $notificationId = NotificationId::fromString($uuid);
        
        $this->assertInstanceOf(NotificationId::class, $notificationId);
        $this->assertEquals($uuid, $notificationId->getValue());
    }
    
    public function testCanGenerateNewId(): void
    {
        $notificationId = NotificationId::generate();
        
        $this->assertInstanceOf(NotificationId::class, $notificationId);
        $this->assertMatchesRegularExpression(
            '/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i',
            $notificationId->getValue()
        );
    }
    
    public function testThrowsExceptionForInvalidUuid(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid notification ID format');
        
        NotificationId::fromString('invalid-uuid');
    }
    
    public function testThrowsExceptionForEmptyString(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Notification ID cannot be empty');
        
        NotificationId::fromString('');
    }
    
    public function testCanBeCompared(): void
    {
        $uuid = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
        $id1 = NotificationId::fromString($uuid);
        $id2 = NotificationId::fromString($uuid);
        $id3 = NotificationId::generate();
        
        $this->assertTrue($id1->equals($id2));
        $this->assertFalse($id1->equals($id3));
    }
    
    public function testCanBeConvertedToString(): void
    {
        $uuid = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
        $notificationId = NotificationId::fromString($uuid);
        
        $this->assertEquals($uuid, (string) $notificationId);
    }
} 