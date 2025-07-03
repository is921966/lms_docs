<?php

declare(strict_types=1);

namespace Notification\Application\UseCases;

use Notification\Application\DTO\BulkNotificationDTO;
use Notification\Application\DTO\NotificationDTO;

class SendBulkNotificationsUseCase
{
    public function __construct(
        private SendNotificationUseCase $sendNotificationUseCase
    ) {
    }
    
    /**
     * @param array{
     *     recipientIds: array<string>,
     *     type: string,
     *     channel: string,
     *     subject: string,
     *     content: string,
     *     priority: string,
     *     metadata?: array<string, mixed>
     * } $data
     */
    public function execute(array $data): BulkNotificationDTO
    {
        $notifications = [];
        $results = [];
        $totalCount = count($data['recipientIds']);
        $successCount = 0;
        $failureCount = 0;
        
        foreach ($data['recipientIds'] as $recipientId) {
            try {
                $request = new SendNotificationRequest(
                    recipientId: $recipientId,
                    type: $data['type'],
                    channel: $data['channel'],
                    subject: $data['subject'],
                    content: $data['content'],
                    priority: $data['priority'],
                    metadata: $data['metadata'] ?? []
                );
                
                $notification = $this->sendNotificationUseCase->execute($request);
                $notifications[] = $notification;
                $results[] = [
                    'recipientId' => $recipientId,
                    'status' => 'sent',
                    'notificationId' => $notification->toArray()['id']
                ];
                $successCount++;
            } catch (\Exception $e) {
                $results[] = [
                    'recipientId' => $recipientId,
                    'status' => 'failed',
                    'error' => $e->getMessage()
                ];
                $failureCount++;
            }
        }
        
        return new BulkNotificationDTO(
            results: $results,
            totalCount: $totalCount,
            successCount: $successCount,
            failureCount: $failureCount
        );
    }
} 