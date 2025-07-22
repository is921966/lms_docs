<?php

declare(strict_types=1);

namespace App\OrgStructure\Application\Exceptions;

use Exception;

final class ImportException extends Exception
{
    private array $context = [];

    public static function invalidFormat(string $message, array $context = []): self
    {
        $exception = new self("Invalid CSV format: $message");
        $exception->context = $context;
        return $exception;
    }

    public static function validationFailed(string $message, array $context = []): self
    {
        $exception = new self("Validation failed: $message");
        $exception->context = $context;
        return $exception;
    }

    public static function databaseError(string $message, array $context = []): self
    {
        $exception = new self("Database error: $message");
        $exception->context = $context;
        return $exception;
    }

    public function getContext(): array
    {
        return $this->context;
    }
} 