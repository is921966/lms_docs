<?php

declare(strict_types=1);

namespace Program\Application\Requests;

final class UpdateProgramRequest
{
    public function __construct(
        public readonly string $programId,
        public readonly string $title,
        public readonly string $description,
        public readonly ?array $metadata = null
    ) {}
    
    public function validate(): array
    {
        $errors = [];
        
        if (empty($this->programId)) {
            $errors[] = 'Program ID is required';
        }
        
        if (empty($this->title)) {
            $errors[] = 'Title is required';
        }
        
        if (strlen($this->title) < 3) {
            $errors[] = 'Title must be at least 3 characters long';
        }
        
        if (strlen($this->title) > 255) {
            $errors[] = 'Title must not exceed 255 characters';
        }
        
        if (empty($this->description)) {
            $errors[] = 'Description is required';
        }
        
        if (strlen($this->description) < 10) {
            $errors[] = 'Description must be at least 10 characters long';
        }
        
        // Basic UUID validation
        $uuidPattern = '/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i';
        
        if (!empty($this->programId) && !preg_match($uuidPattern, $this->programId)) {
            $errors[] = 'Invalid program ID format';
        }
        
        return $errors;
    }
    
    public function isValid(): bool
    {
        return count($this->validate()) === 0;
    }
} 