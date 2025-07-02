<?php

namespace Auth\Infrastructure\Middleware;

use Auth\Domain\Services\JwtService;
use Auth\Domain\Exceptions\InvalidTokenException;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpKernel\HttpKernelInterface;

class AuthenticationMiddleware implements HttpKernelInterface
{
    private JwtService $jwtService;
    private HttpKernelInterface $kernel;
    private array $publicRoutes = [
        '/api/auth/login',
        '/api/auth/register',
        '/api/auth/refresh',
        '/api/health',
        '/api/docs'
    ];

    public function __construct(JwtService $jwtService, HttpKernelInterface $kernel = null)
    {
        $this->jwtService = $jwtService;
        if ($kernel) {
            $this->kernel = $kernel;
        }
    }

    public function handle(Request $request, int $type = self::MAIN_REQUEST, bool $catch = true): Response
    {
        // Check if route is public
        $path = $request->getPathInfo() ?: $request->getRequestUri();
        if ($this->isPublicRoute($path)) {
            return $this->kernel->handle($request, $type, $catch);
        }

        // Get authorization header
        $authHeader = $request->headers->get('Authorization');
        if (!$authHeader) {
            return $this->unauthorizedResponse('Missing authorization header');
        }

        // Validate format
        if (!preg_match('/^Bearer\s+(.+)$/i', $authHeader, $matches)) {
            return $this->unauthorizedResponse('Invalid authorization format');
        }

        $token = $matches[1];

        try {
            // Validate token
            $payload = $this->jwtService->validateToken($token);

            // Add user info to request
            $request->attributes->set('userId', $payload->getUserId());
            $request->attributes->set('userEmail', $payload->getEmail());
            $request->attributes->set('userRoles', $payload->getRoles());

            // Continue to next middleware
            return $this->kernel->handle($request, $type, $catch);

        } catch (InvalidTokenException $e) {
            return $this->unauthorizedResponse($e->getMessage());
        }
    }

    private function isPublicRoute(string $path): bool
    {
        foreach ($this->publicRoutes as $publicRoute) {
            if (strpos($path, $publicRoute) === 0) {
                return true;
            }
        }
        return false;
    }

    private function unauthorizedResponse(string $message): JsonResponse
    {
        return new JsonResponse([
            'error' => 'Unauthorized',
            'message' => $message
        ], 401);
    }

    public function setKernel(HttpKernelInterface $kernel): void
    {
        $this->kernel = $kernel;
    }
} 