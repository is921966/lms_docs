<?php

declare(strict_types=1);

namespace App\Common\Middleware;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface;

/**
 * CORS (Cross-Origin Resource Sharing) Middleware
 */
class CorsMiddleware implements MiddlewareInterface
{
    private array $allowedOrigins;
    private array $allowedMethods;
    private array $allowedHeaders;
    private array $exposedHeaders;
    private int $maxAge;
    private bool $supportsCredentials;
    
    public function __construct(array $config = [])
    {
        $this->allowedOrigins = $config['allowed_origins'] ?? ['*'];
        $this->allowedMethods = $config['allowed_methods'] ?? ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'];
        $this->allowedHeaders = $config['allowed_headers'] ?? ['Content-Type', 'Authorization', 'X-Requested-With'];
        $this->exposedHeaders = $config['exposed_headers'] ?? [];
        $this->maxAge = $config['max_age'] ?? 3600;
        $this->supportsCredentials = $config['supports_credentials'] ?? false;
    }
    
    /**
     * Process the request and add CORS headers
     */
    public function process(
        ServerRequestInterface $request,
        RequestHandlerInterface $handler
    ): ResponseInterface {
        // Handle preflight requests
        if ($request->getMethod() === 'OPTIONS') {
            return $this->handlePreflight($request);
        }
        
        // Process the request
        $response = $handler->handle($request);
        
        // Add CORS headers to response
        return $this->addCorsHeaders($request, $response);
    }
    
    /**
     * Handle preflight OPTIONS request
     */
    private function handlePreflight(ServerRequestInterface $request): ResponseInterface
    {
        $response = new \Slim\Psr7\Response();
        
        return $this->addCorsHeaders($request, $response)
            ->withStatus(204);
    }
    
    /**
     * Add CORS headers to response
     */
    private function addCorsHeaders(
        ServerRequestInterface $request,
        ResponseInterface $response
    ): ResponseInterface {
        $origin = $request->getHeaderLine('Origin');
        
        // Check if origin is allowed
        if ($this->isOriginAllowed($origin)) {
            $response = $response->withHeader('Access-Control-Allow-Origin', $origin);
        } elseif (in_array('*', $this->allowedOrigins)) {
            $response = $response->withHeader('Access-Control-Allow-Origin', '*');
        }
        
        // Add other CORS headers
        $response = $response
            ->withHeader('Access-Control-Allow-Methods', implode(', ', $this->allowedMethods))
            ->withHeader('Access-Control-Allow-Headers', implode(', ', $this->allowedHeaders))
            ->withHeader('Access-Control-Max-Age', (string) $this->maxAge);
        
        // Add exposed headers if any
        if (!empty($this->exposedHeaders)) {
            $response = $response->withHeader(
                'Access-Control-Expose-Headers',
                implode(', ', $this->exposedHeaders)
            );
        }
        
        // Add credentials support
        if ($this->supportsCredentials) {
            $response = $response->withHeader('Access-Control-Allow-Credentials', 'true');
        }
        
        // Add Vary header
        if (!in_array('*', $this->allowedOrigins)) {
            $vary = $response->getHeaderLine('Vary');
            $varyHeaders = $vary ? explode(', ', $vary) : [];
            
            if (!in_array('Origin', $varyHeaders)) {
                $varyHeaders[] = 'Origin';
                $response = $response->withHeader('Vary', implode(', ', $varyHeaders));
            }
        }
        
        return $response;
    }
    
    /**
     * Check if origin is allowed
     */
    private function isOriginAllowed(string $origin): bool
    {
        if (empty($origin)) {
            return false;
        }
        
        foreach ($this->allowedOrigins as $allowed) {
            if ($allowed === '*') {
                return true;
            }
            
            if ($allowed === $origin) {
                return true;
            }
            
            // Check wildcard subdomains (e.g., *.example.com)
            if (strpos($allowed, '*.') === 0) {
                $domain = substr($allowed, 2);
                if (preg_match('/\.?' . preg_quote($domain, '/') . '$/', $origin)) {
                    return true;
                }
            }
        }
        
        return false;
    }
} 