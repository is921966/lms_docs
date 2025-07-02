<?php

namespace Tests\Unit\Auth\Infrastructure\Middleware;

use PHPUnit\Framework\TestCase;
use Auth\Infrastructure\Middleware\SecurityHeadersMiddleware;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\HttpKernelInterface;

class SecurityHeadersMiddlewareTest extends TestCase
{
    private SecurityHeadersMiddleware $middleware;
    private $kernel;

    protected function setUp(): void
    {
        $this->kernel = $this->createMock(HttpKernelInterface::class);
        $this->middleware = new SecurityHeadersMiddleware($this->kernel);
    }

    public function testAddsSecurityHeaders()
    {
        // Arrange
        $request = new Request();
        $response = new Response('Test content');
        
        $this->kernel->expects($this->once())
            ->method('handle')
            ->with($request)
            ->willReturn($response);

        // Act
        $result = $this->middleware->handle($request);

        // Assert
        $this->assertEquals('nosniff', $result->headers->get('X-Content-Type-Options'));
        $this->assertEquals('DENY', $result->headers->get('X-Frame-Options'));
        $this->assertEquals('1; mode=block', $result->headers->get('X-XSS-Protection'));
        $this->assertEquals('no-referrer-when-downgrade', $result->headers->get('Referrer-Policy'));
        $this->assertNotNull($result->headers->get('Content-Security-Policy'));
    }

    public function testAddsStrictTransportSecurity()
    {
        // Arrange
        $request = new Request();
        $response = new Response();
        
        $this->kernel->expects($this->once())
            ->method('handle')
            ->willReturn($response);

        // Act
        $result = $this->middleware->handle($request);

        // Assert
        $this->assertEquals(
            'max-age=31536000; includeSubDomains',
            $result->headers->get('Strict-Transport-Security')
        );
    }

    public function testContentSecurityPolicy()
    {
        // Arrange
        $request = new Request();
        $response = new Response();
        
        $this->kernel->expects($this->once())
            ->method('handle')
            ->willReturn($response);

        // Act
        $result = $this->middleware->handle($request);

        // Assert
        $csp = $result->headers->get('Content-Security-Policy');
        $this->assertStringContainsString("default-src 'self'", $csp);
        $this->assertStringContainsString("script-src 'self' 'unsafe-inline'", $csp);
        $this->assertStringContainsString("style-src 'self' 'unsafe-inline'", $csp);
        $this->assertStringContainsString("img-src 'self' data: https:", $csp);
    }

    public function testRemoveServerHeader()
    {
        // Arrange
        $request = new Request();
        $response = new Response();
        $response->headers->set('Server', 'Apache/2.4.41');
        $response->headers->set('X-Powered-By', 'PHP/8.1');
        
        $this->kernel->expects($this->once())
            ->method('handle')
            ->willReturn($response);

        // Act
        $result = $this->middleware->handle($request);

        // Assert
        $this->assertFalse($result->headers->has('Server'));
        $this->assertFalse($result->headers->has('X-Powered-By'));
    }

    public function testPermissionsPolicy()
    {
        // Arrange
        $request = new Request();
        $response = new Response();
        
        $this->kernel->expects($this->once())
            ->method('handle')
            ->willReturn($response);

        // Act
        $result = $this->middleware->handle($request);

        // Assert
        $policy = $result->headers->get('Permissions-Policy');
        $this->assertStringContainsString('geolocation=()', $policy);
        $this->assertStringContainsString('microphone=()', $policy);
        $this->assertStringContainsString('camera=()', $policy);
    }

    public function testCustomConfiguration()
    {
        // Arrange
        $config = [
            'frame-options' => 'SAMEORIGIN',
            'csp' => [
                'default-src' => "'self'",
                'script-src' => "'self' https://trusted.cdn.com"
            ]
        ];
        
        $middleware = new SecurityHeadersMiddleware($this->kernel, $config);
        $request = new Request();
        $response = new Response();
        
        $this->kernel->expects($this->once())
            ->method('handle')
            ->willReturn($response);

        // Act
        $result = $middleware->handle($request);

        // Assert
        $this->assertEquals('SAMEORIGIN', $result->headers->get('X-Frame-Options'));
        $this->assertStringContainsString('https://trusted.cdn.com', $result->headers->get('Content-Security-Policy'));
    }
} 