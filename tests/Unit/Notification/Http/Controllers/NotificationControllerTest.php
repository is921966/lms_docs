<?php

declare(strict_types=1);

namespace Tests\Unit\Notification\Http\Controllers;

use PHPUnit\Framework\TestCase;
use Notification\Http\Controllers\NotificationController;
use Notification\Application\UseCases\SendNotificationUseCase;
use Notification\Application\UseCases\SendBulkNotificationsUseCase;
use Notification\Application\UseCases\MarkAsReadUseCase;
use Notification\Domain\Repository\NotificationRepositoryInterface;
use Notification\Domain\Notification;
use Notification\Domain\ValueObjects\NotificationId;
use Notification\Domain\ValueObjects\RecipientId;
use Notification\Domain\ValueObjects\NotificationType;
use Notification\Domain\ValueObjects\NotificationChannel;
use Notification\Domain\ValueObjects\NotificationPriority;
use Notification\Application\DTO\NotificationDTO;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;

class NotificationControllerTest extends TestCase
{
    private SendNotificationUseCase $sendNotificationUseCase;
    private SendBulkNotificationsUseCase $sendBulkNotificationsUseCase;
    private MarkAsReadUseCase $markAsReadUseCase;
    private NotificationRepositoryInterface $repository;
    private NotificationController $controller;
    
    protected function setUp(): void
    {
        $this->sendNotificationUseCase = $this->createMock(SendNotificationUseCase::class);
        $this->sendBulkNotificationsUseCase = $this->createMock(SendBulkNotificationsUseCase::class);
        $this->markAsReadUseCase = $this->createMock(MarkAsReadUseCase::class);
        $this->repository = $this->createMock(NotificationRepositoryInterface::class);
        
        $this->controller = new NotificationController(
            $this->sendNotificationUseCase,
            $this->sendBulkNotificationsUseCase,
            $this->markAsReadUseCase,
            $this->repository
        );
    }
    
    public function testSendNotification(): void
    {
        $requestData = [
            'recipientId' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            'type' => 'course_assigned',
            'channel' => 'email',
            'subject' => 'Course Assignment',
            'content' => 'You have been assigned to a new course',
            'priority' => 'medium',
            'metadata' => ['courseId' => '123']
        ];
        
        $request = new Request([], [], [], [], [], [], json_encode($requestData));
        $request->headers->set('Content-Type', 'application/json');
        
        $notificationDto = $this->createMock(NotificationDTO::class);
        $notificationDto->method('toArray')->willReturn([
            'id' => 'generated-id',
            'recipientId' => $requestData['recipientId'],
            'type' => $requestData['type'],
            'status' => 'sent'
        ]);
        
        $this->sendNotificationUseCase->expects($this->once())
            ->method('execute')
            ->willReturn($notificationDto);
        
        $response = $this->controller->send($request);
        
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(201, $response->getStatusCode());
        
        $responseData = json_decode($response->getContent(), true);
        $this->assertEquals('sent', $responseData['data']['status']);
    }
    
    public function testSendBulkNotifications(): void
    {
        $requestData = [
            'recipientIds' => [
                'f47ac10b-58cc-4372-a567-0e02b2c3d479',
                'a47ac10b-58cc-4372-a567-0e02b2c3d479'
            ],
            'type' => 'system_announcement',
            'channel' => 'email',
            'subject' => 'System Update',
            'content' => 'Important system update',
            'priority' => 'high'
        ];
        
        $request = new Request([], [], [], [], [], [], json_encode($requestData));
        $request->headers->set('Content-Type', 'application/json');
        
        $results = [
            ['recipientId' => $requestData['recipientIds'][0], 'status' => 'sent'],
            ['recipientId' => $requestData['recipientIds'][1], 'status' => 'sent']
        ];
        
        $bulkDto = $this->createMock(\Notification\Application\DTO\BulkNotificationDTO::class);
        $bulkDto->method('toArray')->willReturn([
            'results' => $results,
            'total' => 2,
            'successful' => 2,
            'failed' => 0
        ]);
        
        $this->sendBulkNotificationsUseCase->expects($this->once())
            ->method('execute')
            ->willReturn($bulkDto);
        
        $response = $this->controller->sendBulk($request);
        
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(200, $response->getStatusCode());
        
        $responseData = json_decode($response->getContent(), true);
        $this->assertCount(2, $responseData['data']['results']);
    }
    
    public function testGetUserNotifications(): void
    {
        $userId = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
        $notification1 = $this->createNotification($userId);
        $notification2 = $this->createNotification($userId);
        
        $this->repository->expects($this->once())
            ->method('findByRecipient')
            ->with(
                $this->callback(fn($id) => $id instanceof RecipientId && $id->getValue() === $userId),
                50,
                0
            )
            ->willReturn([$notification1, $notification2]);
        
        $request = new Request(['limit' => '50', 'offset' => '0']);
        $response = $this->controller->getUserNotifications($userId, $request);
        
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(200, $response->getStatusCode());
        
        $responseData = json_decode($response->getContent(), true);
        $this->assertCount(2, $responseData['data']);
    }
    
    public function testMarkAsRead(): void
    {
        $notificationId = 'c47ac10b-58cc-4372-a567-0e02b2c3d479';
        
        $this->markAsReadUseCase->expects($this->once())
            ->method('execute')
            ->with($notificationId);
        
        $response = $this->controller->markAsRead($notificationId);
        
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(200, $response->getStatusCode());
        
        $responseData = json_decode($response->getContent(), true);
        $this->assertEquals('Notification marked as read', $responseData['message']);
    }
    
    public function testMarkAllAsRead(): void
    {
        $userId = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
        
        $this->repository->expects($this->once())
            ->method('markAllAsReadForRecipient')
            ->with($this->callback(fn($id) => $id instanceof RecipientId && $id->getValue() === $userId));
        
        $response = $this->controller->markAllAsRead($userId);
        
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(200, $response->getStatusCode());
        
        $responseData = json_decode($response->getContent(), true);
        $this->assertEquals('All notifications marked as read', $responseData['message']);
    }
    
    public function testGetUnreadCount(): void
    {
        $userId = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
        
        $this->repository->expects($this->once())
            ->method('countUnreadByRecipient')
            ->with($this->callback(fn($id) => $id instanceof RecipientId && $id->getValue() === $userId))
            ->willReturn(5);
        
        $response = $this->controller->getUnreadCount($userId);
        
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(200, $response->getStatusCode());
        
        $responseData = json_decode($response->getContent(), true);
        $this->assertEquals(5, $responseData['data']['count']);
    }
    
    public function testHandleInvalidJsonRequest(): void
    {
        $request = new Request([], [], [], [], [], [], 'invalid json');
        $request->headers->set('Content-Type', 'application/json');
        
        $response = $this->controller->send($request);
        
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(400, $response->getStatusCode());
        
        $responseData = json_decode($response->getContent(), true);
        $this->assertEquals('Invalid JSON', $responseData['error']);
    }
    
    public function testHandleMissingRequiredFields(): void
    {
        $requestData = [
            'recipientId' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            // missing required fields
        ];
        
        $request = new Request([], [], [], [], [], [], json_encode($requestData));
        $request->headers->set('Content-Type', 'application/json');
        
        $response = $this->controller->send($request);
        
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(400, $response->getStatusCode());
        
        $responseData = json_decode($response->getContent(), true);
        $this->assertArrayHasKey('error', $responseData);
    }
    
    private function createNotification(string $recipientId): Notification
    {
        return Notification::create(
            NotificationId::generate(),
            RecipientId::fromString($recipientId),
            NotificationType::courseAssigned(),
            NotificationChannel::email(),
            'Test Subject',
            'Test Content',
            NotificationPriority::medium()
        );
    }
} 