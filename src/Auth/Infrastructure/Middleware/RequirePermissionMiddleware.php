<?php

namespace Auth\Infrastructure\Middleware;

use Auth\Domain\Services\PermissionService;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpKernel\HttpKernelInterface;

class RequirePermissionMiddleware implements HttpKernelInterface
{
    private HttpKernelInterface $kernel;
    private PermissionService $permissionService;
    private string $requiredPermission;

    public function __construct(
        HttpKernelInterface $kernel,
        PermissionService $permissionService,
        string $requiredPermission
    ) {
        $this->kernel = $kernel;
        $this->permissionService = $permissionService;
        $this->requiredPermission = $requiredPermission;
    }

    public function handle(Request $request, int $type = self::MAIN_REQUEST, bool $catch = true): Response
    {
        // Get user ID from request (set by AuthenticationMiddleware)
        $userId = $request->attributes->get('userId');

        if (!$userId) {
            return $this->forbiddenResponse('User not authenticated');
        }

        // Check permission
        if (!$this->permissionService->userHasPermission($userId, $this->requiredPermission)) {
            return $this->forbiddenResponse(
                sprintf('Missing required permission: %s', $this->requiredPermission)
            );
        }

        // Continue to next middleware
        return $this->kernel->handle($request, $type, $catch);
    }

    private function forbiddenResponse(string $message): JsonResponse
    {
        return new JsonResponse([
            'error' => 'Forbidden',
            'message' => $message
        ], 403);
    }
} 