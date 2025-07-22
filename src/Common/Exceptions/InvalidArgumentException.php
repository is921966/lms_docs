<?php

declare(strict_types=1);

namespace App\Common\Exceptions;

class InvalidArgumentException extends \InvalidArgumentException
{
    public static function empty(string $field): self
    {
        return new self(sprintf('%s cannot be empty', $field));
    }
    
    public static function invalidFormat(string $field, string $expected): self
    {
        return new self(sprintf('Invalid %s format. Expected: %s', $field, $expected));
    }
} 