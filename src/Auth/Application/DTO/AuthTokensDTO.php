<?php

namespace Auth\Application\DTO;

class AuthTokensDTO
{
    public string $accessToken;
    public string $refreshToken;
    public string $tokenType;
    public int $expiresIn;

    public function __construct(
        string $accessToken,
        string $refreshToken,
        string $tokenType = 'Bearer',
        int $expiresIn = 900
    ) {
        $this->accessToken = $accessToken;
        $this->refreshToken = $refreshToken;
        $this->tokenType = $tokenType;
        $this->expiresIn = $expiresIn;
    }

    public function toArray(): array
    {
        return [
            'access_token' => $this->accessToken,
            'refresh_token' => $this->refreshToken,
            'token_type' => $this->tokenType,
            'expires_in' => $this->expiresIn
        ];
    }
} 