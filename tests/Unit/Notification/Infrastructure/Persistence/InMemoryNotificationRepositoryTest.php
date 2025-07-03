<?php

declare(strict_types=1);

namespace Tests\Unit\Notification\Infrastructure\Persistence;

use PHPUnit\Framework\TestCase;
use Notification\Infrastructure\Persistence\InMemoryNotificationRepository;
use Notification\Domain\Notification;
use Notification\Domain\ValueObjects\NotificationId;
use Notification\Domain\ValueObjects\NotificationType;
use Notification\Domain\ValueObjects\NotificationChannel;
use Notification\Domain\ValueObjects\NotificationPriority;
use Notification\Domain\ValueObjects\NotificationStatus;
use Notification\Domain\ValueObjects\RecipientId;

class InMemoryNotificationRepositoryTest extends TestCase
{
    private InMemoryNotificationRepository $repository;
    
    protected function setUp(): void
    {
        $this->repository = new InMemoryNotificationRepository();
    }
    
    public function testSaveAndFindById(): void
    {
        $notification = $this->createNotification();
        
        $this->repository->save($notification);
        
        $found = $this->repository->findById($notification->getId());
        
        $this->assertNotNull($found);
        $this->assertTrue($notification->getId()->equals($found->getId()));
        $this->assertEquals($notification->getSubject(), $found->getSubject());
    }
    
    public function testFindByIdReturnsNullWhenNotFound(): void
    {
        $id = NotificationId::generate();
        
        $found = $this->repository->findById($id);
        
        $this->assertNull($found);
    }
    
    public function testFindByRecipient(): void
    {
        $recipientId = RecipientId::fromString('f47ac10b-58cc-4372-a567-0e02b2c3d479');
        $otherRecipientId = RecipientId::fromString('a47ac10b-58cc-4372-a567-0e02b2c3d479');
        
        $notification1 = $this->createNotificationForRecipient($recipientId);
        $notification2 = $this->createNotificationForRecipient($recipientId);
        $notification3 = $this->createNotificationForRecipient($otherRecipientId);
        
        $this->repository->save($notification1);
        $this->repository->save($notification2);
        $this->repository->save($notification3);
        
        $found = $this->repository->findByRecipient($recipientId);
        
        $this->assertCount(2, $found);
        $this->assertTrue($found[0]->getRecipientId()->equals($recipientId));
        $this->assertTrue($found[1]->getRecipientId()->equals($recipientId));
    }
    
    public function testFindByRecipientWithLimitAndOffset(): void
    {
        $recipientId = RecipientId::fromString('f47ac10b-58cc-4372-a567-0e02b2c3d479');
        
        for ($i = 0; $i < 5; $i++) {
            $notification = $this->createNotificationForRecipient($recipientId);
            $this->repository->save($notification);
        }
        
        $found = $this->repository->findByRecipient($recipientId, 2, 1);
        
        $this->assertCount(2, $found);
    }
    
    public function testFindByRecipientAndStatus(): void
    {
        $recipientId = RecipientId::fromString('f47ac10b-58cc-4372-a567-0e02b2c3d479');
        
        $notification1 = $this->createNotificationForRecipient($recipientId);
        $notification2 = $this->createNotificationForRecipient($recipientId);
        $notification2->markAsSent();
        $notification3 = $this->createNotificationForRecipient($recipientId);
        $notification3->markAsSent();
        $notification3->markAsDelivered();
        
        $this->repository->save($notification1);
        $this->repository->save($notification2);
        $this->repository->save($notification3);
        
        $pending = $this->repository->findByRecipientAndStatus($recipientId, NotificationStatus::pending());
        $sent = $this->repository->findByRecipientAndStatus($recipientId, NotificationStatus::sent());
        $delivered = $this->repository->findByRecipientAndStatus($recipientId, NotificationStatus::delivered());
        
        $this->assertCount(1, $pending);
        $this->assertCount(1, $sent);
        $this->assertCount(1, $delivered);
    }
    
    public function testFindByRecipientAndChannel(): void
    {
        $recipientId = RecipientId::fromString('f47ac10b-58cc-4372-a567-0e02b2c3d479');
        
        $emailNotification = Notification::create(
            NotificationId::generate(),
            $recipientId,
            NotificationType::courseAssigned(),
            NotificationChannel::email(),
            'Email Subject',
            'Email Content',
            NotificationPriority::medium()
        );
        
        $pushNotification = Notification::create(
            NotificationId::generate(),
            $recipientId,
            NotificationType::courseAssigned(),
            NotificationChannel::push(),
            'Push Subject',
            'Push Content',
            NotificationPriority::high()
        );
        
        $this->repository->save($emailNotification);
        $this->repository->save($pushNotification);
        
        $emailNotifications = $this->repository->findByRecipientAndChannel($recipientId, NotificationChannel::email());
        $pushNotifications = $this->repository->findByRecipientAndChannel($recipientId, NotificationChannel::push());
        
        $this->assertCount(1, $emailNotifications);
        $this->assertCount(1, $pushNotifications);
        $this->assertEquals('email', $emailNotifications[0]->getChannel()->getValue());
        $this->assertEquals('push', $pushNotifications[0]->getChannel()->getValue());
    }
    
    public function testFindPendingNotifications(): void
    {
        $notification1 = $this->createNotification();
        $notification2 = $this->createNotification();
        $notification2->markAsSent();
        $notification3 = $this->createNotification();
        
        $this->repository->save($notification1);
        $this->repository->save($notification2);
        $this->repository->save($notification3);
        
        $pending = $this->repository->findPendingNotifications();
        
        $this->assertCount(2, $pending);
        foreach ($pending as $notification) {
            $this->assertEquals('pending', $notification->getStatus()->getValue());
        }
    }
    
    public function testFindPendingNotificationsWithLimit(): void
    {
        for ($i = 0; $i < 5; $i++) {
            $notification = $this->createNotification();
            $this->repository->save($notification);
        }
        
        $pending = $this->repository->findPendingNotifications(3);
        
        $this->assertCount(3, $pending);
    }
    
    public function testCountUnreadByRecipient(): void
    {
        $recipientId = RecipientId::fromString('f47ac10b-58cc-4372-a567-0e02b2c3d479');
        
        $notification1 = $this->createNotificationForRecipient($recipientId);
        $notification2 = $this->createNotificationForRecipient($recipientId);
        $notification2->markAsSent();
        $notification2->markAsDelivered();
        $notification3 = $this->createNotificationForRecipient($recipientId);
        $notification3->markAsSent();
        $notification3->markAsDelivered();
        $notification3->markAsRead();
        
        $this->repository->save($notification1);
        $this->repository->save($notification2);
        $this->repository->save($notification3);
        
        $unreadCount = $this->repository->countUnreadByRecipient($recipientId);
        
        $this->assertEquals(2, $unreadCount);
    }
    
    public function testMarkAllAsReadForRecipient(): void
    {
        $recipientId = RecipientId::fromString('f47ac10b-58cc-4372-a567-0e02b2c3d479');
        
        $notification1 = $this->createNotificationForRecipient($recipientId);
        $notification1->markAsSent();
        $notification1->markAsDelivered();
        
        $notification2 = $this->createNotificationForRecipient($recipientId);
        $notification2->markAsSent();
        $notification2->markAsDelivered();
        
        $this->repository->save($notification1);
        $this->repository->save($notification2);
        
        $this->repository->markAllAsReadForRecipient($recipientId);
        
        $unreadCount = $this->repository->countUnreadByRecipient($recipientId);
        $this->assertEquals(0, $unreadCount);
        
        $notifications = $this->repository->findByRecipient($recipientId);
        foreach ($notifications as $notification) {
            $this->assertEquals('read', $notification->getStatus()->getValue());
        }
    }
    
    private function createNotification(): Notification
    {
        return Notification::create(
            NotificationId::generate(),
            RecipientId::fromString('f47ac10b-58cc-4372-a567-0e02b2c3d479'),
            NotificationType::courseAssigned(),
            NotificationChannel::email(),
            'Test Subject',
            'Test Content',
            NotificationPriority::medium()
        );
    }
    
    private function createNotificationForRecipient(RecipientId $recipientId): Notification
    {
        return Notification::create(
            NotificationId::generate(),
            $recipientId,
            NotificationType::courseAssigned(),
            NotificationChannel::email(),
            'Test Subject',
            'Test Content',
            NotificationPriority::medium()
        );
    }
} 