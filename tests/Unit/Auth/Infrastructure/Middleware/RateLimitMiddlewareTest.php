<?php

namespace Tests\Unit\Auth\Infrastructure\Middleware;

use PHPUnit\Framework\TestCase;
use Auth\Infrastructure\Middleware\RateLimitMiddleware;
use Auth\Domain\Services\RateLimiter;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpKernel\HttpKernelInterface;

class RateLimitMiddlewareTest extends TestCase
{
    private RateLimitMiddleware $middleware;
    private $kernel;
    private $rateLimiter;

    protected function setUp(): void
    {
        $this->kernel = $this->createMock(HttpKernelInterface::class);
        $this->rateLimiter = $this->createMock(RateLimiter::class);
        
        $config = [
            'limit' => 60,
            'window' => 60
        ];
        
        $this->middleware = new RateLimitMiddleware($this->kernel, $this->rateLimiter, $config);
    }

    public function testAllowsRequestWithinLimit()
    {
        // Arrange
        $request = Request::create('/api/users');
        $request->server->set('REMOTE_ADDR', '127.0.0.1');
        
        $response = new Response('Success');
        
        $this->rateLimiter->expects($this->once())
            ->method('allowRequest')
            ->willReturn(true);
            
        $this->rateLimiter->expects($this->once())
            ->method('getRemainingAttempts')
            ->willReturn(59);
            
        $this->rateLimiter->expects($this->once())
            ->method('getResetTime')
            ->willReturn(time() + 60);
            
        $this->kernel->expects($this->once())
            ->method('handle')
            ->willReturn($response);

        // Act
        $result = $this->middleware->handle($request);

        // Assert
        $this->assertEquals(200, $result->getStatusCode());
        $this->assertEquals('60', $result->headers->get('X-RateLimit-Limit'));
        $this->assertEquals('59', $result->headers->get('X-RateLimit-Remaining'));
        $this->assertNotNull($result->headers->get('X-RateLimit-Reset'));
    }

    public function testBlocksRequestOverLimit()
    {
        // Arrange
        $request = Request::create('/api/users');
        $request->server->set('REMOTE_ADDR', '127.0.0.1');
        
        $this->rateLimiter->expects($this->once())
            ->method('allowRequest')
            ->willReturn(false);
            
        $this->rateLimiter->expects($this->once())
            ->method('getRemainingAttempts')
            ->willReturn(0);
            
        $this->rateLimiter->expects($this->once())
            ->method('getResetTime')
            ->willReturn(time() + 30);

        // Act
        $result = $this->middleware->handle($request);

        // Assert
        $this->assertInstanceOf(JsonResponse::class, $result);
        $this->assertEquals(429, $result->getStatusCode());
        $this->assertEquals('30', $result->headers->get('Retry-After'));
        
        $content = json_decode($result->getContent(), true);
        $this->assertEquals('Too Many Requests', $content['error']);
    }

    public function testUsesAuthenticatedUserIdWhenAvailable()
    {
        // Arrange
        $request = Request::create('/api/users');
        $request->server->set('REMOTE_ADDR', '127.0.0.1');
        $request->attributes->set('userId', 'user-123');
        
        $response = new Response();
        
        $this->rateLimiter->expects($this->once())
            ->method('allowRequest')
            ->with($this->callback(function ($key) {
                return $key->getIdentifier() === 'user-123';
            }))
            ->willReturn(true);
            
        $this->rateLimiter->expects($this->once())
            ->method('getRemainingAttempts')
            ->willReturn(100);
            
        $this->rateLimiter->expects($this->once())
            ->method('getResetTime')
            ->willReturn(time() + 60);
            
        $this->kernel->expects($this->once())
            ->method('handle')
            ->willReturn($response);

        // Act
        $this->middleware->handle($request);
    }

    public function testCustomLimitsPerRoute()
    {
        // Arrange
        $config = [
            'default' => ['limit' => 60, 'window' => 60],
            'routes' => [
                '/api/auth/login' => ['limit' => 5, 'window' => 300]
            ]
        ];
        
        $middleware = new RateLimitMiddleware($this->kernel, $this->rateLimiter, $config);
        
        $request = Request::create('/api/auth/login', 'POST');
        $request->server->set('REMOTE_ADDR', '127.0.0.1');
        
        $this->rateLimiter->expects($this->once())
            ->method('allowRequest')
            ->with(
                $this->anything(),
                5,  // Custom limit for login
                300 // Custom window for login
            )
            ->willReturn(true);
            
        $this->rateLimiter->expects($this->once())
            ->method('getRemainingAttempts')
            ->willReturn(4);
            
        $this->rateLimiter->expects($this->once())
            ->method('getResetTime')
            ->willReturn(time() + 300);
            
        $this->kernel->expects($this->once())
            ->method('handle')
            ->willReturn(new Response());

        // Act
        $result = $middleware->handle($request);

        // Assert
        $this->assertEquals('5', $result->headers->get('X-RateLimit-Limit'));
    }

    public function testExcludesWhitelistedRoutes()
    {
        // Arrange
        $config = [
            'limit' => 60,
            'window' => 60,
            'exclude' => ['/api/health', '/api/docs']
        ];
        
        $middleware = new RateLimitMiddleware($this->kernel, $this->rateLimiter, $config);
        
        $request = Request::create('/api/health');
        $response = new Response('OK');
        
        $this->rateLimiter->expects($this->never())
            ->method('allowRequest');
            
        $this->kernel->expects($this->once())
            ->method('handle')
            ->willReturn($response);

        // Act
        $result = $middleware->handle($request);

        // Assert
        $this->assertEquals(200, $result->getStatusCode());
        $this->assertFalse($result->headers->has('X-RateLimit-Limit'));
    }
} 