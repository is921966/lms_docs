<?php

declare(strict_types=1);

namespace Program\Application\Requests;

final class EnrollUserRequest
{
    public function __construct(
        public readonly string $userId,
        public readonly string $programId
    ) {}
    
    public function validate(): array
    {
        $errors = [];
        
        if (empty($this->userId)) {
            $errors[] = 'User ID is required';
        }
        
        if (empty($this->programId)) {
            $errors[] = 'Program ID is required';
        }
        
        // Basic UUID validation
        $uuidPattern = '/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i';
        
        if (!empty($this->userId) && !preg_match($uuidPattern, $this->userId)) {
            $errors[] = 'Invalid user ID format';
        }
        
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