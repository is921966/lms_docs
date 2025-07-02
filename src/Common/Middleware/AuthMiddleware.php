<?php

declare(strict_types=1);

namespace Common\Middleware;

use Common\Exceptions\AuthorizationException;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Symfony\Component\HttpFoundation\JsonResponse;

/**
 * JWT Authentication Middleware
 */
class AuthMiddleware implements MiddlewareInterface
{
    private string $jwtSecret;
    private string $jwtAlgo;
    private array $publicRoutes;
    
    public function __construct(
        string $jwtSecret,
        string $jwtAlgo = 'HS256',
        array $publicRoutes = []
    ) {
        $this->jwtSecret = $jwtSecret;
        $this->jwtAlgo = $jwtAlgo;
        $this->publicRoutes = $publicRoutes;
    }
    
    /**
     * Process the request and validate JWT token
     */
    public function process(
        ServerRequestInterface $request,
        RequestHandlerInterface $handler
    ): ResponseInterface {
        // Skip auth for public routes
        $path = $request->getUri()->getPath();
        if ($this->isPublicRoute($path)) {
            return $handler->handle($request);
        }
        
        // Check for Authorization header
        $authHeader = $request->getHeaderLine('Authorization');
        if (empty($authHeader)) {
            return $this->unauthorizedResponse('Missing authorization header');
        }
        
        // Extract token
        if (!preg_match('/Bearer\s+(.+)/', $authHeader, $matches)) {
            return $this->unauthorizedResponse('Invalid authorization format');
        }
        
        $token = $matches[1];
        
        try {
            // Decode and verify JWT
            $decoded = JWT::decode($token, new Key($this->jwtSecret, $this->jwtAlgo));
            
            // Check expiration
            if (isset($decoded->exp) && $decoded->exp < time()) {
                return $this->unauthorizedResponse('Token expired');
            }
            
            // Add user info to request
            $request = $request->withAttribute('user_id', $decoded->sub);
            $request = $request->withAttribute('user_roles', $decoded->roles ?? []);
            $request = $request->withAttribute('jwt_claims', $decoded);
            
            return $handler->handle($request);
            
        } catch (\Exception $e) {
            return $this->unauthorizedResponse('Invalid token: ' . $e->getMessage());
        }
    }
    
    /**
     * Check if route is public
     */
    private function isPublicRoute(string $path): bool
    {
        foreach ($this->publicRoutes as $pattern) {
            if (preg_match($pattern, $path)) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * Create unauthorized response
     */
    private function unauthorizedResponse(string $message): ResponseInterface
    {
        $response = new JsonResponse([
            'error' => [
                'code' => 'UNAUTHORIZED',
                'message' => $message,
            ]
        ], 401);
        
        return $response;
    }
} 