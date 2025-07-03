<?php

declare(strict_types=1);

namespace Tests\Unit\Notification\Application\DTO;

use PHPUnit\Framework\TestCase;
use Notification\Application\DTO\NotificationDTO;
use Notification\Domain\Notification;
use Notification\Domain\ValueObjects\NotificationId;
use Notification\Domain\ValueObjects\NotificationType;
use Notification\Domain\ValueObjects\NotificationChannel;
use Notification\Domain\ValueObjects\NotificationPriority;
use Notification\Domain\ValueObjects\NotificationStatus;
use Notification\Domain\ValueObjects\RecipientId;

class NotificationDTOTest extends TestCase
{
    public function testCanBeCreatedFromArray(): void
    {
        $data = [
            'id' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            'recipientId' => 'a47ac10b-58cc-4372-a567-0e02b2c3d479',
            'type' => 'course_assigned',
            'channel' => 'email',
            'subject' => 'Course Assignment',
            'content' => 'You have been assigned to a new course',
            'priority' => 'medium',
            'status' => 'pending',
            'metadata' => ['courseName' => 'PHP Advanced'],
            'createdAt' => '2025-07-02T10:00:00+00:00',
            'sentAt' => null,
            'deliveredAt' => null,
            'readAt' => null,
            'failedAt' => null,
            'failureReason' => null
        ];
        
        $dto = NotificationDTO::fromArray($data);
        
        $this->assertEquals('f47ac10b-58cc-4372-a567-0e02b2c3d479', $dto->id);
        $this->assertEquals('a47ac10b-58cc-4372-a567-0e02b2c3d479', $dto->recipientId);
        $this->assertEquals('course_assigned', $dto->type);
        $this->assertEquals('email', $dto->channel);
        $this->assertEquals('Course Assignment', $dto->subject);
        $this->assertEquals('You have been assigned to a new course', $dto->content);
        $this->assertEquals('medium', $dto->priority);
        $this->assertEquals('pending', $dto->status);
        $this->assertEquals(['courseName' => 'PHP Advanced'], $dto->metadata);
        $this->assertEquals('2025-07-02T10:00:00+00:00', $dto->createdAt);
        $this->assertNull($dto->sentAt);
    }
    
    public function testCanBeCreatedFromEntity(): void
    {
        $notification = Notification::create(
            NotificationId::fromString('f47ac10b-58cc-4372-a567-0e02b2c3d479'),
            RecipientId::fromString('a47ac10b-58cc-4372-a567-0e02b2c3d479'),
            NotificationType::courseAssigned(),
            NotificationChannel::email(),
            'Course Assignment',
            'You have been assigned to a new course',
            NotificationPriority::medium(),
            ['courseName' => 'PHP Advanced']
        );
        
        $dto = NotificationDTO::fromEntity($notification);
        
        $this->assertEquals('f47ac10b-58cc-4372-a567-0e02b2c3d479', $dto->id);
        $this->assertEquals('a47ac10b-58cc-4372-a567-0e02b2c3d479', $dto->recipientId);
        $this->assertEquals('course_assigned', $dto->type);
        $this->assertEquals('email', $dto->channel);
        $this->assertEquals('Course Assignment', $dto->subject);
        $this->assertEquals('You have been assigned to a new course', $dto->content);
        $this->assertEquals('medium', $dto->priority);
        $this->assertEquals('pending', $dto->status);
        $this->assertEquals(['courseName' => 'PHP Advanced'], $dto->metadata);
        $this->assertNotNull($dto->createdAt);
    }
    
    public function testCanBeConvertedToArray(): void
    {
        $notification = Notification::create(
            NotificationId::fromString('f47ac10b-58cc-4372-a567-0e02b2c3d479'),
            RecipientId::fromString('a47ac10b-58cc-4372-a567-0e02b2c3d479'),
            NotificationType::courseAssigned(),
            NotificationChannel::email(),
            'Course Assignment',
            'You have been assigned to a new course',
            NotificationPriority::medium()
        );
        
        $dto = NotificationDTO::fromEntity($notification);
        $array = $dto->toArray();
        
        $this->assertIsArray($array);
        $this->assertArrayHasKey('id', $array);
        $this->assertArrayHasKey('recipientId', $array);
        $this->assertArrayHasKey('type', $array);
        $this->assertArrayHasKey('channel', $array);
        $this->assertArrayHasKey('subject', $array);
        $this->assertArrayHasKey('content', $array);
        $this->assertArrayHasKey('priority', $array);
        $this->assertArrayHasKey('status', $array);
        $this->assertArrayHasKey('metadata', $array);
        $this->assertArrayHasKey('createdAt', $array);
    }
    
    public function testHandlesNullableFields(): void
    {
        $data = [
            'id' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            'recipientId' => 'a47ac10b-58cc-4372-a567-0e02b2c3d479',
            'type' => 'course_assigned',
            'channel' => 'email',
            'subject' => 'Course Assignment',
            'content' => 'You have been assigned to a new course',
            'priority' => 'medium',
            'status' => 'sent',
            'metadata' => [],
            'createdAt' => '2025-07-02T10:00:00+00:00',
            'sentAt' => '2025-07-02T10:01:00+00:00',
            'deliveredAt' => null,
            'readAt' => null,
            'failedAt' => null,
            'failureReason' => null
        ];
        
        $dto = NotificationDTO::fromArray($data);
        
        $this->assertEquals('2025-07-02T10:01:00+00:00', $dto->sentAt);
        $this->assertNull($dto->deliveredAt);
        $this->assertNull($dto->readAt);
        $this->assertNull($dto->failedAt);
        $this->assertNull($dto->failureReason);
    }
} 