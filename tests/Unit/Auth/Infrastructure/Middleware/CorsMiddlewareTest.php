<?php

namespace Tests\Unit\Auth\Infrastructure\Middleware;

use PHPUnit\Framework\TestCase;
use Auth\Infrastructure\Middleware\CorsMiddleware;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\HttpKernelInterface;

class CorsMiddlewareTest extends TestCase
{
    private CorsMiddleware $middleware;
    private $kernel;

    protected function setUp(): void
    {
        $this->kernel = $this->createMock(HttpKernelInterface::class);
        $this->middleware = new CorsMiddleware($this->kernel);
    }

    public function testHandlesPreflightRequest()
    {
        // Arrange
        $request = Request::create('/api/users', 'OPTIONS');
        $request->headers->set('Origin', 'https://example.com');
        $request->headers->set('Access-Control-Request-Method', 'POST');
        $request->headers->set('Access-Control-Request-Headers', 'Content-Type, Authorization');

        // Act
        $response = $this->middleware->handle($request);

        // Assert
        $this->assertEquals(204, $response->getStatusCode());
        $this->assertEquals('*', $response->headers->get('Access-Control-Allow-Origin'));
        $this->assertEquals('POST, GET, PUT, DELETE, OPTIONS', $response->headers->get('Access-Control-Allow-Methods'));
        $this->assertEquals('Content-Type, Authorization', $response->headers->get('Access-Control-Allow-Headers'));
        $this->assertFalse($response->headers->has('Access-Control-Allow-Credentials'));
        $this->assertEquals('86400', $response->headers->get('Access-Control-Max-Age'));
    }

    public function testAddsCorsToCrossOriginRequest()
    {
        // Arrange
        $request = Request::create('/api/users', 'GET');
        $request->headers->set('Origin', 'https://example.com');
        
        $response = new Response('Users data');
        $this->kernel->expects($this->once())
            ->method('handle')
            ->willReturn($response);

        // Act
        $result = $this->middleware->handle($request);

        // Assert
        $this->assertEquals('*', $result->headers->get('Access-Control-Allow-Origin'));
        $this->assertFalse($result->headers->has('Access-Control-Allow-Credentials'));
        $this->assertEquals('X-Total-Count', $result->headers->get('Access-Control-Expose-Headers'));
    }

    public function testDoesNotAddCorsToSameOriginRequest()
    {
        // Arrange
        $request = Request::create('/api/users', 'GET');
        // No Origin header = same origin request
        
        $response = new Response('Users data');
        $this->kernel->expects($this->once())
            ->method('handle')
            ->willReturn($response);

        // Act
        $result = $this->middleware->handle($request);

        // Assert
        $this->assertFalse($result->headers->has('Access-Control-Allow-Origin'));
    }

    public function testAllowsSpecificOrigins()
    {
        // Arrange
        $config = [
            'allowed_origins' => ['https://app.example.com', 'https://admin.example.com'],
            'allow_credentials' => true
        ];
        
        $middleware = new CorsMiddleware($this->kernel, $config);
        
        $request = Request::create('/api/users', 'GET');
        $request->headers->set('Origin', 'https://app.example.com');
        
        $response = new Response();
        $this->kernel->expects($this->once())
            ->method('handle')
            ->willReturn($response);

        // Act
        $result = $middleware->handle($request);

        // Assert
        $this->assertEquals('https://app.example.com', $result->headers->get('Access-Control-Allow-Origin'));
    }

    public function testRejectsUnallowedOrigin()
    {
        // Arrange
        $config = [
            'allowed_origins' => ['https://app.example.com'],
            'allow_credentials' => true
        ];
        
        $middleware = new CorsMiddleware($this->kernel, $config);
        
        $request = Request::create('/api/users', 'GET');
        $request->headers->set('Origin', 'https://evil.com');
        
        $response = new Response();
        $this->kernel->expects($this->once())
            ->method('handle')
            ->willReturn($response);

        // Act
        $result = $middleware->handle($request);

        // Assert
        $this->assertFalse($result->headers->has('Access-Control-Allow-Origin'));
    }

    public function testWildcardOrigin()
    {
        // Arrange
        $config = [
            'allowed_origins' => ['*'],
            'allow_credentials' => false
        ];
        
        $middleware = new CorsMiddleware($this->kernel, $config);
        
        $request = Request::create('/api/users', 'GET');
        $request->headers->set('Origin', 'https://any-site.com');
        
        $response = new Response();
        $this->kernel->expects($this->once())
            ->method('handle')
            ->willReturn($response);

        // Act
        $result = $middleware->handle($request);

        // Assert
        $this->assertEquals('*', $result->headers->get('Access-Control-Allow-Origin'));
        $this->assertFalse($result->headers->has('Access-Control-Allow-Credentials'));
    }
} 