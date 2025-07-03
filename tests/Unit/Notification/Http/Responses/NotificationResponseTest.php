<?php

declare(strict_types=1);

namespace Tests\Unit\Notification\Http\Responses;

use PHPUnit\Framework\TestCase;
use Notification\Http\Responses\NotificationResponse;
use Notification\Application\DTO\NotificationDTO;
use Symfony\Component\HttpFoundation\JsonResponse;

class NotificationResponseTest extends TestCase
{
    public function testCreateSuccessResponse(): void
    {
        $notificationData = [
            'id' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            'recipientId' => 'a47ac10b-58cc-4372-a567-0e02b2c3d479',
            'type' => 'course_assigned',
            'channel' => 'email',
            'subject' => 'Course Assignment',
            'content' => 'You have been assigned to a new course',
            'priority' => 'medium',
            'status' => 'sent',
            'metadata' => ['courseId' => '123'],
            'createdAt' => '2025-07-03T10:00:00+00:00',
            'sentAt' => '2025-07-03T10:00:01+00:00'
        ];
        
        $dto = $this->createMock(NotificationDTO::class);
        $dto->method('toArray')->willReturn($notificationData);
        
        $response = NotificationResponse::success($dto);
        
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(200, $response->getStatusCode());
        
        $responseData = json_decode($response->getContent(), true);
        $this->assertTrue($responseData['success']);
        $this->assertEquals($notificationData, $responseData['data']);
    }
    
    public function testCreateCreatedResponse(): void
    {
        $notificationData = [
            'id' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            'recipientId' => 'a47ac10b-58cc-4372-a567-0e02b2c3d479',
            'type' => 'course_assigned',
            'status' => 'pending'
        ];
        
        $dto = $this->createMock(NotificationDTO::class);
        $dto->method('toArray')->willReturn($notificationData);
        
        $response = NotificationResponse::created($dto);
        
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(201, $response->getStatusCode());
        
        $responseData = json_decode($response->getContent(), true);
        $this->assertTrue($responseData['success']);
        $this->assertEquals($notificationData, $responseData['data']);
    }
    
    public function testCreateListResponse(): void
    {
        $notification1 = [
            'id' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            'type' => 'course_assigned',
            'status' => 'sent'
        ];
        
        $notification2 = [
            'id' => 'b47ac10b-58cc-4372-a567-0e02b2c3d479',
            'type' => 'system_announcement',
            'status' => 'delivered'
        ];
        
        $dto1 = $this->createMock(NotificationDTO::class);
        $dto1->method('toArray')->willReturn($notification1);
        
        $dto2 = $this->createMock(NotificationDTO::class);
        $dto2->method('toArray')->willReturn($notification2);
        
        $response = NotificationResponse::list([$dto1, $dto2], 2, 10, 0);
        
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(200, $response->getStatusCode());
        
        $responseData = json_decode($response->getContent(), true);
        $this->assertTrue($responseData['success']);
        $this->assertCount(2, $responseData['data']);
        $this->assertEquals(2, $responseData['meta']['count']);
        $this->assertEquals(10, $responseData['meta']['total']);
        $this->assertEquals(0, $responseData['meta']['offset']);
    }
    
    public function testCreateErrorResponse(): void
    {
        $response = NotificationResponse::error('Invalid notification data', 400);
        
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(400, $response->getStatusCode());
        
        $responseData = json_decode($response->getContent(), true);
        $this->assertFalse($responseData['success']);
        $this->assertEquals('Invalid notification data', $responseData['error']);
    }
    
    public function testCreateValidationErrorResponse(): void
    {
        $errors = [
            'recipientId' => 'The recipientId field is required.',
            'type' => 'The selected type is invalid.'
        ];
        
        $response = NotificationResponse::validationError($errors);
        
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(422, $response->getStatusCode());
        
        $responseData = json_decode($response->getContent(), true);
        $this->assertFalse($responseData['success']);
        $this->assertEquals('Validation failed', $responseData['message']);
        $this->assertEquals($errors, $responseData['errors']);
    }
    
    public function testCreateCountResponse(): void
    {
        $response = NotificationResponse::count(5);
        
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(200, $response->getStatusCode());
        
        $responseData = json_decode($response->getContent(), true);
        $this->assertTrue($responseData['success']);
        $this->assertEquals(5, $responseData['data']['count']);
    }
    
    public function testCreateBulkResponse(): void
    {
        $results = [
            ['recipientId' => 'user1', 'status' => 'sent', 'notificationId' => 'id1'],
            ['recipientId' => 'user2', 'status' => 'failed', 'error' => 'Invalid email'],
            ['recipientId' => 'user3', 'status' => 'sent', 'notificationId' => 'id3']
        ];
        
        $response = NotificationResponse::bulk($results);
        
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(200, $response->getStatusCode());
        
        $responseData = json_decode($response->getContent(), true);
        $this->assertTrue($responseData['success']);
        $this->assertCount(3, $responseData['data']['results']);
        $this->assertEquals(3, $responseData['data']['total']);
        $this->assertEquals(2, $responseData['data']['successful']);
        $this->assertEquals(1, $responseData['data']['failed']);
    }
} 