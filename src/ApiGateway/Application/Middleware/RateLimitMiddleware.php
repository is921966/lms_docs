<?php

declare(strict_types=1);

namespace ApiGateway\Application\Middleware;

use ApiGateway\Domain\Services\RateLimiterInterface;
use ApiGateway\Domain\ValueObjects\RateLimitKey;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpKernel\HttpKernelInterface;

class RateLimitMiddleware implements HttpKernelInterface
{
    private HttpKernelInterface $app;
    private RateLimiterInterface $rateLimiter;
    private array $config;
    
    public function __construct(
        HttpKernelInterface $app,
        RateLimiterInterface $rateLimiter,
        array $config = []
    ) {
        $this->app = $app;
        $this->rateLimiter = $rateLimiter;
        $this->config = array_merge([
            'default_limit' => 100,
            'window_seconds' => 60,
            'key_strategy' => 'user', // 'user', 'ip', or 'mixed'
        ], $config);
    }
    
    public function handle(Request $request, int $type = self::MAIN_REQUEST, bool $catch = true): Response
    {
        // Create rate limit key based on strategy
        $key = $this->createRateLimitKey($request);
        
        // Check rate limit
        $result = $this->rateLimiter->consume($key);
        
        // Always add rate limit headers
        $response = null;
        
        if ($result->isDenied()) {
            // Create rate limit exceeded response
            $response = new JsonResponse([
                'error' => 'Rate limit exceeded',
                'message' => $result->getReason() ?? 'Too many requests',
                'retry_after' => $result->getResetsIn()
            ], Response::HTTP_TOO_MANY_REQUESTS);
        } else {
            // Continue with the request
            $response = $this->app->handle($request, $type, $catch);
        }
        
        // Add rate limit headers to response
        foreach ($result->toHeaders() as $header => $value) {
            $response->headers->set($header, $value);
        }
        
        return $response;
    }
    
    private function createRateLimitKey(Request $request): RateLimitKey
    {
        $strategy = $this->config['key_strategy'];
        
        switch ($strategy) {
            case 'user':
                // Try to get user ID from request attributes (set by auth middleware)
                $userId = $request->attributes->get('user_id');
                if ($userId) {
                    return RateLimitKey::forUser($userId);
                }
                // Fallback to IP if no user
                return RateLimitKey::forIp($this->getClientIp($request));
                
            case 'ip':
                return RateLimitKey::forIp($this->getClientIp($request));
                
            case 'mixed':
                // Use user ID if authenticated, otherwise use IP
                $userId = $request->attributes->get('user_id');
                if ($userId) {
                    return RateLimitKey::forUser($userId);
                }
                return RateLimitKey::forIp($this->getClientIp($request));
                
            default:
                // Global rate limiting
                return RateLimitKey::global();
        }
    }
    
    private function getClientIp(Request $request): string
    {
        // Get real IP considering proxies
        $ip = $request->getClientIp();
        
        // Fallback to remote address if needed
        if (!$ip) {
            $ip = $request->server->get('REMOTE_ADDR', '0.0.0.0');
        }
        
        return $ip;
    }
} 