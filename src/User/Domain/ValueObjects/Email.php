<?php

declare(strict_types=1);

namespace User\Domain\ValueObjects;

/**
 * Email value object
 */
final class Email implements \Stringable, \JsonSerializable
{
    private string $value;
    
    /**
     * Constructor
     */
    public function __construct(string $email)
    {
        // Normalize before validation
        $normalizedEmail = strtolower(trim($email));
        $this->validate($normalizedEmail);
        $this->value = $normalizedEmail;
    }
    
    /**
     * Create from string
     */
    public static function fromString(string $email): self
    {
        return new self($email);
    }
    
    /**
     * Get email value
     */
    public function getValue(): string
    {
        return $this->value;
    }
    
    /**
     * Get domain part
     */
    public function getDomain(): string
    {
        return substr($this->value, strpos($this->value, '@') + 1);
    }
    
    /**
     * Get local part
     */
    public function getLocalPart(): string
    {
        return substr($this->value, 0, strpos($this->value, '@'));
    }
    
    /**
     * Check if email belongs to domain
     */
    public function belongsToDomain(string $domain): bool
    {
        return $this->getDomain() === strtolower($domain);
    }
    
    /**
     * Check if email is corporate
     */
    public function isCorporate(array $corporateDomains): bool
    {
        $domain = $this->getDomain();
        
        foreach ($corporateDomains as $corporateDomain) {
            if ($domain === strtolower($corporateDomain)) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * Compare with another email
     */
    public function equals(Email $other): bool
    {
        return $this->value === $other->value;
    }
    
    /**
     * Validate email
     */
    private function validate(string $email): void
    {
        if (empty($email)) {
            throw new \InvalidArgumentException('Email cannot be empty');
        }
        
        // Check total length first
        if (strlen($email) > 255) {
            throw new \InvalidArgumentException('Email must not exceed 255 characters');
        }
        
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            throw new \InvalidArgumentException(sprintf('Invalid email address: %s', $email));
        }
        
        // Additional validation for common typos
        $parts = explode('@', $email);
        if (count($parts) !== 2) {
            throw new \InvalidArgumentException(sprintf('Invalid email format: %s', $email));
        }
        
        [$localPart, $domain] = $parts;
        
        // Check local part
        if (strlen($localPart) > 64) {
            throw new \InvalidArgumentException('Email local part is too long (max 64 characters)');
        }
        
        // Check domain
        if (strlen($domain) > 255) {
            throw new \InvalidArgumentException('Email domain is too long (max 255 characters)');
        }
        
        // Check for valid domain
        if (!checkdnsrr($domain, 'MX') && !checkdnsrr($domain, 'A')) {
            // Allow for local/test environments
            if (!in_array($domain, ['localhost', 'example.com', 'test.com'], true)) {
                throw new \InvalidArgumentException(sprintf('Email domain does not exist: %s', $domain));
            }
        }
    }
    
    /**
     * Check if email has valid DNS record
     */
    public function hasDnsRecord(): bool
    {
        $domain = $this->getDomain();
        
        // Allow test domains
        if (in_array($domain, ['localhost', 'example.com', 'test.com'], true)) {
            return true;
        }
        
        return checkdnsrr($domain, 'MX') || checkdnsrr($domain, 'A');
    }
    
    /**
     * Check if email is from disposable email service
     */
    public function isDisposable(): bool
    {
        // Common disposable email domains
        $disposableDomains = [
            'tempmail.com',
            'throwaway.email',
            'guerrillamail.com',
            'mailinator.com',
            '10minutemail.com',
            'trashmail.com',
        ];
        
        return in_array($this->getDomain(), $disposableDomains, true);
    }
    
    /**
     * String representation
     */
    public function __toString(): string
    {
        return $this->value;
    }
    
    /**
     * JSON serialization
     */
    public function jsonSerialize(): mixed
    {
        return $this->value;
    }
} 