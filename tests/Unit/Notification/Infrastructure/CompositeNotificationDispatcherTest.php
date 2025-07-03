<?php

declare(strict_types=1);

namespace Tests\Unit\Notification\Infrastructure;

use PHPUnit\Framework\TestCase;
use Notification\Infrastructure\CompositeNotificationDispatcher;
use Notification\Infrastructure\Email\EmailNotificationSender;
use Notification\Domain\Repository\NotificationRepositoryInterface;
use Notification\Domain\Notification;
use Notification\Domain\ValueObjects\NotificationId;
use Notification\Domain\ValueObjects\NotificationType;
use Notification\Domain\ValueObjects\NotificationChannel;
use Notification\Domain\ValueObjects\NotificationPriority;
use Notification\Domain\ValueObjects\RecipientId;

class CompositeNotificationDispatcherTest extends TestCase
{
    private NotificationRepositoryInterface $repository;
    private EmailNotificationSender $emailSender;
    private CompositeNotificationDispatcher $dispatcher;
    
    protected function setUp(): void
    {
        $this->repository = $this->createMock(NotificationRepositoryInterface::class);
        $this->emailSender = $this->createMock(EmailNotificationSender::class);
        $this->dispatcher = new CompositeNotificationDispatcher($this->repository);
        $this->dispatcher->addSender($this->emailSender);
    }
    
    public function testDispatchToSupportedSender(): void
    {
        $notification = $this->createEmailNotification();
        
        $this->emailSender->expects($this->once())
            ->method('supports')
            ->with($notification)
            ->willReturn(true);
            
        $this->emailSender->expects($this->once())
            ->method('send')
            ->with($notification);
            
        $this->repository->expects($this->once())
            ->method('save')
            ->with($notification);
        
        $this->dispatcher->dispatch($notification);
        
        $this->assertEquals('sent', $notification->getStatus()->getValue());
    }
    
    public function testDispatchWithNoSupportedSender(): void
    {
        $notification = Notification::create(
            NotificationId::generate(),
            RecipientId::fromString('f47ac10b-58cc-4372-a567-0e02b2c3d479'),
            NotificationType::courseAssigned(),
            NotificationChannel::push(),
            'Push Subject',
            'Push Content',
            NotificationPriority::medium()
        );
        
        $this->emailSender->expects($this->once())
            ->method('supports')
            ->with($notification)
            ->willReturn(false);
            
        $this->emailSender->expects($this->never())
            ->method('send');
            
        $this->repository->expects($this->never())
            ->method('save');
        
        $this->expectException(\RuntimeException::class);
        $this->expectExceptionMessage('No sender available for notification channel: push');
        
        $this->dispatcher->dispatch($notification);
    }
    
    public function testDispatchHandlesSenderException(): void
    {
        $notification = $this->createEmailNotification();
        
        $this->emailSender->expects($this->once())
            ->method('supports')
            ->with($notification)
            ->willReturn(true);
            
        $this->emailSender->expects($this->once())
            ->method('send')
            ->with($notification)
            ->willThrowException(new \RuntimeException('SMTP error'));
            
        $this->repository->expects($this->once())
            ->method('save')
            ->with($notification);
        
        $this->expectException(\RuntimeException::class);
        $this->expectExceptionMessage('Failed to dispatch notification');
        
        try {
            $this->dispatcher->dispatch($notification);
        } catch (\RuntimeException $e) {
            // Verify notification was marked as failed
            $this->assertEquals('failed', $notification->getStatus()->getValue());
            $this->assertEquals('SMTP error', $notification->getFailureReason());
            throw $e;
        }
    }
    
    public function testCanAddMultipleSenders(): void
    {
        $pushSender = $this->createMock(EmailNotificationSender::class);
        $this->dispatcher->addSender($pushSender);
        
        $notification = $this->createEmailNotification();
        
        // First sender doesn't support
        $this->emailSender->expects($this->once())
            ->method('supports')
            ->with($notification)
            ->willReturn(false);
            
        // Second sender supports
        $pushSender->expects($this->once())
            ->method('supports')
            ->with($notification)
            ->willReturn(true);
            
        $pushSender->expects($this->once())
            ->method('send')
            ->with($notification);
            
        $this->repository->expects($this->once())
            ->method('save');
        
        $this->dispatcher->dispatch($notification);
    }
    
    private function createEmailNotification(): Notification
    {
        return Notification::create(
            NotificationId::generate(),
            RecipientId::fromString('f47ac10b-58cc-4372-a567-0e02b2c3d479'),
            NotificationType::courseAssigned(),
            NotificationChannel::email(),
            'Course Assignment',
            'You have been assigned to a new course',
            NotificationPriority::medium()
        );
    }
} 