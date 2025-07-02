<?php

namespace Auth\Infrastructure\Middleware;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\HttpKernelInterface;

class CorsMiddleware implements HttpKernelInterface
{
    private HttpKernelInterface $kernel;
    private array $config;

    public function __construct(HttpKernelInterface $kernel, array $config = [])
    {
        $this->kernel = $kernel;
        $this->config = array_merge($this->getDefaultConfig(), $config);
    }

    public function handle(Request $request, int $type = self::MAIN_REQUEST, bool $catch = true): Response
    {
        // Handle preflight requests
        if ($this->isPreflightRequest($request)) {
            return $this->handlePreflight($request);
        }

        // Get response from next middleware
        $response = $this->kernel->handle($request, $type, $catch);

        // Add CORS headers to cross-origin requests
        if ($this->isCrossOriginRequest($request)) {
            $this->addCorsHeaders($request, $response);
        }

        return $response;
    }

    private function isPreflightRequest(Request $request): bool
    {
        return $request->getMethod() === 'OPTIONS' &&
               $request->headers->has('Origin') &&
               $request->headers->has('Access-Control-Request-Method');
    }

    private function isCrossOriginRequest(Request $request): bool
    {
        return $request->headers->has('Origin');
    }

    private function handlePreflight(Request $request): Response
    {
        $response = new Response('', 204);
        $this->addCorsHeaders($request, $response);

        // Add preflight-specific headers
        $response->headers->set(
            'Access-Control-Allow-Methods',
            implode(', ', $this->config['allowed_methods'])
        );

        if ($request->headers->has('Access-Control-Request-Headers')) {
            $response->headers->set(
                'Access-Control-Allow-Headers',
                $request->headers->get('Access-Control-Request-Headers')
            );
        }

        $response->headers->set(
            'Access-Control-Max-Age',
            (string) $this->config['max_age']
        );

        return $response;
    }

    private function addCorsHeaders(Request $request, Response $response): void
    {
        $origin = $request->headers->get('Origin');

        // Check if origin is allowed
        if (!$this->isOriginAllowed($origin)) {
            return;
        }

        // Set allowed origin
        if (in_array('*', $this->config['allowed_origins'])) {
            $response->headers->set('Access-Control-Allow-Origin', '*');
        } else {
            $response->headers->set('Access-Control-Allow-Origin', $origin);
        }

        // Set credentials flag
        if ($this->config['allow_credentials'] && !in_array('*', $this->config['allowed_origins'])) {
            $response->headers->set('Access-Control-Allow-Credentials', 'true');
        }

        // Expose headers
        if (!empty($this->config['exposed_headers'])) {
            $response->headers->set(
                'Access-Control-Expose-Headers',
                implode(', ', $this->config['exposed_headers'])
            );
        }
    }

    private function isOriginAllowed(string $origin): bool
    {
        if (in_array('*', $this->config['allowed_origins'])) {
            return true;
        }

        return in_array($origin, $this->config['allowed_origins']);
    }

    private function getDefaultConfig(): array
    {
        return [
            'allowed_origins' => ['*'],
            'allowed_methods' => ['POST', 'GET', 'PUT', 'DELETE', 'OPTIONS'],
            'allowed_headers' => ['Content-Type', 'Authorization', 'X-Requested-With'],
            'exposed_headers' => ['X-Total-Count'],
            'allow_credentials' => true,
            'max_age' => 86400 // 24 hours
        ];
    }
} 