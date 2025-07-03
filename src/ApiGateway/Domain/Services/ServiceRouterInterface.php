<?php

declare(strict_types=1);

namespace ApiGateway\Domain\Services;

use ApiGateway\Domain\ValueObjects\ServiceEndpoint;
use ApiGateway\Domain\ValueObjects\HttpMethod;

interface ServiceRouterInterface
{
    /**
     * Route a request to the appropriate service
     *
     * @param string $path The requested path
     * @param HttpMethod $method The HTTP method
     * @return ServiceEndpoint The service endpoint to call
     * @throws \ApiGateway\Domain\Exceptions\RouteNotFoundException
     * @throws \ApiGateway\Domain\Exceptions\ServiceNotFoundException
     */
    public function route(string $path, HttpMethod $method): ServiceEndpoint;
    
    /**
     * Register a service with its base URL
     *
     * @param string $name The service name
     * @param string $baseUrl The service base URL
     */
    public function registerService(string $name, string $baseUrl): void;
    
    /**
     * Register a route pattern
     *
     * @param string $pattern The route pattern (e.g., /api/v1/users/{id})
     * @param HttpMethod $method The HTTP method
     * @param string $service The target service name
     * @param string $targetPath The target path on the service
     */
    public function registerRoute(string $pattern, HttpMethod $method, string $service, string $targetPath): void;
} 