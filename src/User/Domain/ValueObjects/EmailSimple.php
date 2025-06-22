<?php

declare(strict_types=1);

namespace App\User\Domain\ValueObjects;

/**
 * Simple Email value object for testing
 */
final class EmailSimple implements \Stringable
{
    private string $value;
    
    public function __construct(string $email)
    {
        $email = trim($email);
        
        if (empty($email)) {
            throw new \InvalidArgumentException('Email cannot be empty');
        }
        
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            throw new \InvalidArgumentException(sprintf('Invalid email address: %s', $email));
        }
        
        $this->value = strtolower($email);
    }
    
    public function getValue(): string
    {
        return $this->value;
    }
    
    public function __toString(): string
    {
        return $this->value;
    }
} 