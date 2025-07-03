<?php

declare(strict_types=1);

namespace Tests\Integration\Notification;

use Tests\Integration\IntegrationTestCase;
use Notification\Application\UseCases\SendNotificationUseCase;
use Notification\Application\UseCases\SendBulkNotificationsUseCase;
use Notification\Application\UseCases\MarkAsReadUseCase;
use Notification\Application\UseCases\SendNotificationRequest;
use Notification\Infrastructure\Persistence\InMemoryNotificationRepository;
use Notification\Infrastructure\CompositeNotificationDispatcher;
use Notification\Infrastructure\Email\EmailNotificationSender;
use Notification\Infrastructure\Email\SmtpEmailProvider;
use Notification\Application\Services\TemplateRenderer;
use Notification\Domain\ValueObjects\RecipientId;
use Notification\Domain\ValueObjects\NotificationStatus;

class NotificationServiceIntegrationTest extends IntegrationTestCase
{
    private InMemoryNotificationRepository $repository;
    private CompositeNotificationDispatcher $dispatcher;
    private SendNotificationUseCase $sendNotificationUseCase;
    private SendBulkNotificationsUseCase $sendBulkNotificationsUseCase;
    private MarkAsReadUseCase $markAsReadUseCase;
    
    protected function setUp(): void
    {
        parent::setUp();
        
        // Setup repository
        $this->repository = new InMemoryNotificationRepository();
        
        // Setup email infrastructure
        $smtpProvider = $this->createMock(SmtpEmailProvider::class);
        
        $templateRenderer = $this->createMock(TemplateRenderer::class);
        $templateRenderer->method('render')->willReturn('<html><body>Test email</body></html>');
        
        $emailSender = new EmailNotificationSender($smtpProvider, $templateRenderer);
        
        // Setup dispatcher
        $this->dispatcher = new CompositeNotificationDispatcher($this->repository);
        $this->dispatcher->addSender($emailSender);
        
        // Setup use cases
        $this->sendNotificationUseCase = new SendNotificationUseCase(
            $this->repository,
            $this->dispatcher
        );
        
        $this->sendBulkNotificationsUseCase = new SendBulkNotificationsUseCase(
            $this->sendNotificationUseCase
        );
        
        $this->markAsReadUseCase = new MarkAsReadUseCase($this->repository);
    }
    
    public function testFullNotificationLifecycle(): void
    {
        // 1. Send notification
        $request = new SendNotificationRequest(
            'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            'course_assigned',
            'email',
            'Course Assignment',
            'You have been assigned to a new course',
            'medium',
            ['courseId' => '123', 'courseName' => 'PHP Advanced']
        );
        
        $notificationDto = $this->sendNotificationUseCase->execute($request);
        
        $this->assertNotNull($notificationDto);
        $this->assertEquals('sent', $notificationDto->toArray()['status']);
        
        // 2. Verify notification is saved
        $notification = $this->repository->findById(
            \Notification\Domain\ValueObjects\NotificationId::fromString($notificationDto->toArray()['id'])
        );
        
        $this->assertNotNull($notification);
        $this->assertEquals('sent', $notification->getStatus()->getValue());
        
        // 3. Get user notifications
        $recipientId = RecipientId::fromString('f47ac10b-58cc-4372-a567-0e02b2c3d479');
        $notifications = $this->repository->findByRecipient($recipientId);
        
        $this->assertCount(1, $notifications);
        $this->assertEquals($notification->getId()->getValue(), $notifications[0]->getId()->getValue());
        
        // 4. Check unread count
        $unreadCount = $this->repository->countUnreadByRecipient($recipientId);
        $this->assertEquals(1, $unreadCount);
        
        // 5. Mark as delivered (simulating email delivery confirmation)
        $notification->markAsDelivered();
        $this->repository->save($notification);
        
        // 6. Mark as read
        $this->markAsReadUseCase->execute($notification->getId()->getValue());
        
        // 7. Verify read status
        $updatedNotification = $this->repository->findById($notification->getId());
        $this->assertEquals('read', $updatedNotification->getStatus()->getValue());
        
        // 8. Check unread count again
        $unreadCount = $this->repository->countUnreadByRecipient($recipientId);
        $this->assertEquals(0, $unreadCount);
    }
    
    public function testBulkNotificationSending(): void
    {
        $recipientIds = [
            'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            'a47ac10b-58cc-4372-a567-0e02b2c3d479',
            'b47ac10b-58cc-4372-a567-0e02b2c3d479'
        ];
        
        $bulkRequest = [
            'recipientIds' => $recipientIds,
            'type' => 'system_announcement',
            'channel' => 'email',
            'subject' => 'System Maintenance',
            'content' => 'The system will be under maintenance',
            'priority' => 'high',
            'metadata' => ['scheduledAt' => '2025-07-04 02:00:00']
        ];
        
        $bulkDto = $this->sendBulkNotificationsUseCase->execute($bulkRequest);
        $results = $bulkDto->toArray();
        
        $this->assertEquals(3, $results['total']);
        $this->assertEquals(3, $results['successful']);
        $this->assertEquals(0, $results['failed']);
        
        // Verify all notifications are saved
        foreach ($recipientIds as $recipientId) {
            $notifications = $this->repository->findByRecipient(
                RecipientId::fromString($recipientId)
            );
            
            $this->assertCount(1, $notifications);
            $this->assertEquals('system_announcement', $notifications[0]->getType()->getValue());
            $this->assertEquals('high', $notifications[0]->getPriority()->getValue());
        }
    }
    
    public function testNotificationFiltering(): void
    {
        $recipientId = RecipientId::fromString('f47ac10b-58cc-4372-a567-0e02b2c3d479');
        
        // Create notifications with different statuses
        $requests = [
            ['type' => 'course_assigned', 'subject' => 'Course 1'],
            ['type' => 'course_completed', 'subject' => 'Course 2'],
            ['type' => 'deadline_reminder', 'subject' => 'Assignment Due']
        ];
        
        $notificationIds = [];
        foreach ($requests as $requestData) {
            $request = new SendNotificationRequest(
                $recipientId->getValue(),
                $requestData['type'],
                'email',
                $requestData['subject'],
                'Test content',
                'medium'
            );
            
            $dto = $this->sendNotificationUseCase->execute($request);
            $notificationIds[] = $dto->toArray()['id'];
        }
        
        // Mark first notification as delivered
        $notification1 = $this->repository->findById(
            \Notification\Domain\ValueObjects\NotificationId::fromString($notificationIds[0])
        );
        $notification1->markAsDelivered();
        $this->repository->save($notification1);
        
        // Mark second notification as read
        $notification2 = $this->repository->findById(
            \Notification\Domain\ValueObjects\NotificationId::fromString($notificationIds[1])
        );
        $notification2->markAsDelivered(); // First mark as delivered
        $this->repository->save($notification2);
        $this->markAsReadUseCase->execute($notificationIds[1]);
        
        // Test filtering by status
        $sentNotifications = $this->repository->findByRecipientAndStatus(
            $recipientId,
            NotificationStatus::sent()
        );
        $this->assertCount(1, $sentNotifications);
        
        $deliveredNotifications = $this->repository->findByRecipientAndStatus(
            $recipientId,
            NotificationStatus::delivered()
        );
        $this->assertCount(1, $deliveredNotifications);
        
        $readNotifications = $this->repository->findByRecipientAndStatus(
            $recipientId,
            NotificationStatus::read()
        );
        $this->assertCount(1, $readNotifications);
    }
    
    public function testMarkAllAsRead(): void
    {
        $recipientId = RecipientId::fromString('f47ac10b-58cc-4372-a567-0e02b2c3d479');
        
        // Create multiple notifications
        for ($i = 1; $i <= 5; $i++) {
            $request = new SendNotificationRequest(
                $recipientId->getValue(),
                'course_assigned',
                'email',
                "Course $i Assignment",
                "You have been assigned to course $i",
                'medium'
            );
            
            $dto = $this->sendNotificationUseCase->execute($request);
            
            // Mark as delivered to allow marking as read
            $notification = $this->repository->findById(
                \Notification\Domain\ValueObjects\NotificationId::fromString($dto->toArray()['id'])
            );
            $notification->markAsDelivered();
            $this->repository->save($notification);
        }
        
        // Verify unread count
        $unreadCount = $this->repository->countUnreadByRecipient($recipientId);
        $this->assertEquals(5, $unreadCount);
        
        // Mark all as read
        $this->repository->markAllAsReadForRecipient($recipientId);
        
        // Verify all are read
        $unreadCount = $this->repository->countUnreadByRecipient($recipientId);
        $this->assertEquals(0, $unreadCount);
        
        $notifications = $this->repository->findByRecipient($recipientId);
        foreach ($notifications as $notification) {
            $this->assertEquals('read', $notification->getStatus()->getValue());
        }
    }
    
    public function testPriorityOrdering(): void
    {
        // Create notifications with different priorities
        $priorities = ['low', 'high', 'medium', 'high', 'low'];
        $notificationIds = [];
        
        foreach ($priorities as $index => $priority) {
            $request = new SendNotificationRequest(
                'f47ac10b-58cc-4372-a567-0e02b2c3d479',
                'system_announcement',
                'email',
                "Announcement $index",
                'Content',
                $priority
            );
            
            $dto = $this->sendNotificationUseCase->execute($request);
            $notificationIds[] = $dto->toArray()['id'];
        }
        
        // Change status back to pending to test ordering
        foreach ($notificationIds as $id) {
            $notification = $this->repository->findById(
                \Notification\Domain\ValueObjects\NotificationId::fromString($id)
            );
            // Reset to pending status for testing priority ordering
            $reflectionClass = new \ReflectionClass($notification);
            $statusProperty = $reflectionClass->getProperty('status');
            $statusProperty->setAccessible(true);
            $statusProperty->setValue($notification, \Notification\Domain\ValueObjects\NotificationStatus::pending());
            $this->repository->save($notification);
        }
        
        // Get pending notifications (should be ordered by priority)
        $pending = $this->repository->findPendingNotifications();
        
        // First notifications should be high priority
        $this->assertEquals('high', $pending[0]->getPriority()->getValue());
        $this->assertEquals('high', $pending[1]->getPriority()->getValue());
        
        // Verify count
        $this->assertCount(5, $pending);
    }
} 