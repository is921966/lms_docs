<?php

declare(strict_types=1);

namespace ApiGateway\Domain\ValueObjects;

use InvalidArgumentException;

class HttpMethod
{
    private const ALLOWED_METHODS = [
        'GET',
        'POST',
        'PUT',
        'PATCH',
        'DELETE',
        'HEAD',
        'OPTIONS'
    ];
    
    private string $value;
    
    private function __construct(string $value)
    {
        $upperValue = strtoupper($value);
        
        if (!in_array($upperValue, self::ALLOWED_METHODS, true)) {
            throw new InvalidArgumentException(
                sprintf('Invalid HTTP method: %s. Allowed methods: %s', 
                    $value, 
                    implode(', ', self::ALLOWED_METHODS)
                )
            );
        }
        
        $this->value = $upperValue;
    }
    
    public static function fromString(string $value): self
    {
        return new self($value);
    }
    
    public static function get(): self
    {
        return new self('GET');
    }
    
    public static function post(): self
    {
        return new self('POST');
    }
    
    public static function put(): self
    {
        return new self('PUT');
    }
    
    public static function patch(): self
    {
        return new self('PATCH');
    }
    
    public static function delete(): self
    {
        return new self('DELETE');
    }
    
    public static function head(): self
    {
        return new self('HEAD');
    }
    
    public static function options(): self
    {
        return new self('OPTIONS');
    }
    
    public function getValue(): string
    {
        return $this->value;
    }
    
    public function equals(HttpMethod $other): bool
    {
        return $this->value === $other->value;
    }
    
    public function __toString(): string
    {
        return $this->value;
    }
} 