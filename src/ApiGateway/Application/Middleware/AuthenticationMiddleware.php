<?php

declare(strict_types=1);

namespace ApiGateway\Application\Middleware;

use ApiGateway\Domain\Services\JwtServiceInterface;
use ApiGateway\Domain\Exceptions\InvalidTokenException;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpKernel\HttpKernelInterface;

class AuthenticationMiddleware implements HttpKernelInterface
{
    private HttpKernelInterface $app;
    private JwtServiceInterface $jwtService;
    private array $excludedPaths;
    
    public function __construct(
        HttpKernelInterface $app,
        JwtServiceInterface $jwtService,
        array $excludedPaths = []
    ) {
        $this->app = $app;
        $this->jwtService = $jwtService;
        $this->excludedPaths = $excludedPaths;
    }
    
    public function handle(Request $request, int $type = self::MAIN_REQUEST, bool $catch = true): Response
    {
        // Check if path is excluded from authentication
        if ($this->isPathExcluded($request->getPathInfo())) {
            return $this->app->handle($request, $type, $catch);
        }
        
        // Extract token from Authorization header
        $token = $this->extractToken($request);
        
        if (!$token) {
            return new JsonResponse([
                'error' => 'Authentication required',
                'message' => 'Missing authorization token'
            ], Response::HTTP_UNAUTHORIZED);
        }
        
        try {
            // Validate token and get user ID
            $userId = $this->jwtService->validateToken($token);
            
            // Check if token is blacklisted
            if ($this->jwtService->isBlacklisted($token)) {
                return new JsonResponse([
                    'error' => 'Token revoked',
                    'message' => 'This token has been revoked'
                ], Response::HTTP_UNAUTHORIZED);
            }
            
            // Add user ID to request attributes for downstream use
            $request->attributes->set('user_id', $userId->getValue());
            $request->attributes->set('auth_token', $token);
            
            // Continue with the request
            return $this->app->handle($request, $type, $catch);
            
        } catch (InvalidTokenException $e) {
            return new JsonResponse([
                'error' => 'Invalid token',
                'message' => $e->getMessage()
            ], Response::HTTP_UNAUTHORIZED);
        }
    }
    
    private function extractToken(Request $request): ?string
    {
        $authHeader = $request->headers->get('Authorization');
        
        if (!$authHeader) {
            return null;
        }
        
        // Check for Bearer token format
        if (!preg_match('/^Bearer\s+(.+)$/i', $authHeader, $matches)) {
            return null;
        }
        
        return $matches[1];
    }
    
    private function isPathExcluded(string $path): bool
    {
        foreach ($this->excludedPaths as $excludedPath) {
            if (strpos($path, $excludedPath) === 0) {
                return true;
            }
        }
        
        return false;
    }
} 