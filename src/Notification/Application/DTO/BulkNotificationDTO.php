<?php

declare(strict_types=1);

namespace Notification\Application\DTO;

class BulkNotificationDTO
{
    /**
     * @param array<array{recipientId: string, status: string, notificationId?: string, error?: string}> $results
     */
    public function __construct(
        private array $results,
        private int $totalCount,
        private int $successCount,
        private int $failureCount
    ) {
    }
    
    public function toArray(): array
    {
        return [
            'results' => $this->results,
            'total' => $this->totalCount,
            'successful' => $this->successCount,
            'failed' => $this->failureCount
        ];
    }
    
    public function getResults(): array
    {
        return $this->results;
    }
    
    public function getTotalCount(): int
    {
        return $this->totalCount;
    }
    
    public function getSuccessCount(): int
    {
        return $this->successCount;
    }
    
    public function getFailureCount(): int
    {
        return $this->failureCount;
    }
} 