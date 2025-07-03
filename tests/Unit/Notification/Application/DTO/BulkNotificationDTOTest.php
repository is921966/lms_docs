<?php

declare(strict_types=1);

namespace Tests\Unit\Notification\Application\DTO;

use PHPUnit\Framework\TestCase;
use Notification\Application\DTO\BulkNotificationDTO;

class BulkNotificationDTOTest extends TestCase
{
    public function testCanBeCreatedWithResults(): void
    {
        $results = [
            [
                'recipientId' => 'a47ac10b-58cc-4372-a567-0e02b2c3d479',
                'status' => 'sent',
                'notificationId' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479'
            ],
            [
                'recipientId' => 'b47ac10b-58cc-4372-a567-0e02b2c3d479',
                'status' => 'sent',
                'notificationId' => 'c47ac10b-58cc-4372-a567-0e02b2c3d479'
            ]
        ];
        
        $bulkDto = new BulkNotificationDTO(
            results: $results,
            totalCount: 2,
            successCount: 2,
            failureCount: 0
        );
        
        $this->assertCount(2, $bulkDto->getResults());
        $this->assertEquals(2, $bulkDto->getTotalCount());
        $this->assertEquals(2, $bulkDto->getSuccessCount());
        $this->assertEquals(0, $bulkDto->getFailureCount());
    }
    
    public function testCanBeCreatedWithPartialSuccess(): void
    {
        $results = [
            [
                'recipientId' => 'a47ac10b-58cc-4372-a567-0e02b2c3d479',
                'status' => 'sent',
                'notificationId' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479'
            ],
            [
                'recipientId' => 'b47ac10b-58cc-4372-a567-0e02b2c3d479',
                'status' => 'failed',
                'error' => 'Invalid email address'
            ],
            [
                'recipientId' => 'c47ac10b-58cc-4372-a567-0e02b2c3d479',
                'status' => 'failed',
                'error' => 'SMTP connection failed'
            ]
        ];
        
        $bulkDto = new BulkNotificationDTO(
            results: $results,
            totalCount: 3,
            successCount: 1,
            failureCount: 2
        );
        
        $this->assertCount(3, $bulkDto->getResults());
        $this->assertEquals(3, $bulkDto->getTotalCount());
        $this->assertEquals(1, $bulkDto->getSuccessCount());
        $this->assertEquals(2, $bulkDto->getFailureCount());
    }
    
    public function testCanBeConvertedToArray(): void
    {
        $results = [
            [
                'recipientId' => 'a47ac10b-58cc-4372-a567-0e02b2c3d479',
                'status' => 'sent',
                'notificationId' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479'
            ]
        ];
        
        $bulkDto = new BulkNotificationDTO(
            results: $results,
            totalCount: 1,
            successCount: 1,
            failureCount: 0
        );
        
        $array = $bulkDto->toArray();
        
        $this->assertIsArray($array);
        $this->assertArrayHasKey('results', $array);
        $this->assertArrayHasKey('total', $array);
        $this->assertArrayHasKey('successful', $array);
        $this->assertArrayHasKey('failed', $array);
        $this->assertCount(1, $array['results']);
        $this->assertEquals(1, $array['total']);
        $this->assertEquals(1, $array['successful']);
        $this->assertEquals(0, $array['failed']);
    }
} 