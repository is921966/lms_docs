<?php

namespace Auth\Domain\Exceptions;

class AuthenticationException extends \Exception
{
    public static function invalidCredentials(): self
    {
        return new self('Invalid credentials');
    }

    public static function accountInactive(): self
    {
        return new self('Account is inactive');
    }

    public static function accountLocked(): self
    {
        return new self('Account is locked');
    }

    public static function tooManyAttempts(): self
    {
        return new self('Too many login attempts. Please try again later.');
    }
} 