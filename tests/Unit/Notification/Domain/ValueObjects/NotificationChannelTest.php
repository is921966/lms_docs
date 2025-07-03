<?php

declare(strict_types=1);

namespace Tests\Unit\Notification\Domain\ValueObjects;

use PHPUnit\Framework\TestCase;
use Notification\Domain\ValueObjects\NotificationChannel;

class NotificationChannelTest extends TestCase
{
    public function testCanBeCreatedWithValidChannel(): void
    {
        $channel = NotificationChannel::fromString('email');
        
        $this->assertInstanceOf(NotificationChannel::class, $channel);
        $this->assertEquals('email', $channel->getValue());
    }
    
    public function testPredefinedChannelsCanBeCreated(): void
    {
        $email = NotificationChannel::email();
        $push = NotificationChannel::push();
        $inApp = NotificationChannel::inApp();
        $sms = NotificationChannel::sms();
        
        $this->assertEquals('email', $email->getValue());
        $this->assertEquals('push', $push->getValue());
        $this->assertEquals('in_app', $inApp->getValue());
        $this->assertEquals('sms', $sms->getValue());
    }
    
    public function testThrowsExceptionForEmptyChannel(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Notification channel cannot be empty');
        
        NotificationChannel::fromString('');
    }
    
    public function testThrowsExceptionForInvalidChannel(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid notification channel');
        
        NotificationChannel::fromString('telegram');
    }
    
    public function testCanBeCompared(): void
    {
        $channel1 = NotificationChannel::fromString('email');
        $channel2 = NotificationChannel::fromString('email');
        $channel3 = NotificationChannel::fromString('push');
        
        $this->assertTrue($channel1->equals($channel2));
        $this->assertFalse($channel1->equals($channel3));
    }
    
    public function testCanBeConvertedToString(): void
    {
        $channel = NotificationChannel::fromString('email');
        
        $this->assertEquals('email', (string) $channel);
    }
    
    public function testCanCheckIfChannelSupportsTemplates(): void
    {
        $email = NotificationChannel::email();
        $push = NotificationChannel::push();
        $inApp = NotificationChannel::inApp();
        $sms = NotificationChannel::sms();
        
        $this->assertTrue($email->supportsTemplates());
        $this->assertFalse($push->supportsTemplates());
        $this->assertFalse($inApp->supportsTemplates());
        $this->assertFalse($sms->supportsTemplates());
    }
    
    public function testCanCheckIfChannelSupportsAttachments(): void
    {
        $email = NotificationChannel::email();
        $push = NotificationChannel::push();
        $inApp = NotificationChannel::inApp();
        
        $this->assertTrue($email->supportsAttachments());
        $this->assertFalse($push->supportsAttachments());
        $this->assertFalse($inApp->supportsAttachments());
    }
} 