<?php

declare(strict_types=1);

namespace Tests\Unit\Notification\Domain\Entities;

use PHPUnit\Framework\TestCase;
use Notification\Domain\Notification;
use Notification\Domain\ValueObjects\NotificationId;
use Notification\Domain\ValueObjects\NotificationType;
use Notification\Domain\ValueObjects\NotificationChannel;
use Notification\Domain\ValueObjects\NotificationPriority;
use Notification\Domain\ValueObjects\NotificationStatus;
use Notification\Domain\ValueObjects\RecipientId;

class NotificationTest extends TestCase
{
    public function testCanBeCreated(): void
    {
        $notification = Notification::create(
            NotificationId::generate(),
            RecipientId::fromString('f47ac10b-58cc-4372-a567-0e02b2c3d479'),
            NotificationType::courseAssigned(),
            NotificationChannel::email(),
            'Course Assignment',
            'You have been assigned to a new course',
            NotificationPriority::medium(),
            ['courseName' => 'PHP Advanced', 'deadline' => '2025-08-01']
        );
        
        $this->assertInstanceOf(Notification::class, $notification);
        $this->assertEquals('Course Assignment', $notification->getSubject());
        $this->assertEquals('You have been assigned to a new course', $notification->getContent());
        $this->assertEquals(NotificationStatus::pending()->getValue(), $notification->getStatus()->getValue());
        $this->assertTrue($notification->hasEvents());
    }
    
    public function testCanMarkAsSent(): void
    {
        $notification = $this->createNotification();
        
        $notification->markAsSent();
        
        $this->assertEquals(NotificationStatus::sent()->getValue(), $notification->getStatus()->getValue());
        $this->assertNotNull($notification->getSentAt());
        $this->assertTrue($notification->hasEvents());
    }
    
    public function testCanMarkAsDelivered(): void
    {
        $notification = $this->createNotification();
        $notification->markAsSent();
        
        $notification->markAsDelivered();
        
        $this->assertEquals(NotificationStatus::delivered()->getValue(), $notification->getStatus()->getValue());
        $this->assertNotNull($notification->getDeliveredAt());
    }
    
    public function testCanMarkAsFailed(): void
    {
        $notification = $this->createNotification();
        $notification->markAsSent();
        
        $notification->markAsFailed('SMTP connection error');
        
        $this->assertEquals(NotificationStatus::failed()->getValue(), $notification->getStatus()->getValue());
        $this->assertEquals('SMTP connection error', $notification->getFailureReason());
        $this->assertNotNull($notification->getFailedAt());
    }
    
    public function testCanMarkAsRead(): void
    {
        $notification = $this->createNotification();
        $notification->markAsSent();
        $notification->markAsDelivered();
        
        $notification->markAsRead();
        
        $this->assertEquals(NotificationStatus::read()->getValue(), $notification->getStatus()->getValue());
        $this->assertNotNull($notification->getReadAt());
    }
    
    public function testCannotTransitionToInvalidStatus(): void
    {
        $notification = $this->createNotification();
        
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Invalid status transition');
        
        $notification->markAsDelivered(); // Cannot go from pending to delivered
    }
    
    public function testCannotChangeStatusFromFinalState(): void
    {
        $notification = $this->createNotification();
        $notification->markAsSent();
        $notification->markAsFailed('Error');
        
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Cannot change status from final state');
        
        $notification->markAsDelivered();
    }
    
    public function testCanGetMetadata(): void
    {
        $metadata = ['courseName' => 'PHP Advanced', 'deadline' => '2025-08-01'];
        $notification = Notification::create(
            NotificationId::generate(),
            RecipientId::fromString('f47ac10b-58cc-4372-a567-0e02b2c3d479'),
            NotificationType::courseAssigned(),
            NotificationChannel::email(),
            'Course Assignment',
            'You have been assigned to a new course',
            NotificationPriority::medium(),
            $metadata
        );
        
        $this->assertEquals($metadata, $notification->getMetadata());
    }
    
    public function testCanCheckIfHighPriority(): void
    {
        $highPriorityNotification = Notification::create(
            NotificationId::generate(),
            RecipientId::fromString('f47ac10b-58cc-4372-a567-0e02b2c3d479'),
            NotificationType::systemAnnouncement(),
            NotificationChannel::push(),
            'Urgent System Maintenance',
            'System will be down for maintenance',
            NotificationPriority::high()
        );
        
        $lowPriorityNotification = $this->createNotification();
        
        $this->assertTrue($highPriorityNotification->isHighPriority());
        $this->assertFalse($lowPriorityNotification->isHighPriority());
    }
    
    private function createNotification(): Notification
    {
        return Notification::create(
            NotificationId::generate(),
            RecipientId::fromString('f47ac10b-58cc-4372-a567-0e02b2c3d479'),
            NotificationType::courseAssigned(),
            NotificationChannel::email(),
            'Course Assignment',
            'You have been assigned to a new course',
            NotificationPriority::medium()
        );
    }
} 