<?php

declare(strict_types=1);

namespace ApiGateway\Domain\Exceptions;

use DomainException;

class ServiceNotFoundException extends DomainException
{
    public static function forService(string $serviceName): self
    {
        return new self(sprintf('Service not found: %s', $serviceName));
    }
} 