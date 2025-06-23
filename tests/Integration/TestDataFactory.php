<?php

declare(strict_types=1);

namespace Tests\Integration;

use Ramsey\Uuid\Uuid;

class TestDataFactory
{
    /**
     * Генерирует валидный UUID v4
     */
    public static function validUuid(): string
    {
        return Uuid::uuid4()->toString();
    }
    
    /**
     * Генерирует невалидный UUID для тестирования негативных сценариев
     * Но который проходит базовую валидацию формата UUID
     */
    public static function nonExistentUuid(): string
    {
        // Генерируем UUID, которого точно нет в системе
        return '00000000-0000-0000-0000-000000000000';
    }
    
    /**
     * Генерирует валидный код должности
     */
    public static function validPositionCode(): string
    {
        $prefix = ['IT', 'HR', 'FIN', 'MGR', 'DEV', 'ADM'];
        $number = str_pad((string)rand(1, 999), 3, '0', STR_PAD_LEFT);
        return $prefix[array_rand($prefix)] . '-' . $number;
    }
    
    /**
     * Генерирует валидный email
     */
    public static function validEmail(): string
    {
        $names = ['test', 'user', 'admin', 'employee', 'manager'];
        $domains = ['example.com', 'test.com', 'company.com'];
        return $names[array_rand($names)] . rand(1, 9999) . '@' . $domains[array_rand($domains)];
    }
    
    /**
     * Генерирует валидный пароль
     */
    public static function validPassword(): string
    {
        return 'Test@123' . rand(1000, 9999);
    }
} 