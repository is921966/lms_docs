<?php

namespace Auth\Domain\Exceptions;

class InvalidTokenException extends \Exception
{
    public static function expired(): self
    {
        return new self('Token has expired');
    }

    public static function invalidSignature(): self
    {
        return new self('Invalid token signature');
    }

    public static function malformed(): self
    {
        return new self('Malformed token');
    }

    public static function blacklisted(): self
    {
        return new self('Token has been blacklisted');
    }

    public static function invalidType(string $expected, string $actual): self
    {
        return new self(sprintf('Invalid token type. Expected %s, got %s', $expected, $actual));
    }
} 