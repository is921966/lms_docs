<?php

declare(strict_types=1);

namespace Competency\Http\Middleware;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\JsonResponse;

class CompetencyAuthorizationMiddleware
{
    private array $protectedRoutes = [
        'POST' => ['create_competency', 'assess_competency'],
        'PUT' => ['update_competency'],
        'DELETE' => ['delete_competency']
    ];

    public function handle(Request $request, callable $next): Response
    {
        $method = $request->getMethod();
        $route = $request->attributes->get('_route');

        // Check if route requires authorization
        if ($this->requiresAuthorization($method, $route)) {
            // Check user permissions
            $user = $request->attributes->get('user');
            
            if (!$user) {
                return new JsonResponse([
                    'error' => 'Unauthorized'
                ], Response::HTTP_UNAUTHORIZED);
            }

            // Check specific permissions
            if (!$this->hasPermission($user, $method, $route)) {
                return new JsonResponse([
                    'error' => 'Forbidden'
                ], Response::HTTP_FORBIDDEN);
            }
        }

        return $next($request);
    }

    private function requiresAuthorization(string $method, ?string $route): bool
    {
        if (!$route) {
            return false;
        }

        return isset($this->protectedRoutes[$method]) && 
               in_array($route, $this->protectedRoutes[$method]);
    }

    private function hasPermission($user, string $method, string $route): bool
    {
        // Simple role-based check
        $requiredRoles = [
            'create_competency' => ['admin', 'hr_manager'],
            'update_competency' => ['admin', 'hr_manager'],
            'delete_competency' => ['admin'],
            'assess_competency' => ['admin', 'hr_manager', 'manager']
        ];

        if (!isset($requiredRoles[$route])) {
            return true;
        }

        $userRole = $user->role ?? 'user';
        return in_array($userRole, $requiredRoles[$route]);
    }
}
