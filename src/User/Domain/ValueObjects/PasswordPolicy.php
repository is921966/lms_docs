<?php

declare(strict_types=1);

namespace App\User\Domain\ValueObjects;

/**
 * Password policy and validation
 */
class PasswordPolicy
{
    /**
     * Default policy configuration
     */
    public const MIN_LENGTH = 8;
    public const REQUIRE_UPPERCASE = true;
    public const REQUIRE_LOWERCASE = true;
    public const REQUIRE_NUMBERS = true;
    public const REQUIRE_SYMBOLS = true;
    
    /**
     * Common passwords list
     */
    private const COMMON_PASSWORDS = [
        'password', '12345678', '123456789', 'qwerty',
        'admin', 'letmein', 'welcome', 'monkey', '1234567890',
        'password1', 'qwerty123', 'abc123', 'Password1', 'password!',
        '123456', '12345', 'iloveyou', 'admin123', 'welcome123',
    ];
    
    /**
     * Validate password against policy
     */
    public static function validate(string $password, array $policy = []): void
    {
        $minLength = $policy['min_length'] ?? self::MIN_LENGTH;
        $requireUppercase = $policy['require_uppercase'] ?? self::REQUIRE_UPPERCASE;
        $requireLowercase = $policy['require_lowercase'] ?? self::REQUIRE_LOWERCASE;
        $requireNumbers = $policy['require_numbers'] ?? self::REQUIRE_NUMBERS;
        $requireSymbols = $policy['require_symbols'] ?? self::REQUIRE_SYMBOLS;
        
        $errors = [];
        
        // Check length
        if (strlen($password) < $minLength) {
            $errors[] = sprintf('Password must be at least %d characters long', $minLength);
        }
        
        // Check uppercase
        if ($requireUppercase && !preg_match('/[A-Z]/', $password)) {
            $errors[] = 'Password must contain at least one uppercase letter';
        }
        
        // Check lowercase
        if ($requireLowercase && !preg_match('/[a-z]/', $password)) {
            $errors[] = 'Password must contain at least one lowercase letter';
        }
        
        // Check numbers
        if ($requireNumbers && !preg_match('/[0-9]/', $password)) {
            $errors[] = 'Password must contain at least one number';
        }
        
        // Check symbols
        if ($requireSymbols && !preg_match('/[^A-Za-z0-9]/', $password)) {
            $errors[] = 'Password must contain at least one special character';
        }
        
        // Check sequential characters (only 4+ consecutive)
        if (preg_match('/(?:0123|1234|2345|3456|4567|5678|6789|7890|abcd|bcde|cdef|defg|efgh|fghi|ghij|hijk|ijkl|jklm|klmn|lmno|mnop|nopq|opqr|pqrs|qrst|rstu|stuv|tuvw|uvwx|vwxy|wxyz)/i', $password)) {
            $errors[] = 'Password contains sequential characters';
        }
        
        // Check for repeated characters
        if (preg_match('/(.)\1{3,}/', $password)) {
            $errors[] = 'Password contains too many repeated characters';
        }
        
        // Check common passwords
        if (self::isCommonPassword($password)) {
            $errors[] = 'Password is too common, please choose a more secure password';
        }
        
        if (!empty($errors)) {
            throw new \InvalidArgumentException(
                'Password does not meet security requirements: ' . implode('; ', $errors)
            );
        }
    }
    
    /**
     * Check if password is in common passwords list
     */
    public static function isCommonPassword(string $password): bool
    {
        return in_array(strtolower($password), self::COMMON_PASSWORDS, true);
    }
    
    /**
     * Generate random password
     */
    public static function generateRandom(int $length = 16): string
    {
        $uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        $lowercase = 'abcdefghijklmnopqrstuvwxyz';
        $numbers = '0123456789';
        $symbols = '!@#$%^&*()-_=+[]{}|;:,.<>?';
        
        $allCharacters = $uppercase . $lowercase . $numbers . $symbols;
        
        // Ensure at least one character from each category
        $password = [
            $uppercase[random_int(0, strlen($uppercase) - 1)],
            $lowercase[random_int(0, strlen($lowercase) - 1)],
            $numbers[random_int(0, strlen($numbers) - 1)],
            $symbols[random_int(0, strlen($symbols) - 1)],
        ];
        
        // Fill the rest randomly
        for ($i = count($password); $i < $length; $i++) {
            $password[] = $allCharacters[random_int(0, strlen($allCharacters) - 1)];
        }
        
        // Shuffle the password
        shuffle($password);
        
        return implode('', $password);
    }
    
    /**
     * Calculate password strength
     */
    public static function calculateStrength(string $password): int
    {
        $strength = 0;
        
        // Length
        $length = strlen($password);
        if ($length >= 8) $strength += 10;
        if ($length >= 12) $strength += 10;
        if ($length >= 16) $strength += 10;
        
        // Character variety
        if (preg_match('/[a-z]/', $password)) $strength += 10;
        if (preg_match('/[A-Z]/', $password)) $strength += 10;
        if (preg_match('/[0-9]/', $password)) $strength += 10;
        if (preg_match('/[^A-Za-z0-9]/', $password)) $strength += 20;
        
        // Patterns
        if (!preg_match('/(.)\1{2,}/', $password)) $strength += 10; // No repeated chars
        if (!preg_match('/(?:012|123|234|345|456|567|678|789|890|abc|bcd|cde|def)/', strtolower($password))) {
            $strength += 10; // No sequential chars
        }
        
        return min($strength, 100);
    }
} 