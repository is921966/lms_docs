<?php

declare(strict_types=1);

namespace App\Domain\Exception;

use DomainException;

class InvalidPasswordException extends DomainException
{
    public static function empty(): self
    {
        return new self('Password cannot be empty');
    }

    public static function tooShort(int $minLength): self
    {
        return new self("Password must be at least {$minLength} characters long");
    }

    public static function tooLong(int $maxLength): self
    {
        return new self("Password must not exceed {$maxLength} characters");
    }

    public static function tooWeak(): self
    {
        return new self('Password is too weak. It must contain at least one uppercase letter, one lowercase letter, one number, and one special character');
    }

    public static function commonPassword(): self
    {
        return new self('Password is too weak. This password is too common');
    }
} 