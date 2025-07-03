<?php

declare(strict_types=1);

namespace ApiGateway\Http\Controllers;

use ApiGateway\Domain\Services\JwtServiceInterface;
use ApiGateway\Domain\Exceptions\InvalidTokenException;
use Common\Http\BaseController;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use GuzzleHttp\Client;
use User\Domain\ValueObjects\UserId;

class AuthController extends BaseController
{
    private JwtServiceInterface $jwtService;
    private Client $httpClient;
    private string $authServiceUrl;
    
    public function __construct(
        JwtServiceInterface $jwtService,
        Client $httpClient,
        string $authServiceUrl = 'http://auth-service:8081'
    ) {
        $this->jwtService = $jwtService;
        $this->httpClient = $httpClient;
        $this->authServiceUrl = $authServiceUrl;
    }
    
    public function login(Request $request): JsonResponse
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string'
        ]);
        
        try {
            // Forward to auth service
            $response = $this->httpClient->post($this->authServiceUrl . '/login', [
                'json' => [
                    'email' => $request->input('email'),
                    'password' => $request->input('password')
                ],
                'http_errors' => false
            ]);
            
            $statusCode = $response->getStatusCode();
            $body = json_decode($response->getBody()->getContents(), true);
            
            if ($statusCode !== 200) {
                return $this->error(
                    $body['message'] ?? 'Authentication failed',
                    $statusCode
                );
            }
            
            // Generate JWT token
            $userId = UserId::fromString($body['user']['id']);
            $token = $this->jwtService->generateToken($userId, [
                'email' => $body['user']['email'],
                'role' => $body['user']['role'] ?? 'user'
            ]);
            
            return $this->success([
                'user' => $body['user'],
                'token' => [
                    'access_token' => $token->getAccessToken(),
                    'refresh_token' => $token->getRefreshToken(),
                    'token_type' => 'Bearer',
                    'expires_in' => $token->getExpiresIn()
                ]
            ]);
            
        } catch (\Exception $e) {
            return $this->error('Authentication service unavailable', 503);
        }
    }
    
    public function logout(Request $request): JsonResponse
    {
        try {
            // Get token from header
            $token = $request->bearerToken();
            
            if ($token) {
                // Blacklist the token
                $this->jwtService->blacklistToken($token);
            }
            
            return $this->success(['message' => 'Successfully logged out']);
            
        } catch (\Exception $e) {
            return $this->error('Logout failed', 500);
        }
    }
    
    public function refresh(Request $request): JsonResponse
    {
        $request->validate([
            'refresh_token' => 'required|string'
        ]);
        
        try {
            $refreshToken = $request->input('refresh_token');
            $newToken = $this->jwtService->refreshToken($refreshToken);
            
            return $this->success([
                'token' => [
                    'access_token' => $newToken->getAccessToken(),
                    'refresh_token' => $newToken->getRefreshToken(),
                    'token_type' => 'Bearer',
                    'expires_in' => $newToken->getExpiresIn()
                ]
            ]);
            
        } catch (InvalidTokenException $e) {
            return $this->unauthorized($e->getMessage());
        } catch (\Exception $e) {
            return $this->error('Token refresh failed', 500);
        }
    }
    
    public function me(Request $request): JsonResponse
    {
        try {
            $userId = $request->get('user_id'); // Set by auth middleware
            
            // Get user details from user service
            $response = $this->httpClient->get("http://user-service:8080/users/{$userId}", [
                'headers' => [
                    'X-User-Id' => $userId
                ],
                'http_errors' => false
            ]);
            
            if ($response->getStatusCode() !== 200) {
                return $this->notFound('User not found');
            }
            
            $user = json_decode($response->getBody()->getContents(), true);
            
            return $this->success(['user' => $user]);
            
        } catch (\Exception $e) {
            return $this->error('Failed to fetch user details', 500);
        }
    }
} 