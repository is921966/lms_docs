<?php

declare(strict_types=1);

namespace ApiGateway\Http\Controllers;

use ApiGateway\Domain\Services\ServiceRouterInterface;
use ApiGateway\Domain\Services\JwtServiceInterface;
use ApiGateway\Domain\Services\RateLimiterInterface;
use ApiGateway\Domain\ValueObjects\HttpMethod;
use ApiGateway\Domain\ValueObjects\RateLimitKey;
use ApiGateway\Domain\Exceptions\RouteNotFoundException;
use ApiGateway\Domain\Exceptions\ServiceNotFoundException;
use ApiGateway\Domain\Exceptions\RateLimitExceededException;
use Common\Http\BaseController;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use GuzzleHttp\Client;
use GuzzleHttp\Exception\RequestException;

class GatewayController extends BaseController
{
    private ServiceRouterInterface $router;
    private JwtServiceInterface $jwtService;
    private RateLimiterInterface $rateLimiter;
    private Client $httpClient;
    
    public function __construct(
        ServiceRouterInterface $router,
        JwtServiceInterface $jwtService,
        RateLimiterInterface $rateLimiter,
        Client $httpClient
    ) {
        $this->router = $router;
        $this->jwtService = $jwtService;
        $this->rateLimiter = $rateLimiter;
        $this->httpClient = $httpClient;
    }
    
    public function proxy(Request $request): JsonResponse
    {
        try {
            // Get HTTP method
            $method = HttpMethod::fromString($request->method());
            
            // Get path
            $path = $request->path();
            
            // Route to service
            $endpoint = $this->router->route($path, $method);
            
            // Check rate limit
            $userId = $request->get('user_id'); // Set by auth middleware
            $rateLimitKey = RateLimitKey::forUser($userId);
            
            if (!$this->rateLimiter->checkLimit($rateLimitKey)) {
                throw RateLimitExceededException::forKey($rateLimitKey->getValue());
            }
            
            // Forward request to service
            $response = $this->forwardRequest($request, $endpoint);
            
            return $this->success($response);
            
        } catch (RouteNotFoundException $e) {
            return $this->notFound($e->getMessage());
        } catch (ServiceNotFoundException $e) {
            return $this->error($e->getMessage(), 503);
        } catch (RateLimitExceededException $e) {
            return $this->error($e->getMessage(), 429);
        } catch (RequestException $e) {
            return $this->handleServiceError($e);
        } catch (\Exception $e) {
            return $this->error('Internal gateway error', 500);
        }
    }
    
    private function forwardRequest(Request $request, $endpoint): array
    {
        // Prepare request options
        $options = [
            'headers' => $this->prepareHeaders($request),
            'timeout' => 30,
            'http_errors' => true
        ];
        
        // Add query parameters
        if ($request->query()) {
            $options['query'] = $request->query();
        }
        
        // Add body for non-GET requests
        if (!in_array($request->method(), ['GET', 'HEAD'])) {
            if ($request->isJson()) {
                $options['json'] = $request->json()->all();
            } else {
                $options['form_params'] = $request->all();
            }
        }
        
        // Make request
        $response = $this->httpClient->request(
            $endpoint->getMethod()->getValue(),
            $endpoint->getUrl(),
            $options
        );
        
        // Parse response
        $body = $response->getBody()->getContents();
        return json_decode($body, true) ?? ['response' => $body];
    }
    
    private function prepareHeaders(Request $request): array
    {
        $headers = $request->headers->all();
        
        // Remove hop-by-hop headers
        $hopByHopHeaders = [
            'connection', 'keep-alive', 'proxy-authenticate',
            'proxy-authorization', 'te', 'trailers',
            'transfer-encoding', 'upgrade'
        ];
        
        foreach ($hopByHopHeaders as $header) {
            unset($headers[$header]);
        }
        
        // Add X-Forwarded headers
        $headers['X-Forwarded-For'] = $request->ip();
        $headers['X-Forwarded-Proto'] = $request->secure() ? 'https' : 'http';
        $headers['X-Forwarded-Host'] = $request->getHost();
        
        // Add user context from JWT
        if ($userId = $request->get('user_id')) {
            $headers['X-User-Id'] = $userId;
        }
        
        return $headers;
    }
    
    private function handleServiceError(RequestException $e): JsonResponse
    {
        if ($response = $e->getResponse()) {
            $statusCode = $response->getStatusCode();
            $body = $response->getBody()->getContents();
            
            try {
                $error = json_decode($body, true);
                return $this->error(
                    $error['message'] ?? 'Service error',
                    $statusCode,
                    $error['errors'] ?? []
                );
            } catch (\Exception $jsonError) {
                return $this->error('Service error', $statusCode);
            }
        }
        
        return $this->error('Service unavailable', 503);
    }
} 