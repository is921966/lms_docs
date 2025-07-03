<?php

declare(strict_types=1);

namespace ApiGateway\Domain\ValueObjects;

use InvalidArgumentException;

class ServiceEndpoint
{
    private string $url;
    private HttpMethod $method;
    
    public function __construct(string $url, HttpMethod $method)
    {
        if (empty($url)) {
            throw new InvalidArgumentException('Service endpoint URL cannot be empty');
        }
        
        if (!filter_var($url, FILTER_VALIDATE_URL)) {
            throw new InvalidArgumentException(sprintf('Invalid URL: %s', $url));
        }
        
        $this->url = $url;
        $this->method = $method;
    }
    
    public function getUrl(): string
    {
        return $this->url;
    }
    
    public function getMethod(): HttpMethod
    {
        return $this->method;
    }
    
    public function withQueryParameters(array $parameters): self
    {
        if (empty($parameters)) {
            return $this;
        }
        
        $query = http_build_query($parameters);
        $separator = parse_url($this->url, PHP_URL_QUERY) ? '&' : '?';
        
        return new self($this->url . $separator . $query, $this->method);
    }
    
    public function equals(ServiceEndpoint $other): bool
    {
        return $this->url === $other->url && $this->method->equals($other->method);
    }
    
    public function __toString(): string
    {
        return sprintf('%s %s', $this->method->getValue(), $this->url);
    }
} 