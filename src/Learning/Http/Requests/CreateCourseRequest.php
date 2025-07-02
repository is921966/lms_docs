<?php

declare(strict_types=1);

namespace Learning\Http\Requests;

use InvalidArgumentException;

final class CreateCourseRequest
{
    private array $data;
    private array $errors = [];
    
    public function __construct(array $data)
    {
        $this->data = $data;
        $this->validate();
    }
    
    private function validate(): void
    {
        if (empty($this->data['course_code'])) {
            $this->errors['course_code'] = 'Course code is required';
        } elseif (!preg_match('/^[A-Z]{2,10}-\d{3,5}$/', $this->data['course_code'])) {
            $this->errors['course_code'] = 'Course code must be in format XX-123';
        }
        
        if (empty($this->data['title'])) {
            $this->errors['title'] = 'Title is required';
        } elseif (strlen($this->data['title']) < 3) {
            $this->errors['title'] = 'Title must be at least 3 characters';
        } elseif (strlen($this->data['title']) > 255) {
            $this->errors['title'] = 'Title must not exceed 255 characters';
        }
        
        if (empty($this->data['description'])) {
            $this->errors['description'] = 'Description is required';
        } elseif (strlen($this->data['description']) < 10) {
            $this->errors['description'] = 'Description must be at least 10 characters';
        }
        
        if (empty($this->data['duration_hours'])) {
            $this->errors['duration_hours'] = 'Duration is required';
        } elseif (!is_numeric($this->data['duration_hours']) || $this->data['duration_hours'] <= 0) {
            $this->errors['duration_hours'] = 'Duration must be a positive number';
        } elseif ($this->data['duration_hours'] > 1000) {
            $this->errors['duration_hours'] = 'Duration cannot exceed 1000 hours';
        }
        
        if (empty($this->data['instructor_id'])) {
            $this->errors['instructor_id'] = 'Instructor ID is required';
        }
        
        if (!empty($this->data['metadata']) && !is_array($this->data['metadata'])) {
            $this->errors['metadata'] = 'Metadata must be an array';
        }
    }
    
    public function isValid(): bool
    {
        return empty($this->errors);
    }
    
    public function getErrors(): array
    {
        return $this->errors;
    }
    
    public function getCourseCode(): string
    {
        return $this->data['course_code'];
    }
    
    public function getTitle(): string
    {
        return $this->data['title'];
    }
    
    public function getDescription(): string
    {
        return $this->data['description'];
    }
    
    public function getDurationHours(): int
    {
        return (int) $this->data['duration_hours'];
    }
    
    public function getInstructorId(): string
    {
        return $this->data['instructor_id'];
    }
    
    public function getMetadata(): array
    {
        return $this->data['metadata'] ?? [];
    }
    
    public function toArray(): array
    {
        return [
            'course_code' => $this->getCourseCode(),
            'title' => $this->getTitle(),
            'description' => $this->getDescription(),
            'duration_hours' => $this->getDurationHours(),
            'instructor_id' => $this->getInstructorId(),
            'metadata' => $this->getMetadata()
        ];
    }
} 