<?php

declare(strict_types=1);

namespace Tests\Unit\Notification\Application\UseCases;

use PHPUnit\Framework\TestCase;
use Notification\Application\UseCases\SendNotificationUseCase;
use Notification\Application\UseCases\SendNotificationRequest;
use Notification\Application\Services\NotificationDispatcher;
use Notification\Domain\Repository\NotificationRepositoryInterface;
use Notification\Domain\Notification;
use Notification\Domain\ValueObjects\NotificationId;

class SendNotificationUseCaseTest extends TestCase
{
    private NotificationRepositoryInterface $repository;
    private NotificationDispatcher $dispatcher;
    private SendNotificationUseCase $useCase;
    
    protected function setUp(): void
    {
        $this->repository = $this->createMock(NotificationRepositoryInterface::class);
        $this->dispatcher = $this->createMock(NotificationDispatcher::class);
        $this->useCase = new SendNotificationUseCase($this->repository, $this->dispatcher);
    }
    
    public function testExecuteCreatesAndSavesNotification(): void
    {
        $request = new SendNotificationRequest(
            recipientId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            type: 'course_assigned',
            channel: 'email',
            subject: 'Course Assignment',
            content: 'You have been assigned to a new course',
            priority: 'medium',
            metadata: ['courseName' => 'PHP Advanced']
        );
        
        $this->repository->expects($this->once())
            ->method('save')
            ->with($this->isInstanceOf(Notification::class));
            
        $this->dispatcher->expects($this->once())
            ->method('dispatch')
            ->with($this->isInstanceOf(Notification::class));
        
        $result = $this->useCase->execute($request);
        
        $this->assertNotNull($result);
        $this->assertEquals('f47ac10b-58cc-4372-a567-0e02b2c3d479', $result->recipientId);
        $this->assertEquals('course_assigned', $result->type);
        $this->assertEquals('email', $result->channel);
        $this->assertEquals('Course Assignment', $result->subject);
        $this->assertEquals('You have been assigned to a new course', $result->content);
        $this->assertEquals('medium', $result->priority);
        $this->assertEquals('pending', $result->status);
        $this->assertEquals(['courseName' => 'PHP Advanced'], $result->metadata);
    }
    
    public function testExecuteGeneratesUniqueNotificationId(): void
    {
        $request = new SendNotificationRequest(
            recipientId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            type: 'course_assigned',
            channel: 'email',
            subject: 'Course Assignment',
            content: 'You have been assigned to a new course'
        );
        
        $capturedNotification = null;
        $this->repository->expects($this->once())
            ->method('save')
            ->willReturnCallback(function ($notification) use (&$capturedNotification) {
                $capturedNotification = $notification;
            });
            
        $this->dispatcher->expects($this->once())
            ->method('dispatch');
        
        $result = $this->useCase->execute($request);
        
        $this->assertNotNull($capturedNotification);
        $this->assertInstanceOf(Notification::class, $capturedNotification);
        $this->assertMatchesRegularExpression(
            '/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i',
            $capturedNotification->getId()->getValue()
        );
    }
    
    public function testExecuteHandlesDispatcherException(): void
    {
        $request = new SendNotificationRequest(
            recipientId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            type: 'course_assigned',
            channel: 'email',
            subject: 'Course Assignment',
            content: 'You have been assigned to a new course'
        );
        
        $this->repository->expects($this->once())
            ->method('save');
            
        $this->dispatcher->expects($this->once())
            ->method('dispatch')
            ->willThrowException(new \RuntimeException('Dispatcher error'));
        
        // The use case should still return a DTO even if dispatch fails
        $result = $this->useCase->execute($request);
        
        $this->assertNotNull($result);
        $this->assertEquals('pending', $result->status);
    }
} 