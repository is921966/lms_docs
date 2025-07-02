<?php

namespace Auth\Infrastructure\Repositories;

use Auth\Domain\Repositories\TokenRepositoryInterface;

class InMemoryTokenRepository implements TokenRepositoryInterface
{
    private array $tokens = [];

    public function saveRefreshToken(string $userId, string $token, int $expiresAt): void
    {
        $this->tokens[$token] = [
            'userId' => $userId,
            'expiresAt' => $expiresAt,
            'revoked' => false
        ];
    }

    public function isRefreshTokenValid(string $token): bool
    {
        if (!isset($this->tokens[$token])) {
            return false;
        }

        $tokenData = $this->tokens[$token];

        // Check if revoked
        if ($tokenData['revoked']) {
            return false;
        }

        // Check if expired
        if ($tokenData['expiresAt'] < time()) {
            return false;
        }

        return true;
    }

    public function revokeRefreshToken(string $token): void
    {
        if (isset($this->tokens[$token])) {
            $this->tokens[$token]['revoked'] = true;
        }
    }

    public function revokeAllUserTokens(string $userId): void
    {
        foreach ($this->tokens as $token => &$data) {
            if ($data['userId'] === $userId) {
                $data['revoked'] = true;
            }
        }
    }

    public function getUserIdByRefreshToken(string $token): ?string
    {
        if (!$this->isRefreshTokenValid($token)) {
            return null;
        }

        return $this->tokens[$token]['userId'];
    }

    public function cleanupExpiredTokens(): int
    {
        $count = 0;
        $currentTime = time();

        foreach ($this->tokens as $token => $data) {
            if ($data['expiresAt'] < $currentTime) {
                unset($this->tokens[$token]);
                $count++;
            }
        }

        return $count;
    }
} 