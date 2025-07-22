<?php

namespace App\Controller;

use App\Domain\Entity\User;
use App\Domain\ValueObject\Email;
use App\Security\JWTTokenManager;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\Security\Core\Exception\BadCredentialsException;

#[Route('/api/v1/auth')]
class AuthController extends AbstractController
{
    private JWTTokenManager $tokenManager;
    private EntityManagerInterface $entityManager;
    
    public function __construct(
        JWTTokenManager $tokenManager,
        EntityManagerInterface $entityManager
    ) {
        $this->tokenManager = $tokenManager;
        $this->entityManager = $entityManager;
    }
    
    #[Route('/login', name: 'auth_login', methods: ['POST'])]
    public function login(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true);
        
        if (!isset($data['email']) || !isset($data['password'])) {
            return new JsonResponse([
                'error' => 'Email and password are required'
            ], Response::HTTP_BAD_REQUEST);
        }
        
        try {
            $email = new Email($data['email']);
        } catch (\InvalidArgumentException $e) {
            return new JsonResponse([
                'error' => 'Invalid email format'
            ], Response::HTTP_BAD_REQUEST);
        }
        
        /** @var User|null $user */
        $user = $this->entityManager->getRepository(User::class)
            ->findOneBy(['email' => $email->getValue()]);
        
        if (!$user || !$user->getPassword()->verify($data['password'])) {
            throw new BadCredentialsException('Invalid credentials');
        }
        
        if (!$user->isActive()) {
            return new JsonResponse([
                'error' => 'Account is not active'
            ], Response::HTTP_FORBIDDEN);
        }
        
        $user->recordLogin();
        $this->entityManager->flush();
        
        $accessToken = $this->tokenManager->createToken($user);
        $refreshToken = $this->tokenManager->createRefreshToken($user);
        
        return new JsonResponse([
            'access_token' => $accessToken,
            'refresh_token' => $refreshToken,
            'token_type' => 'Bearer',
            'expires_in' => 3600,
            'user' => [
                'id' => $user->getId()->getValue(),
                'email' => $user->getEmail()->getValue(),
                'roles' => $user->getRoles()
            ]
        ]);
    }
    
    #[Route('/refresh', name: 'auth_refresh', methods: ['POST'])]
    public function refresh(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true);
        
        if (!isset($data['refresh_token'])) {
            return new JsonResponse([
                'error' => 'Refresh token is required'
            ], Response::HTTP_BAD_REQUEST);
        }
        
        try {
            $payload = $this->tokenManager->decode($data['refresh_token']);
            
            if (!isset($payload['type']) || $payload['type'] !== 'refresh') {
                throw new \InvalidArgumentException('Invalid token type');
            }
            
            /** @var User|null $user */
            $user = $this->entityManager->getRepository(User::class)
                ->find($payload['user_id']);
            
            if (!$user || !$user->isActive()) {
                throw new BadCredentialsException('User not found or inactive');
            }
            
            $accessToken = $this->tokenManager->createToken($user);
            
            return new JsonResponse([
                'access_token' => $accessToken,
                'token_type' => 'Bearer',
                'expires_in' => 3600
            ]);
            
        } catch (\Exception $e) {
            return new JsonResponse([
                'error' => 'Invalid refresh token'
            ], Response::HTTP_UNAUTHORIZED);
        }
    }
    
    #[Route('/logout', name: 'auth_logout', methods: ['POST'])]
    public function logout(): JsonResponse
    {
        // In JWT-based auth, logout is typically handled client-side
        // by removing the token. We can add token blacklisting here if needed.
        
        return new JsonResponse([
            'message' => 'Successfully logged out'
        ]);
    }
    
    #[Route('/me', name: 'auth_me', methods: ['GET'])]
    public function me(): JsonResponse
    {
        /** @var User $user */
        $user = $this->getUser();
        
        return new JsonResponse([
            'id' => $user->getId()->getValue(),
            'email' => $user->getEmail()->getValue(),
            'roles' => $user->getRoles(),
            'created_at' => $user->getCreatedAt()->format('c'),
            'last_login_at' => $user->getLastLoginAt()?->format('c')
        ]);
    }
} 