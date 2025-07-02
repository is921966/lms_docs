<?php

namespace Tests\Unit\Auth\Infrastructure\Middleware;

use PHPUnit\Framework\TestCase;
use Auth\Infrastructure\Middleware\AuthenticationMiddleware;
use Auth\Domain\Services\JwtService;
use Auth\Domain\ValueObjects\TokenPayload;
use Auth\Domain\Exceptions\InvalidTokenException;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\HttpKernelInterface;

class AuthenticationMiddlewareTest extends TestCase
{
    private AuthenticationMiddleware $middleware;
    private $jwtService;
    private $kernel;

    protected function setUp(): void
    {
        $this->jwtService = $this->createMock(JwtService::class);
        $this->kernel = $this->createMock(HttpKernelInterface::class);
        $this->middleware = new AuthenticationMiddleware($this->jwtService);
        $this->middleware->setKernel($this->kernel);
    }

    public function testValidTokenPassesThrough()
    {
        // Arrange
        $request = new Request();
        $request->headers->set('Authorization', 'Bearer valid-token');
        
        $payload = new TokenPayload(
            '123e4567-e89b-12d3-a456-426614174000',
            'test@example.com',
            ['user'],
            time(),
            time() + 3600,
            'lms-api',
            'access'
        );

        $this->jwtService->expects($this->once())
            ->method('validateToken')
            ->with('valid-token')
            ->willReturn($payload);

        $expectedResponse = new Response('Success');
        $this->kernel->expects($this->once())
            ->method('handle')
            ->with($request)
            ->willReturn($expectedResponse);

        // Act
        $response = $this->middleware->handle($request);

        // Assert
        $this->assertEquals($expectedResponse, $response);
        $this->assertEquals('123e4567-e89b-12d3-a456-426614174000', $request->attributes->get('userId'));
        $this->assertEquals(['user'], $request->attributes->get('userRoles'));
    }

    public function testMissingTokenReturnsUnauthorized()
    {
        // Arrange
        $request = new Request();

        // Act
        $response = $this->middleware->handle($request);

        // Assert
        $this->assertEquals(401, $response->getStatusCode());
        $this->assertStringContainsString('Missing authorization header', $response->getContent());
    }

    public function testInvalidTokenFormatReturnsUnauthorized()
    {
        // Arrange
        $request = new Request();
        $request->headers->set('Authorization', 'InvalidFormat token');

        // Act
        $response = $this->middleware->handle($request);

        // Assert
        $this->assertEquals(401, $response->getStatusCode());
        $this->assertStringContainsString('Invalid authorization format', $response->getContent());
    }

    public function testExpiredTokenReturnsUnauthorized()
    {
        // Arrange
        $request = new Request();
        $request->headers->set('Authorization', 'Bearer expired-token');

        $this->jwtService->expects($this->once())
            ->method('validateToken')
            ->with('expired-token')
            ->willThrowException(InvalidTokenException::expired());

        // Act
        $response = $this->middleware->handle($request);

        // Assert
        $this->assertEquals(401, $response->getStatusCode());
        $this->assertStringContainsString('Token has expired', $response->getContent());
    }

    public function testInvalidSignatureReturnsUnauthorized()
    {
        // Arrange
        $request = new Request();
        $request->headers->set('Authorization', 'Bearer invalid-signature-token');

        $this->jwtService->expects($this->once())
            ->method('validateToken')
            ->with('invalid-signature-token')
            ->willThrowException(InvalidTokenException::invalidSignature());

        // Act
        $response = $this->middleware->handle($request);

        // Assert
        $this->assertEquals(401, $response->getStatusCode());
        $this->assertStringContainsString('Invalid token signature', $response->getContent());
    }

    public function testPublicRoutesAreAccessibleWithoutToken()
    {
        // Arrange
        $publicRoutes = ['/api/auth/login', '/api/auth/register', '/api/health'];
        
        $expectedResponse = new Response('Public route');
        $this->kernel->expects($this->exactly(count($publicRoutes)))
            ->method('handle')
            ->willReturn($expectedResponse);
        
        foreach ($publicRoutes as $route) {
            $request = new Request([], [], [], [], [], ['REQUEST_URI' => $route]);

            // Act
            $response = $this->middleware->handle($request);

            // Assert
            $this->assertEquals($expectedResponse, $response);
        }
    }
} 