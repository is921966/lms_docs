<?php

declare(strict_types=1);

namespace Program\Application\Requests;

final class CreateProgramRequest
{
    public function __construct(
        public readonly string $code,
        public readonly string $title,
        public readonly string $description,
        public readonly int $completionPercentage = 100,
        public readonly bool $requireAllCourses = true,
        public readonly array $metadata = []
    ) {}
    
    public function validate(): array
    {
        $errors = [];
        
        if (empty($this->code)) {
            $errors[] = 'Program code is required';
        }
        
        if (!preg_match('/^[A-Z]{4}-\d{3}$/', $this->code)) {
            $errors[] = 'Program code must match format XXXX-NNN';
        }
        
        if (empty($this->title)) {
            $errors[] = 'Program title is required';
        }
        
        if (empty($this->description)) {
            $errors[] = 'Program description is required';
        }
        
        if ($this->completionPercentage < 0 || $this->completionPercentage > 100) {
            $errors[] = 'Completion percentage must be between 0 and 100';
        }
        
        return $errors;
    }
    
    public function isValid(): bool
    {
        return count($this->validate()) === 0;
    }
} 