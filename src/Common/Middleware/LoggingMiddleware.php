<?php

declare(strict_types=1);

namespace App\Common\Middleware;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Psr\Log\LoggerInterface;
use Ramsey\Uuid\Uuid;

/**
 * Request/Response Logging Middleware
 */
class LoggingMiddleware implements MiddlewareInterface
{
    private LoggerInterface $logger;
    private array $sensitiveHeaders;
    private array $sensitiveParams;
    private bool $logRequestBody;
    private bool $logResponseBody;
    private int $maxBodySize;
    
    public function __construct(
        LoggerInterface $logger,
        array $config = []
    ) {
        $this->logger = $logger;
        $this->sensitiveHeaders = $config['sensitive_headers'] ?? ['authorization', 'cookie', 'x-api-key'];
        $this->sensitiveParams = $config['sensitive_params'] ?? ['password', 'token', 'secret'];
        $this->logRequestBody = $config['log_request_body'] ?? false;
        $this->logResponseBody = $config['log_response_body'] ?? false;
        $this->maxBodySize = $config['max_body_size'] ?? 1024; // 1KB
    }
    
    /**
     * Process the request and log details
     */
    public function process(
        ServerRequestInterface $request,
        RequestHandlerInterface $handler
    ): ResponseInterface {
        $requestId = Uuid::uuid4()->toString();
        $startTime = microtime(true);
        
        // Add request ID to request
        $request = $request->withAttribute('request_id', $requestId);
        
        // Log request
        $this->logRequest($request, $requestId);
        
        try {
            // Process request
            $response = $handler->handle($request);
            
            // Log response
            $duration = microtime(true) - $startTime;
            $this->logResponse($request, $response, $requestId, $duration);
            
            // Add request ID to response header
            return $response->withHeader('X-Request-ID', $requestId);
            
        } catch (\Throwable $e) {
            // Log error
            $duration = microtime(true) - $startTime;
            $this->logError($request, $e, $requestId, $duration);
            
            throw $e;
        }
    }
    
    /**
     * Log incoming request
     */
    private function logRequest(ServerRequestInterface $request, string $requestId): void
    {
        $context = [
            'request_id' => $requestId,
            'method' => $request->getMethod(),
            'uri' => (string) $request->getUri(),
            'headers' => $this->sanitizeHeaders($request->getHeaders()),
            'query_params' => $this->sanitizeParams($request->getQueryParams()),
            'client_ip' => $this->getClientIp($request),
            'user_agent' => $request->getHeaderLine('User-Agent'),
        ];
        
        if ($this->logRequestBody && $request->getBody()->getSize() <= $this->maxBodySize) {
            $body = (string) $request->getBody();
            $request->getBody()->rewind();
            
            if ($this->isJson($request)) {
                $context['body'] = $this->sanitizeJson($body);
            } else {
                $context['body'] = substr($body, 0, $this->maxBodySize);
            }
        }
        
        $this->logger->info('Incoming request', $context);
    }
    
    /**
     * Log outgoing response
     */
    private function logResponse(
        ServerRequestInterface $request,
        ResponseInterface $response,
        string $requestId,
        float $duration
    ): void {
        $context = [
            'request_id' => $requestId,
            'status_code' => $response->getStatusCode(),
            'duration_ms' => round($duration * 1000, 2),
            'memory_peak_mb' => round(memory_get_peak_usage() / 1024 / 1024, 2),
        ];
        
        if ($this->logResponseBody && $response->getBody()->getSize() <= $this->maxBodySize) {
            $body = (string) $response->getBody();
            $response->getBody()->rewind();
            
            if ($this->isJson($response)) {
                $context['body'] = json_decode($body, true);
            } else {
                $context['body'] = substr($body, 0, $this->maxBodySize);
            }
        }
        
        $level = $response->getStatusCode() >= 400 ? 'warning' : 'info';
        $this->logger->log($level, 'Request completed', $context);
    }
    
    /**
     * Log error during request processing
     */
    private function logError(
        ServerRequestInterface $request,
        \Throwable $error,
        string $requestId,
        float $duration
    ): void {
        $this->logger->error('Request failed', [
            'request_id' => $requestId,
            'duration_ms' => round($duration * 1000, 2),
            'error' => [
                'class' => get_class($error),
                'message' => $error->getMessage(),
                'file' => $error->getFile(),
                'line' => $error->getLine(),
                'trace' => $error->getTraceAsString(),
            ],
        ]);
    }
    
    /**
     * Sanitize headers to remove sensitive data
     */
    private function sanitizeHeaders(array $headers): array
    {
        $sanitized = [];
        
        foreach ($headers as $name => $values) {
            $lowerName = strtolower($name);
            
            if (in_array($lowerName, $this->sensitiveHeaders)) {
                $sanitized[$name] = ['***REDACTED***'];
            } else {
                $sanitized[$name] = $values;
            }
        }
        
        return $sanitized;
    }
    
    /**
     * Sanitize parameters to remove sensitive data
     */
    private function sanitizeParams(array $params): array
    {
        $sanitized = [];
        
        foreach ($params as $key => $value) {
            if (in_array(strtolower($key), $this->sensitiveParams)) {
                $sanitized[$key] = '***REDACTED***';
            } elseif (is_array($value)) {
                $sanitized[$key] = $this->sanitizeParams($value);
            } else {
                $sanitized[$key] = $value;
            }
        }
        
        return $sanitized;
    }
    
    /**
     * Sanitize JSON body
     */
    private function sanitizeJson(string $json): array
    {
        $data = json_decode($json, true);
        
        if (!is_array($data)) {
            return [];
        }
        
        return $this->sanitizeParams($data);
    }
    
    /**
     * Check if request/response contains JSON
     */
    private function isJson($message): bool
    {
        $contentType = $message->getHeaderLine('Content-Type');
        return strpos($contentType, 'application/json') !== false;
    }
    
    /**
     * Get client IP address
     */
    private function getClientIp(ServerRequestInterface $request): string
    {
        $params = $request->getServerParams();
        
        // Check for forwarded IP
        if (!empty($params['HTTP_X_FORWARDED_FOR'])) {
            $ips = explode(',', $params['HTTP_X_FORWARDED_FOR']);
            return trim($ips[0]);
        }
        
        if (!empty($params['HTTP_X_REAL_IP'])) {
            return $params['HTTP_X_REAL_IP'];
        }
        
        return $params['REMOTE_ADDR'] ?? 'unknown';
    }
} 