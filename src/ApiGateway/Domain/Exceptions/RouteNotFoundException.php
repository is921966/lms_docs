<?php

declare(strict_types=1);

namespace ApiGateway\Domain\Exceptions;

use DomainException;

class RouteNotFoundException extends DomainException
{
    public static function forPath(string $path): self
    {
        return new self(sprintf('No route found for path: %s', $path));
    }
} 