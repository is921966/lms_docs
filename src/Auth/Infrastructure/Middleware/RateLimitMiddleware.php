<?php

namespace Auth\Infrastructure\Middleware;

use Auth\Domain\Services\RateLimiter;
use Auth\Domain\ValueObjects\RateLimitKey;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpKernel\HttpKernelInterface;

class RateLimitMiddleware implements HttpKernelInterface
{
    private HttpKernelInterface $kernel;
    private RateLimiter $rateLimiter;
    private array $config;

    public function __construct(
        HttpKernelInterface $kernel,
        RateLimiter $rateLimiter,
        array $config = []
    ) {
        $this->kernel = $kernel;
        $this->rateLimiter = $rateLimiter;
        $this->config = array_merge($this->getDefaultConfig(), $config);
    }

    public function handle(Request $request, int $type = self::MAIN_REQUEST, bool $catch = true): Response
    {
        $path = $request->getPathInfo();

        // Check if route is excluded
        if ($this->isExcluded($path)) {
            return $this->kernel->handle($request, $type, $catch);
        }

        // Get rate limit config for route
        $config = $this->getConfigForRoute($path);
        
        // Create rate limit key
        $key = $this->createKey($request);

        // Check rate limit
        $allowed = $this->rateLimiter->allowRequest($key, $config['limit'], $config['window']);
        $remaining = $this->rateLimiter->getRemainingAttempts($key, $config['limit'], $config['window']);
        $resetTime = $this->rateLimiter->getResetTime($key);

        if (!$allowed) {
            return $this->createRateLimitResponse($resetTime);
        }

        // Process request
        $response = $this->kernel->handle($request, $type, $catch);

        // Add rate limit headers
        $this->addRateLimitHeaders($response, $config['limit'], $remaining, $resetTime);

        return $response;
    }

    private function createKey(Request $request): RateLimitKey
    {
        // Use authenticated user ID if available
        $userId = $request->attributes->get('userId');
        if ($userId) {
            return new RateLimitKey($userId, 'user');
        }

        // Fall back to IP address
        $ip = $request->getClientIp() ?: 'unknown';
        return new RateLimitKey($ip, 'ip');
    }

    private function isExcluded(string $path): bool
    {
        foreach ($this->config['exclude'] as $pattern) {
            if (strpos($path, $pattern) === 0) {
                return true;
            }
        }
        return false;
    }

    private function getConfigForRoute(string $path): array
    {
        // Check for route-specific config
        foreach ($this->config['routes'] as $pattern => $config) {
            if (strpos($path, $pattern) === 0) {
                return $config;
            }
        }

        // Return default config
        return $this->config['default'] ?? [
            'limit' => $this->config['limit'] ?? 60,
            'window' => $this->config['window'] ?? 60
        ];
    }

    private function addRateLimitHeaders(Response $response, int $limit, int $remaining, int $resetTime): void
    {
        $response->headers->set('X-RateLimit-Limit', (string) $limit);
        $response->headers->set('X-RateLimit-Remaining', (string) $remaining);
        $response->headers->set('X-RateLimit-Reset', (string) $resetTime);
    }

    private function createRateLimitResponse(int $resetTime): JsonResponse
    {
        $retryAfter = max(0, $resetTime - time());

        $response = new JsonResponse([
            'error' => 'Too Many Requests',
            'message' => 'Rate limit exceeded. Please try again later.',
            'retry_after' => $retryAfter
        ], 429);

        $response->headers->set('Retry-After', (string) $retryAfter);

        return $response;
    }

    private function getDefaultConfig(): array
    {
        return [
            'limit' => 60,
            'window' => 60,
            'exclude' => [],
            'routes' => []
        ];
    }
} 