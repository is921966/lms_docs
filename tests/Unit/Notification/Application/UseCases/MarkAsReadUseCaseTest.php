<?php

declare(strict_types=1);

namespace Tests\Unit\Notification\Application\UseCases;

use PHPUnit\Framework\TestCase;
use Notification\Application\UseCases\MarkAsReadUseCase;
use Notification\Domain\Repository\NotificationRepositoryInterface;
use Notification\Domain\Notification;
use Notification\Domain\ValueObjects\NotificationId;
use Notification\Domain\ValueObjects\NotificationType;
use Notification\Domain\ValueObjects\NotificationChannel;
use Notification\Domain\ValueObjects\NotificationPriority;
use Notification\Domain\ValueObjects\NotificationStatus;
use Notification\Domain\ValueObjects\RecipientId;

class MarkAsReadUseCaseTest extends TestCase
{
    private NotificationRepositoryInterface $repository;
    private MarkAsReadUseCase $useCase;
    
    protected function setUp(): void
    {
        $this->repository = $this->createMock(NotificationRepositoryInterface::class);
        $this->useCase = new MarkAsReadUseCase($this->repository);
    }
    
    public function testExecuteMarksNotificationAsRead(): void
    {
        $notificationId = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
        $notification = $this->createDeliveredNotification($notificationId);
        
        $this->repository->expects($this->once())
            ->method('findById')
            ->with($this->isInstanceOf(NotificationId::class))
            ->willReturn($notification);
            
        $this->repository->expects($this->once())
            ->method('save')
            ->with($notification);
        
        $result = $this->useCase->execute($notificationId);
        
        $this->assertTrue($result);
        $this->assertEquals('read', $notification->getStatus()->getValue());
        $this->assertNotNull($notification->getReadAt());
    }
    
    public function testExecuteReturnsFalseWhenNotificationNotFound(): void
    {
        $notificationId = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
        
        $this->repository->expects($this->once())
            ->method('findById')
            ->with($this->isInstanceOf(NotificationId::class))
            ->willReturn(null);
            
        $this->repository->expects($this->never())
            ->method('save');
        
        $result = $this->useCase->execute($notificationId);
        
        $this->assertFalse($result);
    }
    
    public function testExecuteThrowsExceptionForInvalidNotificationId(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid notification ID');
        
        $this->useCase->execute('invalid-uuid');
    }
    
    public function testExecuteThrowsExceptionWhenStatusTransitionNotAllowed(): void
    {
        $notificationId = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
        $notification = $this->createPendingNotification($notificationId);
        
        $this->repository->expects($this->once())
            ->method('findById')
            ->with($this->isInstanceOf(NotificationId::class))
            ->willReturn($notification);
            
        $this->repository->expects($this->never())
            ->method('save');
        
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Invalid status transition');
        
        $this->useCase->execute($notificationId);
    }
    
    private function createDeliveredNotification(string $id): Notification
    {
        $notification = Notification::create(
            NotificationId::fromString($id),
            RecipientId::fromString('a47ac10b-58cc-4372-a567-0e02b2c3d479'),
            NotificationType::courseAssigned(),
            NotificationChannel::email(),
            'Course Assignment',
            'You have been assigned to a new course',
            NotificationPriority::medium()
        );
        
        $notification->markAsSent();
        $notification->markAsDelivered();
        
        return $notification;
    }
    
    private function createPendingNotification(string $id): Notification
    {
        return Notification::create(
            NotificationId::fromString($id),
            RecipientId::fromString('a47ac10b-58cc-4372-a567-0e02b2c3d479'),
            NotificationType::courseAssigned(),
            NotificationChannel::email(),
            'Course Assignment',
            'You have been assigned to a new course',
            NotificationPriority::medium()
        );
    }
} 