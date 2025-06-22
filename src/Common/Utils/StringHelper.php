<?php

declare(strict_types=1);

namespace App\Common\Utils;

/**
 * String helper utility class
 */
class StringHelper
{
    /**
     * Generate random string
     */
    public static function random(int $length = 16): string
    {
        return bin2hex(random_bytes($length / 2));
    }
    
    /**
     * Convert string to slug
     */
    public static function slug(string $string, string $separator = '-'): string
    {
        // Replace non letter or digits by separator
        $slug = preg_replace('~[^\pL\d]+~u', $separator, $string);
        
        // Transliterate
        $slug = iconv('utf-8', 'us-ascii//TRANSLIT', $slug ?? '');
        
        // Remove unwanted characters
        $slug = preg_replace('~[^-\w]+~', '', $slug ?? '');
        
        // Trim
        $slug = trim($slug ?? '', $separator);
        
        // Remove duplicate separators
        $slug = preg_replace('~-+~', $separator, $slug ?? '');
        
        // Lowercase
        return strtolower($slug ?? '');
    }
    
    /**
     * Truncate string with ellipsis
     */
    public static function truncate(string $string, int $length = 100, string $suffix = '...'): string
    {
        if (mb_strlen($string) <= $length) {
            return $string;
        }
        
        return rtrim(mb_substr($string, 0, $length)) . $suffix;
    }
    
    /**
     * Convert string to camelCase
     */
    public static function camelCase(string $string): string
    {
        $string = ucwords(str_replace(['-', '_'], ' ', $string));
        $string = str_replace(' ', '', $string);
        
        return lcfirst($string);
    }
    
    /**
     * Convert string to snake_case
     */
    public static function snakeCase(string $string): string
    {
        $string = preg_replace('/\s+/u', '', ucwords($string));
        $string = preg_replace('/(.)(?=[A-Z])/u', '$1_', $string ?? '');
        
        return mb_strtolower($string ?? '');
    }
    
    /**
     * Check if string contains substring
     */
    public static function contains(string $haystack, string $needle, bool $caseSensitive = true): bool
    {
        if ($caseSensitive) {
            return str_contains($haystack, $needle);
        }
        
        return str_contains(mb_strtolower($haystack), mb_strtolower($needle));
    }
    
    /**
     * Mask sensitive data
     */
    public static function mask(string $string, int $visibleChars = 4, string $maskChar = '*'): string
    {
        $length = mb_strlen($string);
        
        if ($length <= $visibleChars) {
            return str_repeat($maskChar, $length);
        }
        
        $visible = mb_substr($string, 0, $visibleChars);
        $masked = str_repeat($maskChar, $length - $visibleChars);
        
        return $visible . $masked;
    }
} 