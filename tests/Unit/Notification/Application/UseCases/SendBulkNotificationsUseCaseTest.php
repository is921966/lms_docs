<?php

declare(strict_types=1);

namespace Tests\Unit\Notification\Application\UseCases;

use PHPUnit\Framework\TestCase;
use Notification\Application\UseCases\SendBulkNotificationsUseCase;
use Notification\Application\UseCases\SendNotificationUseCase;
use Notification\Application\UseCases\SendNotificationRequest;
use Notification\Application\DTO\NotificationDTO;

class SendBulkNotificationsUseCaseTest extends TestCase
{
    private SendNotificationUseCase $sendNotificationUseCase;
    private SendBulkNotificationsUseCase $useCase;
    
    protected function setUp(): void
    {
        $this->sendNotificationUseCase = $this->createMock(SendNotificationUseCase::class);
        $this->useCase = new SendBulkNotificationsUseCase($this->sendNotificationUseCase);
    }
    
    public function testExecuteSendsAllNotifications(): void
    {
        $data = [
            'recipientIds' => [
                'f47ac10b-58cc-4372-a567-0e02b2c3d479',
                'a47ac10b-58cc-4372-a567-0e02b2c3d479'
            ],
            'type' => 'course_assigned',
            'channel' => 'email',
            'subject' => 'Course Assignment',
            'content' => 'You have been assigned to a new course',
            'priority' => 'medium',
            'metadata' => ['courseId' => '123']
        ];
        
        $this->sendNotificationUseCase->expects($this->exactly(2))
            ->method('execute')
            ->willReturnOnConsecutiveCalls(
                new NotificationDTO(
                    id: 'id1',
                    recipientId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
                    type: 'course_assigned',
                    channel: 'email',
                    subject: 'Course Assignment',
                    content: 'You have been assigned to a new course',
                    priority: 'medium',
                    status: 'sent',
                    metadata: ['courseId' => '123'],
                    createdAt: '2025-07-02T10:00:00+00:00'
                ),
                new NotificationDTO(
                    id: 'id2',
                    recipientId: 'a47ac10b-58cc-4372-a567-0e02b2c3d479',
                    type: 'course_assigned',
                    channel: 'email',
                    subject: 'Course Assignment',
                    content: 'You have been assigned to a new course',
                    priority: 'medium',
                    status: 'sent',
                    metadata: ['courseId' => '123'],
                    createdAt: '2025-07-02T10:00:00+00:00'
                )
            );
        
        $result = $this->useCase->execute($data);
        $resultArray = $result->toArray();
        
        $this->assertCount(2, $resultArray['results']);
        $this->assertEquals(2, $resultArray['total']);
        $this->assertEquals(2, $resultArray['successful']);
        $this->assertEquals(0, $resultArray['failed']);
    }
    
    public function testExecuteHandlesPartialFailures(): void
    {
        $data = [
            'recipientIds' => [
                'f47ac10b-58cc-4372-a567-0e02b2c3d479',
                'a47ac10b-58cc-4372-a567-0e02b2c3d479'
            ],
            'type' => 'course_assigned',
            'channel' => 'email',
            'subject' => 'Course Assignment',
            'content' => 'You have been assigned to a new course',
            'priority' => 'medium'
        ];
        
        $this->sendNotificationUseCase->expects($this->exactly(2))
            ->method('execute')
            ->willReturnCallback(function (SendNotificationRequest $request) {
                if ($request->recipientId === 'f47ac10b-58cc-4372-a567-0e02b2c3d479') {
                    return new NotificationDTO(
                        id: 'id1',
                        recipientId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
                        type: 'course_assigned',
                        channel: 'email',
                        subject: 'Course Assignment',
                        content: 'You have been assigned to a new course',
                        priority: 'medium',
                        status: 'sent',
                        metadata: [],
                        createdAt: '2025-07-02T10:00:00+00:00'
                    );
                }
                throw new \Exception('Failed to send notification');
            });
        
        $result = $this->useCase->execute($data);
        $resultArray = $result->toArray();
        
        $this->assertCount(2, $resultArray['results']);
        $this->assertEquals(2, $resultArray['total']);
        $this->assertEquals(1, $resultArray['successful']);
        $this->assertEquals(1, $resultArray['failed']);
        
        // Check that we have one success and one failure
        $successCount = 0;
        $failureCount = 0;
        foreach ($resultArray['results'] as $item) {
            if ($item['status'] === 'sent') {
                $successCount++;
            } else {
                $failureCount++;
            }
        }
        $this->assertEquals(1, $successCount);
        $this->assertEquals(1, $failureCount);
    }
    
    public function testExecuteWithEmptyRecipients(): void
    {
        $data = [
            'recipientIds' => [],
            'type' => 'course_assigned',
            'channel' => 'email',
            'subject' => 'Course Assignment',
            'content' => 'You have been assigned to a new course',
            'priority' => 'medium'
        ];
        
        $result = $this->useCase->execute($data);
        $resultArray = $result->toArray();
        
        $this->assertEmpty($resultArray['results']);
        $this->assertEquals(0, $resultArray['total']);
        $this->assertEquals(0, $resultArray['successful']);
        $this->assertEquals(0, $resultArray['failed']);
    }
} 