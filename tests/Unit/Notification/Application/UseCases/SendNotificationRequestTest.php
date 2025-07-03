<?php

declare(strict_types=1);

namespace Tests\Unit\Notification\Application\UseCases;

use PHPUnit\Framework\TestCase;
use Notification\Application\UseCases\SendNotificationRequest;

class SendNotificationRequestTest extends TestCase
{
    public function testCanBeCreatedWithValidData(): void
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
        
        $this->assertEquals('f47ac10b-58cc-4372-a567-0e02b2c3d479', $request->recipientId);
        $this->assertEquals('course_assigned', $request->type);
        $this->assertEquals('email', $request->channel);
        $this->assertEquals('Course Assignment', $request->subject);
        $this->assertEquals('You have been assigned to a new course', $request->content);
        $this->assertEquals('medium', $request->priority);
        $this->assertEquals(['courseName' => 'PHP Advanced'], $request->metadata);
    }
    
    public function testCanBeCreatedWithDefaultPriority(): void
    {
        $request = new SendNotificationRequest(
            recipientId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            type: 'course_assigned',
            channel: 'email',
            subject: 'Course Assignment',
            content: 'You have been assigned to a new course'
        );
        
        $this->assertEquals('medium', $request->priority);
        $this->assertEquals([], $request->metadata);
    }
    
    public function testValidatesRecipientId(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid recipient ID');
        
        new SendNotificationRequest(
            recipientId: 'invalid-uuid',
            type: 'course_assigned',
            channel: 'email',
            subject: 'Course Assignment',
            content: 'You have been assigned to a new course'
        );
    }
    
    public function testValidatesEmptySubject(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Subject cannot be empty');
        
        new SendNotificationRequest(
            recipientId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            type: 'course_assigned',
            channel: 'email',
            subject: '',
            content: 'You have been assigned to a new course'
        );
    }
    
    public function testValidatesEmptyContent(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Content cannot be empty');
        
        new SendNotificationRequest(
            recipientId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            type: 'course_assigned',
            channel: 'email',
            subject: 'Course Assignment',
            content: ''
        );
    }
    
    public function testValidatesInvalidType(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid notification type');
        
        new SendNotificationRequest(
            recipientId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            type: 'invalid_type!',
            channel: 'email',
            subject: 'Course Assignment',
            content: 'You have been assigned to a new course'
        );
    }
    
    public function testValidatesInvalidChannel(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid notification channel');
        
        new SendNotificationRequest(
            recipientId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            type: 'course_assigned',
            channel: 'telegram',
            subject: 'Course Assignment',
            content: 'You have been assigned to a new course'
        );
    }
    
    public function testValidatesInvalidPriority(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid notification priority');
        
        new SendNotificationRequest(
            recipientId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            type: 'course_assigned',
            channel: 'email',
            subject: 'Course Assignment',
            content: 'You have been assigned to a new course',
            priority: 'urgent'
        );
    }
} 