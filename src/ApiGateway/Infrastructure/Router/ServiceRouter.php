<?php

declare(strict_types=1);

namespace ApiGateway\Infrastructure\Router;

use ApiGateway\Domain\Services\ServiceRouterInterface;
use ApiGateway\Domain\ValueObjects\ServiceEndpoint;
use ApiGateway\Domain\ValueObjects\HttpMethod;
use ApiGateway\Domain\Exceptions\ServiceNotFoundException;
use ApiGateway\Domain\Exceptions\RouteNotFoundException;

class ServiceRouter implements ServiceRouterInterface
{
    private array $routes = [];
    private array $services = [];
    
    public function __construct(array $serviceConfig = [])
    {
        $this->initializeDefaultRoutes();
        $this->loadServiceConfig($serviceConfig);
    }
    
    public function route(string $path, HttpMethod $method): ServiceEndpoint
    {
        $normalizedPath = $this->normalizePath($path);
        $methodValue = $method->getValue();
        
        // Try exact match first
        if (isset($this->routes[$methodValue][$normalizedPath])) {
            $route = $this->routes[$methodValue][$normalizedPath];
            return $this->createEndpoint($route['service'], $route['path'], $method);
        }
        
        // Try pattern matching
        foreach ($this->routes[$methodValue] ?? [] as $pattern => $route) {
            if ($this->matchesPattern($normalizedPath, $pattern)) {
                $targetPath = $this->transformPath($normalizedPath, $pattern, $route['path']);
                return $this->createEndpoint($route['service'], $targetPath, $method);
            }
        }
        
        throw RouteNotFoundException::forPath($path);
    }
    
    public function registerService(string $name, string $baseUrl): void
    {
        $this->services[$name] = $baseUrl;
    }
    
    public function registerRoute(string $pattern, HttpMethod $method, string $service, string $targetPath): void
    {
        $this->routes[$method->getValue()][$pattern] = [
            'service' => $service,
            'path' => $targetPath
        ];
    }
    
    private function initializeDefaultRoutes(): void
    {
        // User service routes
        $this->routes['GET']['/api/v1/users'] = ['service' => 'user', 'path' => '/users'];
        $this->routes['GET']['/api/v1/users/{id}'] = ['service' => 'user', 'path' => '/users/{id}'];
        $this->routes['POST']['/api/v1/users'] = ['service' => 'user', 'path' => '/users'];
        $this->routes['PUT']['/api/v1/users/{id}'] = ['service' => 'user', 'path' => '/users/{id}'];
        $this->routes['DELETE']['/api/v1/users/{id}'] = ['service' => 'user', 'path' => '/users/{id}'];
        
        // Auth service routes
        $this->routes['POST']['/api/v1/auth/login'] = ['service' => 'auth', 'path' => '/login'];
        $this->routes['POST']['/api/v1/auth/logout'] = ['service' => 'auth', 'path' => '/logout'];
        $this->routes['POST']['/api/v1/auth/refresh'] = ['service' => 'auth', 'path' => '/refresh'];
        
        // Competency service routes
        $this->routes['GET']['/api/v1/competencies'] = ['service' => 'competency', 'path' => '/competencies'];
        $this->routes['GET']['/api/v1/competencies/{id}'] = ['service' => 'competency', 'path' => '/competencies/{id}'];
        $this->routes['POST']['/api/v1/competencies'] = ['service' => 'competency', 'path' => '/competencies'];
        
        // Learning service routes
        $this->routes['GET']['/api/v1/courses'] = ['service' => 'learning', 'path' => '/courses'];
        $this->routes['GET']['/api/v1/courses/{id}'] = ['service' => 'learning', 'path' => '/courses/{id}'];
        $this->routes['POST']['/api/v1/courses'] = ['service' => 'learning', 'path' => '/courses'];
        $this->routes['POST']['/api/v1/enrollments'] = ['service' => 'learning', 'path' => '/enrollments'];
        
        // Program service routes
        $this->routes['GET']['/api/v1/programs'] = ['service' => 'program', 'path' => '/programs'];
        $this->routes['GET']['/api/v1/programs/{id}'] = ['service' => 'program', 'path' => '/programs/{id}'];
        $this->routes['POST']['/api/v1/programs'] = ['service' => 'program', 'path' => '/programs'];
        
        // Notification service routes
        $this->routes['POST']['/api/v1/notifications'] = ['service' => 'notification', 'path' => '/notifications'];
        $this->routes['GET']['/api/v1/notifications/{userId}'] = ['service' => 'notification', 'path' => '/notifications/{userId}'];
    }
    
    private function loadServiceConfig(array $config): void
    {
        foreach ($config as $name => $baseUrl) {
            $this->registerService($name, $baseUrl);
        }
    }
    
    private function createEndpoint(string $serviceName, string $path, HttpMethod $method): ServiceEndpoint
    {
        if (!isset($this->services[$serviceName])) {
            throw ServiceNotFoundException::forService($serviceName);
        }
        
        $baseUrl = rtrim($this->services[$serviceName], '/');
        $fullUrl = $baseUrl . '/' . ltrim($path, '/');
        
        return new ServiceEndpoint($fullUrl, $method);
    }
    
    private function normalizePath(string $path): string
    {
        // Remove query parameters
        $path = strtok($path, '?');
        
        // Remove trailing slash
        return rtrim($path, '/') ?: '/';
    }
    
    private function matchesPattern(string $path, string $pattern): bool
    {
        // Convert route pattern to regex
        $regex = preg_replace('/\{[^}]+\}/', '([^/]+)', $pattern);
        $regex = '#^' . $regex . '$#';
        
        return preg_match($regex, $path) === 1;
    }
    
    private function transformPath(string $path, string $pattern, string $targetPattern): string
    {
        // Extract parameter values from path
        $regex = preg_replace('/\{([^}]+)\}/', '(?P<$1>[^/]+)', $pattern);
        $regex = '#^' . $regex . '$#';
        
        if (preg_match($regex, $path, $matches)) {
            $result = $targetPattern;
            
            // Replace parameters in target pattern
            foreach ($matches as $key => $value) {
                if (is_string($key)) {
                    $result = str_replace('{' . $key . '}', $value, $result);
                }
            }
            
            return $result;
        }
        
        return $targetPattern;
    }
} 