<?php

declare(strict_types=1);

namespace Notification\Http\Requests;

use Symfony\Component\HttpFoundation\Request;

class SendNotificationHttpRequest
{
    private string $recipientId = '';
    private string $type = '';
    private string $channel = '';
    private string $subject = '';
    private string $content = '';
    private string $priority = '';
    private array $metadata = [];
    
    public static function createFromRequest(Request $request): self
    {
        $data = json_decode($request->getContent(), true) ?? [];
        
        $instance = new self();
        $instance->recipientId = $data['recipientId'] ?? '';
        $instance->type = $data['type'] ?? '';
        $instance->channel = $data['channel'] ?? '';
        $instance->subject = $data['subject'] ?? '';
        $instance->content = $data['content'] ?? '';
        $instance->priority = $data['priority'] ?? '';
        $instance->metadata = $data['metadata'] ?? [];
        
        return $instance;
    }
    
    public function rules(): array
    {
        return [
            'recipientId' => ['required', 'uuid'],
            'type' => ['required', 'in:course_assigned,course_completed,deadline_reminder,system_announcement'],
            'channel' => ['required', 'in:email,push,sms,in_app'],
            'subject' => ['required', 'string', 'max:255'],
            'content' => ['required', 'string'],
            'priority' => ['required', 'in:low,medium,high'],
            'metadata' => ['array']
        ];
    }
    
    public function validate(): array
    {
        $errors = [];
        $rules = $this->rules();
        
        // Validate recipientId
        if (empty($this->recipientId)) {
            $errors['recipientId'] = 'The recipientId field is required.';
        } elseif (!$this->isValidUuid($this->recipientId)) {
            $errors['recipientId'] = 'The recipientId must be a valid UUID.';
        }
        
        // Validate type
        if (empty($this->type)) {
            $errors['type'] = 'The type field is required.';
        } elseif (!in_array($this->type, ['course_assigned', 'course_completed', 'deadline_reminder', 'system_announcement'])) {
            $errors['type'] = 'The selected type is invalid.';
        }
        
        // Validate channel
        if (empty($this->channel)) {
            $errors['channel'] = 'The channel field is required.';
        } elseif (!in_array($this->channel, ['email', 'push', 'sms', 'in_app'])) {
            $errors['channel'] = 'The selected channel is invalid.';
        }
        
        // Validate subject
        if (empty($this->subject)) {
            $errors['subject'] = 'The subject field is required.';
        } elseif (strlen($this->subject) > 255) {
            $errors['subject'] = 'The subject may not be greater than 255 characters.';
        }
        
        // Validate content
        if (empty($this->content)) {
            $errors['content'] = 'The content field is required.';
        }
        
        // Validate priority
        if (empty($this->priority)) {
            $errors['priority'] = 'The priority field is required.';
        } elseif (!in_array($this->priority, ['low', 'medium', 'high'])) {
            $errors['priority'] = 'The selected priority is invalid.';
        }
        
        // Validate metadata
        if (!is_array($this->metadata)) {
            $errors['metadata'] = 'The metadata must be an array.';
        }
        
        return $errors;
    }
    
    private function isValidUuid(string $uuid): bool
    {
        $pattern = '/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i';
        return preg_match($pattern, $uuid) === 1;
    }
    
    public function getRecipientId(): string
    {
        return $this->recipientId;
    }
    
    public function getType(): string
    {
        return $this->type;
    }
    
    public function getChannel(): string
    {
        return $this->channel;
    }
    
    public function getSubject(): string
    {
        return $this->subject;
    }
    
    public function getContent(): string
    {
        return $this->content;
    }
    
    public function getPriority(): string
    {
        return $this->priority;
    }
    
    public function getMetadata(): array
    {
        return $this->metadata;
    }
} 