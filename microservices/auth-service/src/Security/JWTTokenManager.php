<?php

namespace App\Security;

use App\Entity\User;
use Lexik\Bundle\JWTAuthenticationBundle\Services\JWTTokenManagerInterface;
use Symfony\Component\Security\Core\User\UserInterface;

class JWTTokenManager
{
    private JWTTokenManagerInterface $jwtManager;
    
    public function __construct(JWTTokenManagerInterface $jwtManager)
    {
        $this->jwtManager = $jwtManager;
    }
    
    public function createToken(UserInterface $user): string
    {
        $payload = [
            'user_id' => $user->getId(),
            'email' => $user->getEmail(),
            'roles' => $user->getRoles(),
            'iat' => time(),
            'exp' => time() + 3600, // 1 hour
        ];
        
        return $this->jwtManager->createFromPayload($user, $payload);
    }
    
    public function createRefreshToken(UserInterface $user): string
    {
        $payload = [
            'user_id' => $user->getId(),
            'type' => 'refresh',
            'iat' => time(),
            'exp' => time() + 2592000, // 30 days
        ];
        
        return $this->jwtManager->createFromPayload($user, $payload);
    }
    
    public function decode(string $token): array
    {
        return $this->jwtManager->parse($token);
    }
} 