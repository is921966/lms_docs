<?php

declare(strict_types=1);

namespace Tests\Unit\ApiGateway\Http\Controllers;

use PHPUnit\Framework\TestCase;
use ApiGateway\Http\Controllers\AuthController;
use ApiGateway\Domain\Services\JwtServiceInterface;
use ApiGateway\Domain\ValueObjects\JwtToken;
use ApiGateway\Domain\Exceptions\InvalidTokenException;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Request as SymfonyRequest;
use GuzzleHttp\Client;
use GuzzleHttp\Psr7\Response;
use Mockery;

class AuthControllerTest extends TestCase
{
    private AuthController $controller;
    private $jwtService;
    private $httpClient;
    
    protected function setUp(): void
    {
        $this->jwtService = Mockery::mock(JwtServiceInterface::class);
        $this->httpClient = Mockery::mock(Client::class);
        
        $this->controller = new AuthController(
            $this->jwtService,
            $this->httpClient,
            'http://auth-service:8081'
        );
    }
    
    protected function tearDown(): void
    {
        Mockery::close();
    }
    
    private function createRequest(string $uri, string $method = 'GET', array $parameters = []): Request
    {
        $symfonyRequest = SymfonyRequest::create($uri, $method, $parameters);
        return Request::createFromBase($symfonyRequest);
    }
    
    public function testLoginSuccess(): void
    {
        $request = $this->createRequest('/api/v1/auth/login', 'POST', [
            'email' => 'test@example.com',
            'password' => 'password123'
        ]);
        
        $authResponse = [
            'user' => [
                'id' => '550e8400-e29b-41d4-a716-446655440000',
                'email' => 'test@example.com',
                'role' => 'admin'
            ]
        ];
        
        $this->httpClient->shouldReceive('post')
            ->with('http://auth-service:8081/login', Mockery::type('array'))
            ->once()
            ->andReturn(new Response(200, [], json_encode($authResponse)));
        
        $token = new JwtToken(
            'access.token.here',
            'refresh.token.here',
            3600,
            new \DateTimeImmutable()
        );
        
        $this->jwtService->shouldReceive('generateToken')
            ->once()
            ->andReturn($token);
        
        $response = $this->controller->login($request);
        
        $this->assertEquals(200, $response->getStatusCode());
        $data = json_decode($response->getContent(), true);
        $this->assertArrayHasKey('data', $data);
        $this->assertArrayHasKey('user', $data['data']);
        $this->assertArrayHasKey('token', $data['data']);
        $this->assertEquals('Bearer', $data['data']['token']['token_type']);
    }
    
    public function testLoginInvalidCredentials(): void
    {
        $request = $this->createRequest('/api/v1/auth/login', 'POST', [
            'email' => 'test@example.com',
            'password' => 'wrong'
        ]);
        
        $this->httpClient->shouldReceive('post')
            ->once()
            ->andReturn(new Response(401, [], json_encode(['message' => 'Invalid credentials'])));
        
        $response = $this->controller->login($request);
        
        $this->assertEquals(401, $response->getStatusCode());
    }
    
    public function testLoginServiceUnavailable(): void
    {
        $request = $this->createRequest('/api/v1/auth/login', 'POST', [
            'email' => 'test@example.com',
            'password' => 'password123'
        ]);
        
        $this->httpClient->shouldReceive('post')
            ->once()
            ->andThrow(new \Exception('Connection failed'));
        
        $response = $this->controller->login($request);
        
        $this->assertEquals(503, $response->getStatusCode());
    }
    
    public function testLogoutSuccess(): void
    {
        $request = $this->createRequest('/api/v1/auth/logout', 'POST');
        $request->headers->set('Authorization', 'Bearer token123');
        
        $this->jwtService->shouldReceive('blacklistToken')
            ->with('token123')
            ->once();
        
        $response = $this->controller->logout($request);
        
        $this->assertEquals(200, $response->getStatusCode());
        $data = json_decode($response->getContent(), true);
        $this->assertEquals('Successfully logged out', $data['data']['message']);
    }
    
    public function testLogoutWithoutToken(): void
    {
        $request = $this->createRequest('/api/v1/auth/logout', 'POST');
        
        $response = $this->controller->logout($request);
        
        $this->assertEquals(200, $response->getStatusCode());
    }
    
    public function testRefreshTokenSuccess(): void
    {
        $request = $this->createRequest('/api/v1/auth/refresh', 'POST', [
            'refresh_token' => 'old.refresh.token'
        ]);
        
        $newToken = new JwtToken(
            'new.access.token',
            'new.refresh.token',
            3600,
            new \DateTimeImmutable()
        );
        
        $this->jwtService->shouldReceive('refreshToken')
            ->with('old.refresh.token')
            ->once()
            ->andReturn($newToken);
        
        $response = $this->controller->refresh($request);
        
        $this->assertEquals(200, $response->getStatusCode());
        $data = json_decode($response->getContent(), true);
        $this->assertEquals('new.access.token', $data['data']['token']['access_token']);
        $this->assertEquals('new.refresh.token', $data['data']['token']['refresh_token']);
    }
    
    public function testRefreshTokenInvalid(): void
    {
        $request = $this->createRequest('/api/v1/auth/refresh', 'POST', [
            'refresh_token' => 'invalid.token'
        ]);
        
        $this->jwtService->shouldReceive('refreshToken')
            ->once()
            ->andThrow(InvalidTokenException::expired());
        
        $response = $this->controller->refresh($request);
        
        $this->assertEquals(401, $response->getStatusCode());
    }
    
    public function testMeSuccess(): void
    {
        $request = $this->createRequest('/api/v1/auth/me', 'GET');
        $request->merge(['user_id' => '550e8400-e29b-41d4-a716-446655440000']);
        
        $userResponse = [
            'id' => '550e8400-e29b-41d4-a716-446655440000',
            'email' => 'test@example.com',
            'name' => 'Test User'
        ];
        
        $this->httpClient->shouldReceive('get')
            ->with('http://user-service:8080/users/550e8400-e29b-41d4-a716-446655440000', Mockery::type('array'))
            ->once()
            ->andReturn(new Response(200, [], json_encode($userResponse)));
        
        $response = $this->controller->me($request);
        
        $this->assertEquals(200, $response->getStatusCode());
        $data = json_decode($response->getContent(), true);
        $this->assertEquals('test@example.com', $data['data']['user']['email']);
    }
    
    public function testMeUserNotFound(): void
    {
        $request = $this->createRequest('/api/v1/auth/me', 'GET');
        $request->merge(['user_id' => '550e8400-e29b-41d4-a716-446655440000']);
        
        $this->httpClient->shouldReceive('get')
            ->once()
            ->andReturn(new Response(404, [], json_encode(['message' => 'User not found'])));
        
        $response = $this->controller->me($request);
        
        $this->assertEquals(404, $response->getStatusCode());
    }
} 