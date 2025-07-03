<?php

declare(strict_types=1);

namespace Notification\Http\Controllers;

use Notification\Application\UseCases\SendNotificationUseCase;
use Notification\Application\UseCases\SendBulkNotificationsUseCase;
use Notification\Application\UseCases\MarkAsReadUseCase;
use Notification\Application\UseCases\SendNotificationRequest;
use Notification\Domain\Repository\NotificationRepositoryInterface;
use Notification\Domain\ValueObjects\RecipientId;
use Notification\Application\DTO\NotificationDTO;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;

class NotificationController
{
    public function __construct(
        private SendNotificationUseCase $sendNotificationUseCase,
        private SendBulkNotificationsUseCase $sendBulkNotificationsUseCase,
        private MarkAsReadUseCase $markAsReadUseCase,
        private NotificationRepositoryInterface $repository
    ) {
    }
    
    public function send(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true);
        
        if (json_last_error() !== JSON_ERROR_NONE) {
            return new JsonResponse(['error' => 'Invalid JSON'], 400);
        }
        
        $requiredFields = ['recipientId', 'type', 'channel', 'subject', 'content', 'priority'];
        foreach ($requiredFields as $field) {
            if (!isset($data[$field])) {
                return new JsonResponse(['error' => "Missing required field: $field"], 400);
            }
        }
        
        try {
            $sendRequest = new SendNotificationRequest(
                $data['recipientId'],
                $data['type'],
                $data['channel'],
                $data['subject'],
                $data['content'],
                $data['priority'],
                $data['metadata'] ?? []
            );
            
            $notificationDto = $this->sendNotificationUseCase->execute($sendRequest);
            
            return new JsonResponse([
                'data' => $notificationDto->toArray()
            ], 201);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => $e->getMessage()], 400);
        }
    }
    
    public function sendBulk(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true);
        
        if (json_last_error() !== JSON_ERROR_NONE) {
            return new JsonResponse(['error' => 'Invalid JSON'], 400);
        }
        
        try {
            $bulkRequest = [
                'recipientIds' => $data['recipientIds'] ?? [],
                'type' => $data['type'],
                'channel' => $data['channel'],
                'subject' => $data['subject'],
                'content' => $data['content'],
                'priority' => $data['priority'],
                'metadata' => $data['metadata'] ?? []
            ];
            
            $bulkDto = $this->sendBulkNotificationsUseCase->execute($bulkRequest);
            
            return new JsonResponse([
                'data' => $bulkDto->toArray()
            ]);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => $e->getMessage()], 400);
        }
    }
    
    public function getUserNotifications(string $userId, Request $request): JsonResponse
    {
        try {
            $limit = (int) ($request->query->get('limit', '50'));
            $offset = (int) ($request->query->get('offset', '0'));
            
            $notifications = $this->repository->findByRecipient(
                RecipientId::fromString($userId),
                $limit,
                $offset
            );
            
            $data = array_map(
                fn($notification) => NotificationDTO::fromEntity($notification)->toArray(),
                $notifications
            );
            
            return new JsonResponse(['data' => $data]);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => $e->getMessage()], 400);
        }
    }
    
    public function markAsRead(string $notificationId): JsonResponse
    {
        try {
            $this->markAsReadUseCase->execute($notificationId);
            
            return new JsonResponse(['message' => 'Notification marked as read']);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => $e->getMessage()], 400);
        }
    }
    
    public function markAllAsRead(string $userId): JsonResponse
    {
        try {
            $this->repository->markAllAsReadForRecipient(
                RecipientId::fromString($userId)
            );
            
            return new JsonResponse(['message' => 'All notifications marked as read']);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => $e->getMessage()], 400);
        }
    }
    
    public function getUnreadCount(string $userId): JsonResponse
    {
        try {
            $count = $this->repository->countUnreadByRecipient(
                RecipientId::fromString($userId)
            );
            
            return new JsonResponse(['data' => ['count' => $count]]);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => $e->getMessage()], 400);
        }
    }
} 