<?php

declare(strict_types=1);

namespace Tests\Unit\ApiGateway\Infrastructure\Router;

use PHPUnit\Framework\TestCase;
use ApiGateway\Infrastructure\Router\ServiceRouter;
use ApiGateway\Domain\ValueObjects\HttpMethod;
use ApiGateway\Domain\Exceptions\ServiceNotFoundException;
use ApiGateway\Domain\Exceptions\RouteNotFoundException;

class ServiceRouterTest extends TestCase
{
    private ServiceRouter $router;
    
    protected function setUp(): void
    {
        $serviceConfig = [
            'user' => 'http://user-service:8080',
            'auth' => 'http://auth-service:8081',
            'competency' => 'http://competency-service:8082',
            'learning' => 'http://learning-service:8083',
            'program' => 'http://program-service:8084',
            'notification' => 'http://notification-service:8085'
        ];
        
        $this->router = new ServiceRouter($serviceConfig);
    }
    
    public function testRouteUsersList(): void
    {
        $endpoint = $this->router->route('/api/v1/users', HttpMethod::get());
        
        $this->assertEquals('http://user-service:8080/users', $endpoint->getUrl());
        $this->assertEquals('GET', $endpoint->getMethod()->getValue());
    }
    
    public function testRouteUserById(): void
    {
        $endpoint = $this->router->route('/api/v1/users/123', HttpMethod::get());
        
        $this->assertEquals('http://user-service:8080/users/123', $endpoint->getUrl());
        $this->assertEquals('GET', $endpoint->getMethod()->getValue());
    }
    
    public function testRouteAuthLogin(): void
    {
        $endpoint = $this->router->route('/api/v1/auth/login', HttpMethod::post());
        
        $this->assertEquals('http://auth-service:8081/login', $endpoint->getUrl());
        $this->assertEquals('POST', $endpoint->getMethod()->getValue());
    }
    
    public function testRouteCoursesList(): void
    {
        $endpoint = $this->router->route('/api/v1/courses', HttpMethod::get());
        
        $this->assertEquals('http://learning-service:8083/courses', $endpoint->getUrl());
        $this->assertEquals('GET', $endpoint->getMethod()->getValue());
    }
    
    public function testRouteWithTrailingSlash(): void
    {
        $endpoint = $this->router->route('/api/v1/users/', HttpMethod::get());
        
        $this->assertEquals('http://user-service:8080/users', $endpoint->getUrl());
    }
    
    public function testRouteWithQueryParameters(): void
    {
        $endpoint = $this->router->route('/api/v1/users?page=2&limit=10', HttpMethod::get());
        
        $this->assertEquals('http://user-service:8080/users', $endpoint->getUrl());
    }
    
    public function testRouteNotFound(): void
    {
        $this->expectException(RouteNotFoundException::class);
        
        $this->router->route('/api/v1/unknown', HttpMethod::get());
    }
    
    public function testRouteWithWrongMethod(): void
    {
        $this->expectException(RouteNotFoundException::class);
        
        // Try to GET a POST-only route
        $this->router->route('/api/v1/auth/login', HttpMethod::get());
    }
    
    public function testRegisterNewService(): void
    {
        $this->router->registerService('custom', 'http://custom-service:9000');
        $this->router->registerRoute('/api/v1/custom', HttpMethod::get(), 'custom', '/items');
        
        $endpoint = $this->router->route('/api/v1/custom', HttpMethod::get());
        
        $this->assertEquals('http://custom-service:9000/items', $endpoint->getUrl());
    }
    
    public function testRegisterRouteWithParameters(): void
    {
        $this->router->registerService('custom', 'http://custom-service:9000');
        $this->router->registerRoute('/api/v1/custom/{id}/details', HttpMethod::get(), 'custom', '/items/{id}/info');
        
        $endpoint = $this->router->route('/api/v1/custom/456/details', HttpMethod::get());
        
        $this->assertEquals('http://custom-service:9000/items/456/info', $endpoint->getUrl());
    }
    
    public function testServiceNotFound(): void
    {
        $this->expectException(ServiceNotFoundException::class);
        
        $this->router->registerRoute('/api/v1/missing', HttpMethod::get(), 'missing-service', '/test');
        $this->router->route('/api/v1/missing', HttpMethod::get());
    }
    
    public function testComplexParameterMatching(): void
    {
        $endpoint = $this->router->route('/api/v1/notifications/user-123-uuid', HttpMethod::get());
        
        $this->assertEquals('http://notification-service:8085/notifications/user-123-uuid', $endpoint->getUrl());
    }
} 