<?php

namespace Auth\Application\Commands;

class RefreshTokenCommand
{
    private string $refreshToken;

    public function __construct(string $refreshToken)
    {
        $this->refreshToken = $refreshToken;
    }

    public function getRefreshToken(): string
    {
        return $this->refreshToken;
    }
} 