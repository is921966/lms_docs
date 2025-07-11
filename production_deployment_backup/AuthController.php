<?php

namespace Auth\Http\Controllers;

use Auth\Application\Service\AuthService;
use Auth\Application\DTO\LoginRequest;
use Common\Http\JsonResponseTrait;
use Common\Exceptions\ValidationException;
use Common\Exceptions\UnauthorizedException;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Annotation\Route;

#[Route('/api/v1/auth')]
class AuthController
{
    use JsonResponseTrait;
    
    private AuthService $authService;
    
    public function __construct(AuthService $authService)
    {
        $this->authService = $authService;
    }
    
    #[Route('/login', methods: ['POST'])]
    public function login(Request $request): JsonResponse
    {
        try {
            $data = json_decode($request->getContent(), true);
            
            if (!isset($data['email']) || !isset($data['password'])) {
                throw new ValidationException('Email and password are required');
            }
            
            $loginRequest = new LoginRequest(
                email: $data['email'],
                password: $data['password']
            );
            
            $response = $this->authService->login($loginRequest);
            
            return $this->success([
                'accessToken' => $response->getAccessToken(),
                'refreshToken' => $response->getRefreshToken(),
                'expiresIn' => $response->getExpiresIn(),
                'user' => [
                    'id' => $response->getUser()->getId()->getValue(),
                    'email' => $response->getUser()->getEmail()->getValue(),
                    'name' => $response->getUser()->getFullName(),
                    'firstName' => $response->getUser()->getFirstName(),
                    'lastName' => $response->getUser()->getLastName(),
                    'role' => $response->getUser()->isAdmin() ? 'admin' : 'student',
                    'isActive' => $response->getUser()->isActive(),
                    'department' => $response->getUser()->getDepartment(),
                    'createdAt' => $response->getUser()->getCreatedAt()->format('c'),
                    'updatedAt' => $response->getUser()->getUpdatedAt()->format('c'),
                ]
            ]);
        } catch (UnauthorizedException $e) {
            return $this->error('Invalid credentials', 401);
        } catch (ValidationException $e) {
            return $this->error($e->getMessage(), 400);
        } catch (\Exception $e) {
            return $this->error('An error occurred during login', 500);
        }
    }
    
    #[Route('/logout', methods: ['POST'])]
    public function logout(Request $request): JsonResponse
    {
        try {
            $token = $this->extractToken($request);
            if ($token) {
                $this->authService->logout($token);
            }
            
            return $this->success(['message' => 'Logged out successfully']);
        } catch (\Exception $e) {
            return $this->error('An error occurred during logout', 500);
        }
    }
    
    #[Route('/refresh', methods: ['POST'])]
    public function refresh(Request $request): JsonResponse
    {
        try {
            $data = json_decode($request->getContent(), true);
            
            if (!isset($data['refreshToken'])) {
                throw new ValidationException('Refresh token is required');
            }
            
            $response = $this->authService->refreshToken($data['refreshToken']);
            
            return $this->success([
                'accessToken' => $response->getAccessToken(),
                'refreshToken' => $response->getRefreshToken(),
                'expiresIn' => $response->getExpiresIn(),
            ]);
        } catch (UnauthorizedException $e) {
            return $this->error('Invalid refresh token', 401);
        } catch (ValidationException $e) {
            return $this->error($e->getMessage(), 400);
        } catch (\Exception $e) {
            return $this->error('An error occurred during token refresh', 500);
        }
    }
    
    #[Route('/me', methods: ['GET'])]
    public function me(Request $request): JsonResponse
    {
        try {
            $token = $this->extractToken($request);
            if (!$token) {
                throw new UnauthorizedException('No token provided');
            }
            
            $user = $this->authService->getCurrentUser($token);
            
            return $this->success([
                'id' => $user->getId()->getValue(),
                'email' => $user->getEmail()->getValue(),
                'name' => $user->getFullName(),
                'firstName' => $user->getFirstName(),
                'lastName' => $user->getLastName(),
                'role' => $user->isAdmin() ? 'admin' : 'student',
                'isActive' => $user->isActive(),
                'department' => $user->getDepartment(),
                'avatarURL' => $user->getAvatar(),
                'createdAt' => $user->getCreatedAt()->format('c'),
                'updatedAt' => $user->getUpdatedAt()->format('c'),
            ]);
        } catch (UnauthorizedException $e) {
            return $this->error('Unauthorized', 401);
        } catch (\Exception $e) {
            return $this->error('An error occurred while fetching user data', 500);
        }
    }
    
    #[Route('/health', methods: ['GET'])]
    public function health(): JsonResponse
    {
        return $this->success([
            'status' => 'ok',
            'service' => 'auth',
            'timestamp' => date('c'),
        ]);
    }
    
    /**
     * Extract token from Authorization header
     */
    private function extractToken(Request $request): ?string
    {
        $authHeader = $request->headers->get('Authorization');
        if (!$authHeader || !str_starts_with($authHeader, 'Bearer ')) {
            return null;
        }
        
        return substr($authHeader, 7);
    }
} 