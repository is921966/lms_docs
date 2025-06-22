<?php

declare(strict_types=1);

namespace App\Common\Middleware;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\RateLimiter\RateLimiterFactory;

/**
 * Rate Limiting Middleware
 */
class RateLimitMiddleware implements MiddlewareInterface
{
    private RateLimiterFactory $limiterFactory;
    private array $limits;
    private string $identifierType;
    
    public function __construct(
        RateLimiterFactory $limiterFactory,
        array $limits = [],
        string $identifierType = 'ip'
    ) {
        $this->limiterFactory = $limiterFactory;
        $this->limits = array_merge([
            'default' => ['limit' => 60, 'interval' => '1 minute'],
            'auth' => ['limit' => 5, 'interval' => '1 minute'],
            'api' => ['limit' => 1000, 'interval' => '1 hour'],
        ], $limits);
        $this->identifierType = $identifierType;
    }
    
    /**
     * Process the request and apply rate limiting
     */
    public function process(
        ServerRequestInterface $request,
        RequestHandlerInterface $handler
    ): ResponseInterface {
        $identifier = $this->getIdentifier($request);
        $route = $this->getRoute($request);
        $limitConfig = $this->getLimitConfig($route);
        
        // Get or create limiter for this identifier
        $limiter = $this->limiterFactory->create($identifier);
        
        // Consume a token
        $limit = $limiter->consume(1);
        
        if (!$limit->isAccepted()) {
            return $this->createRateLimitResponse($limit);
        }
        
        // Process request
        $response = $handler->handle($request);
        
        // Add rate limit headers
        return $this->addRateLimitHeaders($response, $limit);
    }
    
    /**
     * Get identifier for rate limiting
     */
    private function getIdentifier(ServerRequestInterface $request): string
    {
        switch ($this->identifierType) {
            case 'user':
                $userId = $request->getAttribute('user_id');
                if ($userId) {
                    return 'user:' . $userId;
                }
                // Fall back to IP if no user
                
            case 'ip':
            default:
                return 'ip:' . $this->getClientIp($request);
        }
    }
    
    /**
     * Get route name from request
     */
    private function getRoute(ServerRequestInterface $request): string
    {
        $route = $request->getAttribute('_route');
        
        if (!$route) {
            $path = $request->getUri()->getPath();
            
            // Determine route type by path
            if (strpos($path, '/auth/') !== false) {
                return 'auth';
            } elseif (strpos($path, '/api/') !== false) {
                return 'api';
            }
        }
        
        return $route ?: 'default';
    }
    
    /**
     * Get limit configuration for route
     */
    private function getLimitConfig(string $route): array
    {
        // Check for specific route limit
        if (isset($this->limits[$route])) {
            return $this->limits[$route];
        }
        
        // Check for wildcard matches
        foreach ($this->limits as $pattern => $config) {
            if (fnmatch($pattern, $route)) {
                return $config;
            }
        }
        
        return $this->limits['default'];
    }
    
    /**
     * Create rate limit exceeded response
     */
    private function createRateLimitResponse($limit): ResponseInterface
    {
        $retryAfter = $limit->getRetryAfter()->getTimestamp() - time();
        
        $response = new JsonResponse([
            'error' => [
                'code' => 'RATE_LIMIT_EXCEEDED',
                'message' => 'Too many requests. Please try again later.',
                'retry_after' => $retryAfter,
            ]
        ], 429);
        
        return $response->withHeader('Retry-After', (string) $retryAfter);
    }
    
    /**
     * Add rate limit headers to response
     */
    private function addRateLimitHeaders(ResponseInterface $response, $limit): ResponseInterface
    {
        return $response
            ->withHeader('X-RateLimit-Limit', (string) $limit->getLimit())
            ->withHeader('X-RateLimit-Remaining', (string) $limit->getRemainingTokens())
            ->withHeader('X-RateLimit-Reset', (string) $limit->getRetryAfter()->getTimestamp());
    }
    
    /**
     * Get client IP address
     */
    private function getClientIp(ServerRequestInterface $request): string
    {
        $params = $request->getServerParams();
        
        if (!empty($params['HTTP_X_FORWARDED_FOR'])) {
            $ips = explode(',', $params['HTTP_X_FORWARDED_FOR']);
            return trim($ips[0]);
        }
        
        if (!empty($params['HTTP_X_REAL_IP'])) {
            return $params['HTTP_X_REAL_IP'];
        }
        
        return $params['REMOTE_ADDR'] ?? '127.0.0.1';
    }
} 