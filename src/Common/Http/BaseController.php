<?php

declare(strict_types=1);

namespace Common\Http;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;

/**
 * Base controller with common functionality
 */
abstract class BaseController
{
    /**
     * Get validated data from request
     */
    protected function getValidatedData(ServerRequestInterface $request): array
    {
        $contentType = $request->getHeaderLine('Content-Type');
        
        if (strpos($contentType, 'application/json') !== false) {
            return json_decode((string) $request->getBody(), true) ?? [];
        }
        
        return $request->getParsedBody() ?? [];
    }
    
    /**
     * Get query parameters
     */
    protected function getQueryParams(ServerRequestInterface $request): array
    {
        return $request->getQueryParams();
    }
    
    /**
     * Get route parameter
     */
    protected function getRouteParam(ServerRequestInterface $request, string $name): ?string
    {
        $routeParams = $request->getAttribute('routeParams', []);
        return $routeParams[$name] ?? null;
    }
    
    /**
     * Create JSON response
     */
    protected function json(ResponseInterface $response, mixed $data, int $status = 200): ResponseInterface
    {
        $response->getBody()->write(json_encode($data));
        
        return $response
            ->withStatus($status)
            ->withHeader('Content-Type', 'application/json');
    }
    
    /**
     * Create success response
     */
    protected function success(ResponseInterface $response, mixed $data = null, string $message = 'Success', int $status = 200): ResponseInterface
    {
        return $this->json($response, [
            'success' => true,
            'message' => $message,
            'data' => $data
        ], $status);
    }
    
    /**
     * Create error response
     */
    protected function error(ResponseInterface $response, string $message, array $errors = [], int $status = 400): ResponseInterface
    {
        return $this->json($response, [
            'success' => false,
            'message' => $message,
            'errors' => $errors
        ], $status);
    }
    
    /**
     * Create paginated response
     */
    protected function paginated(ResponseInterface $response, array $items, int $total, int $page, int $perPage): ResponseInterface
    {
        return $this->json($response, [
            'success' => true,
            'data' => $items,
            'meta' => [
                'total' => $total,
                'page' => $page,
                'per_page' => $perPage,
                'last_page' => (int) ceil($total / $perPage)
            ]
        ]);
    }
    
    /**
     * Get pagination parameters from request
     */
    protected function getPaginationParams(ServerRequestInterface $request): array
    {
        $queryParams = $this->getQueryParams($request);
        
        return [
            'page' => max(1, (int) ($queryParams['page'] ?? 1)),
            'per_page' => min(100, max(1, (int) ($queryParams['per_page'] ?? 20))),
            'sort_by' => $queryParams['sort_by'] ?? null,
            'sort_order' => strtoupper($queryParams['sort_order'] ?? 'ASC')
        ];
    }
    
    /**
     * Get authenticated user from request
     */
    protected function getAuthUser(ServerRequestInterface $request): ?object
    {
        return $request->getAttribute('auth_user');
    }
    
    /**
     * Check if user has permission
     */
    protected function hasPermission(ServerRequestInterface $request, string $permission): bool
    {
        $user = $this->getAuthUser($request);
        
        if (!$user) {
            return false;
        }
        
        return method_exists($user, 'hasPermission') && $user->hasPermission($permission);
    }
    
    /**
     * Require permission or throw
     */
    protected function requirePermission(ServerRequestInterface $request, string $permission): void
    {
        if (!$this->hasPermission($request, $permission)) {
            throw new \App\Common\Exceptions\AuthorizationException(
                'You do not have permission to perform this action'
            );
        }
    }
} 