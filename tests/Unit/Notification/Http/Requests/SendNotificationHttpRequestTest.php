<?php

declare(strict_types=1);

namespace Tests\Unit\Notification\Http\Requests;

use PHPUnit\Framework\TestCase;
use Notification\Http\Requests\SendNotificationHttpRequest;
use Symfony\Component\HttpFoundation\Request;

class SendNotificationHttpRequestTest extends TestCase
{
    public function testCreateFromValidRequest(): void
    {
        $data = [
            'recipientId' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            'type' => 'course_assigned',
            'channel' => 'email',
            'subject' => 'Course Assignment',
            'content' => 'You have been assigned to a new course',
            'priority' => 'medium',
            'metadata' => ['courseId' => '123']
        ];
        
        $symfonyRequest = new Request([], [], [], [], [], [], json_encode($data));
        $symfonyRequest->headers->set('Content-Type', 'application/json');
        
        $request = SendNotificationHttpRequest::createFromRequest($symfonyRequest);
        
        $this->assertEquals($data['recipientId'], $request->getRecipientId());
        $this->assertEquals($data['type'], $request->getType());
        $this->assertEquals($data['channel'], $request->getChannel());
        $this->assertEquals($data['subject'], $request->getSubject());
        $this->assertEquals($data['content'], $request->getContent());
        $this->assertEquals($data['priority'], $request->getPriority());
        $this->assertEquals($data['metadata'], $request->getMetadata());
    }
    
    public function testCreateWithoutOptionalMetadata(): void
    {
        $data = [
            'recipientId' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            'type' => 'course_assigned',
            'channel' => 'email',
            'subject' => 'Course Assignment',
            'content' => 'You have been assigned to a new course',
            'priority' => 'medium'
        ];
        
        $symfonyRequest = new Request([], [], [], [], [], [], json_encode($data));
        $symfonyRequest->headers->set('Content-Type', 'application/json');
        
        $request = SendNotificationHttpRequest::createFromRequest($symfonyRequest);
        
        $this->assertEquals([], $request->getMetadata());
    }
    
    public function testValidationRules(): void
    {
        $request = new SendNotificationHttpRequest();
        $rules = $request->rules();
        
        $this->assertArrayHasKey('recipientId', $rules);
        $this->assertContains('required', $rules['recipientId']);
        $this->assertContains('uuid', $rules['recipientId']);
        
        $this->assertArrayHasKey('type', $rules);
        $this->assertContains('required', $rules['type']);
        $this->assertContains('in:course_assigned,course_completed,deadline_reminder,system_announcement', $rules['type']);
        
        $this->assertArrayHasKey('channel', $rules);
        $this->assertContains('required', $rules['channel']);
        $this->assertContains('in:email,push,sms,in_app', $rules['channel']);
        
        $this->assertArrayHasKey('priority', $rules);
        $this->assertContains('required', $rules['priority']);
        $this->assertContains('in:low,medium,high', $rules['priority']);
        
        $this->assertArrayHasKey('metadata', $rules);
        $this->assertContains('array', $rules['metadata']);
    }
    
    public function testValidateWithValidData(): void
    {
        $data = [
            'recipientId' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            'type' => 'course_assigned',
            'channel' => 'email',
            'subject' => 'Course Assignment',
            'content' => 'You have been assigned to a new course',
            'priority' => 'medium'
        ];
        
        $symfonyRequest = new Request([], [], [], [], [], [], json_encode($data));
        $symfonyRequest->headers->set('Content-Type', 'application/json');
        
        $request = SendNotificationHttpRequest::createFromRequest($symfonyRequest);
        $errors = $request->validate();
        
        $this->assertEmpty($errors);
    }
    
    public function testValidateWithInvalidUuid(): void
    {
        $data = [
            'recipientId' => 'invalid-uuid',
            'type' => 'course_assigned',
            'channel' => 'email',
            'subject' => 'Course Assignment',
            'content' => 'You have been assigned to a new course',
            'priority' => 'medium'
        ];
        
        $symfonyRequest = new Request([], [], [], [], [], [], json_encode($data));
        $symfonyRequest->headers->set('Content-Type', 'application/json');
        
        $request = SendNotificationHttpRequest::createFromRequest($symfonyRequest);
        $errors = $request->validate();
        
        $this->assertNotEmpty($errors);
        $this->assertArrayHasKey('recipientId', $errors);
    }
    
    public function testValidateWithInvalidType(): void
    {
        $data = [
            'recipientId' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            'type' => 'invalid_type',
            'channel' => 'email',
            'subject' => 'Course Assignment',
            'content' => 'You have been assigned to a new course',
            'priority' => 'medium'
        ];
        
        $symfonyRequest = new Request([], [], [], [], [], [], json_encode($data));
        $symfonyRequest->headers->set('Content-Type', 'application/json');
        
        $request = SendNotificationHttpRequest::createFromRequest($symfonyRequest);
        $errors = $request->validate();
        
        $this->assertNotEmpty($errors);
        $this->assertArrayHasKey('type', $errors);
    }
    
    public function testValidateWithMissingRequiredFields(): void
    {
        $data = [
            'recipientId' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            // missing other required fields
        ];
        
        $symfonyRequest = new Request([], [], [], [], [], [], json_encode($data));
        $symfonyRequest->headers->set('Content-Type', 'application/json');
        
        $request = SendNotificationHttpRequest::createFromRequest($symfonyRequest);
        $errors = $request->validate();
        
        $this->assertNotEmpty($errors);
        $this->assertArrayHasKey('type', $errors);
        $this->assertArrayHasKey('channel', $errors);
        $this->assertArrayHasKey('subject', $errors);
        $this->assertArrayHasKey('content', $errors);
        $this->assertArrayHasKey('priority', $errors);
    }
} 