<?php

declare(strict_types=1);

namespace Notification\Http\Responses;

use Notification\Application\DTO\NotificationDTO;
use Symfony\Component\HttpFoundation\JsonResponse;

class NotificationResponse
{
    public static function success(NotificationDTO $notification): JsonResponse
    {
        return new JsonResponse([
            'success' => true,
            'data' => $notification->toArray()
        ], 200);
    }
    
    public static function created(NotificationDTO $notification): JsonResponse
    {
        return new JsonResponse([
            'success' => true,
            'data' => $notification->toArray()
        ], 201);
    }
    
    public static function list(array $notifications, int $count, int $total, int $offset): JsonResponse
    {
        $data = array_map(
            fn(NotificationDTO $dto) => $dto->toArray(),
            $notifications
        );
        
        return new JsonResponse([
            'success' => true,
            'data' => $data,
            'meta' => [
                'count' => $count,
                'total' => $total,
                'offset' => $offset
            ]
        ], 200);
    }
    
    public static function error(string $message, int $statusCode = 400): JsonResponse
    {
        return new JsonResponse([
            'success' => false,
            'error' => $message
        ], $statusCode);
    }
    
    public static function validationError(array $errors): JsonResponse
    {
        return new JsonResponse([
            'success' => false,
            'message' => 'Validation failed',
            'errors' => $errors
        ], 422);
    }
    
    public static function count(int $count): JsonResponse
    {
        return new JsonResponse([
            'success' => true,
            'data' => [
                'count' => $count
            ]
        ], 200);
    }
    
    public static function bulk(array $results): JsonResponse
    {
        $successful = 0;
        $failed = 0;
        
        foreach ($results as $result) {
            if ($result['status'] === 'sent') {
                $successful++;
            } else {
                $failed++;
            }
        }
        
        return new JsonResponse([
            'success' => true,
            'data' => [
                'results' => $results,
                'total' => count($results),
                'successful' => $successful,
                'failed' => $failed
            ]
        ], 200);
    }
} 