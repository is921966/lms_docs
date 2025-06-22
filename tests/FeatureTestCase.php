<?php

namespace Tests;

use Slim\App;
use Slim\Psr7\Factory\ServerRequestFactory;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;

abstract class FeatureTestCase extends IntegrationTestCase
{
    protected App $app;
    protected ?string $authToken = null;
    
    protected function setUp(): void
    {
        parent::setUp();
        
        // Bootstrap application
        $this->app = $this->createApplication();
    }
    
    protected function createApplication(): App
    {
        // This would be replaced with actual application bootstrap
        $app = new App();
        
        // Register services
        $container = $app->getContainer();
        $container->set('entityManager', $this->entityManager);
        
        // Load routes
        require __DIR__ . '/../config/routes/api.php';
        
        // Add middleware
        $app->addBodyParsingMiddleware();
        $app->addRoutingMiddleware();
        $app->addErrorMiddleware(true, true, true);
        
        return $app;
    }
    
    /**
     * Make HTTP request
     */
    protected function request(
        string $method,
        string $uri,
        array $data = [],
        array $headers = []
    ): ResponseInterface {
        $request = $this->createRequest($method, $uri, $headers);
        
        if (!empty($data)) {
            $request = $request->withParsedBody($data);
        }
        
        return $this->app->handle($request);
    }
    
    /**
     * Make authenticated HTTP request
     */
    protected function actingAs($user): self
    {
        // Generate JWT token for user
        $this->authToken = $this->generateTokenForUser($user);
        return $this;
    }
    
    /**
     * Create server request
     */
    protected function createRequest(
        string $method,
        string $uri,
        array $headers = []
    ): ServerRequestInterface {
        $factory = new ServerRequestFactory();
        $request = $factory->createServerRequest($method, $uri);
        
        // Add default headers
        $request = $request->withHeader('Accept', 'application/json');
        $request = $request->withHeader('Content-Type', 'application/json');
        
        // Add auth token if set
        if ($this->authToken) {
            $request = $request->withHeader('Authorization', 'Bearer ' . $this->authToken);
        }
        
        // Add custom headers
        foreach ($headers as $name => $value) {
            $request = $request->withHeader($name, $value);
        }
        
        return $request;
    }
    
    /**
     * JSON request shortcuts
     */
    protected function getJson(string $uri, array $headers = []): ResponseInterface
    {
        return $this->request('GET', $uri, [], $headers);
    }
    
    protected function postJson(string $uri, array $data = [], array $headers = []): ResponseInterface
    {
        return $this->request('POST', $uri, $data, $headers);
    }
    
    protected function putJson(string $uri, array $data = [], array $headers = []): ResponseInterface
    {
        return $this->request('PUT', $uri, $data, $headers);
    }
    
    protected function deleteJson(string $uri, array $headers = []): ResponseInterface
    {
        return $this->request('DELETE', $uri, [], $headers);
    }
    
    /**
     * Response assertions
     */
    protected function assertResponseOk(ResponseInterface $response): void
    {
        $this->assertEquals(200, $response->getStatusCode());
    }
    
    protected function assertResponseCreated(ResponseInterface $response): void
    {
        $this->assertEquals(201, $response->getStatusCode());
    }
    
    protected function assertResponseNoContent(ResponseInterface $response): void
    {
        $this->assertEquals(204, $response->getStatusCode());
    }
    
    protected function assertResponseUnauthorized(ResponseInterface $response): void
    {
        $this->assertEquals(401, $response->getStatusCode());
    }
    
    protected function assertResponseForbidden(ResponseInterface $response): void
    {
        $this->assertEquals(403, $response->getStatusCode());
    }
    
    protected function assertResponseNotFound(ResponseInterface $response): void
    {
        $this->assertEquals(404, $response->getStatusCode());
    }
    
    protected function assertResponseValidationError(ResponseInterface $response): void
    {
        $this->assertEquals(422, $response->getStatusCode());
    }
    
    /**
     * JSON response assertions
     */
    protected function assertJsonResponse(ResponseInterface $response): array
    {
        $contentType = $response->getHeaderLine('Content-Type');
        $this->assertStringContainsString('application/json', $contentType);
        
        $body = (string) $response->getBody();
        $data = json_decode($body, true);
        
        $this->assertIsArray($data);
        
        return $data;
    }
    
    protected function assertJsonSuccess(ResponseInterface $response): array
    {
        $data = $this->assertJsonResponse($response);
        $this->assertTrue($data['success'] ?? false);
        
        return $data;
    }
    
    protected function assertJsonError(ResponseInterface $response): array
    {
        $data = $this->assertJsonResponse($response);
        $this->assertFalse($data['success'] ?? true);
        
        return $data;
    }
    
    protected function assertJsonStructure(array $structure, array $data): void
    {
        foreach ($structure as $key => $value) {
            if (is_array($value) && $key === '*') {
                // Validate each item in array
                $this->assertIsArray($data);
                foreach ($data as $item) {
                    $this->assertJsonStructure($value, $item);
                }
            } elseif (is_array($value)) {
                // Nested structure
                $this->assertArrayHasKey($key, $data);
                $this->assertJsonStructure($value, $data[$key]);
            } else {
                // Simple key
                $this->assertArrayHasKey($value, $data);
            }
        }
    }
    
    /**
     * Generate JWT token for user
     */
    protected function generateTokenForUser($user): string
    {
        // This would use actual JWT service
        return 'test-token-' . $user->getId()->getValue();
    }
    
    /**
     * Create user and authenticate
     */
    protected function createAuthenticatedUser(array $attributes = []): object
    {
        $user = $this->createUser($attributes);
        $this->actingAs($user);
        
        return $user;
    }
    
    /**
     * Create test user
     */
    protected function createUser(array $attributes = []): object
    {
        $defaults = [
            'email' => $this->faker->unique()->safeEmail,
            'firstName' => $this->faker->firstName,
            'lastName' => $this->faker->lastName,
            'password' => 'Password123!',
        ];
        
        $data = array_merge($defaults, $attributes);
        
        $user = new \App\User\Domain\User(
            \App\User\Domain\ValueObjects\UserId::generate(),
            new \App\User\Domain\ValueObjects\Email($data['email']),
            $data['firstName'],
            $data['lastName'],
            \App\User\Domain\ValueObjects\Password::fromPlainText($data['password'])
        );
        
        $this->entityManager->persist($user);
        $this->entityManager->flush();
        
        return $user;
    }
} 