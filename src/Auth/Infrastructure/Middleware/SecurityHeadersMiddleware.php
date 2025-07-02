<?php

namespace Auth\Infrastructure\Middleware;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\HttpKernelInterface;

class SecurityHeadersMiddleware implements HttpKernelInterface
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
        // Get response from next middleware
        $response = $this->kernel->handle($request, $type, $catch);

        // Add security headers
        $this->addSecurityHeaders($response);

        return $response;
    }

    private function addSecurityHeaders(Response $response): void
    {
        // Prevent MIME type sniffing
        $response->headers->set('X-Content-Type-Options', 'nosniff');

        // Clickjacking protection
        $response->headers->set('X-Frame-Options', $this->config['frame-options']);

        // XSS protection (legacy browsers)
        $response->headers->set('X-XSS-Protection', '1; mode=block');

        // Referrer policy
        $response->headers->set('Referrer-Policy', $this->config['referrer-policy']);

        // Content Security Policy
        $response->headers->set('Content-Security-Policy', $this->buildCSP());

        // Strict Transport Security (HTTPS only)
        $response->headers->set('Strict-Transport-Security', $this->config['hsts']);

        // Permissions Policy (formerly Feature Policy)
        $response->headers->set('Permissions-Policy', $this->buildPermissionsPolicy());

        // Remove server identification headers
        $response->headers->remove('Server');
        $response->headers->remove('X-Powered-By');
    }

    private function buildCSP(): string
    {
        $directives = [];
        foreach ($this->config['csp'] as $directive => $value) {
            $directives[] = "$directive $value";
        }
        return implode('; ', $directives);
    }

    private function buildPermissionsPolicy(): string
    {
        $policies = [];
        foreach ($this->config['permissions-policy'] as $feature => $allowlist) {
            $policies[] = "$feature=$allowlist";
        }
        return implode(', ', $policies);
    }

    private function getDefaultConfig(): array
    {
        return [
            'frame-options' => 'DENY',
            'referrer-policy' => 'no-referrer-when-downgrade',
            'hsts' => 'max-age=31536000; includeSubDomains',
            'csp' => [
                'default-src' => "'self'",
                'script-src' => "'self' 'unsafe-inline'",
                'style-src' => "'self' 'unsafe-inline'",
                'img-src' => "'self' data: https:",
                'font-src' => "'self'",
                'connect-src' => "'self'",
                'media-src' => "'self'",
                'object-src' => "'none'",
                'frame-ancestors' => "'none'",
                'base-uri' => "'self'",
                'form-action' => "'self'"
            ],
            'permissions-policy' => [
                'geolocation' => '()',
                'microphone' => '()',
                'camera' => '()',
                'payment' => '()',
                'usb' => '()',
                'magnetometer' => '()',
                'accelerometer' => '()',
                'gyroscope' => '()'
            ]
        ];
    }
} 