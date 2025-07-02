<?php

namespace Auth\Domain\Repositories;

interface TokenRepositoryInterface
{
    /**
     * Сохранить refresh token для пользователя
     */
    public function saveRefreshToken(string $userId, string $token, int $expiresAt): void;

    /**
     * Проверить, существует ли refresh token
     */
    public function isRefreshTokenValid(string $token): bool;

    /**
     * Отозвать refresh token
     */
    public function revokeRefreshToken(string $token): void;

    /**
     * Отозвать все refresh tokens пользователя
     */
    public function revokeAllUserTokens(string $userId): void;

    /**
     * Получить user ID по refresh token
     */
    public function getUserIdByRefreshToken(string $token): ?string;

    /**
     * Очистить истекшие токены
     */
    public function cleanupExpiredTokens(): int;
} 