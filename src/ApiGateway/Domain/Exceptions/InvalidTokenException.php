<?php

declare(strict_types=1);

namespace ApiGateway\Domain\Exceptions;

class InvalidTokenException extends \Exception
{
    public static function expired(): self
    {
        return new self('Token has expired');
    }
    
    public static function malformed(): self
    {
        return new self('Token is malformed');
    }
    
    public static function invalidSignature(): self
    {
        return new self('Token signature is invalid');
    }
    
    public static function notYetValid(): self
    {
        return new self('Token is not yet valid');
    }
    
    public static function missingClaim(string $claim): self
    {
        return new self(sprintf('Token is missing required claim: %s', $claim));
    }
} 