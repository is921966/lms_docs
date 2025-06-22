<?php

declare(strict_types=1);

namespace App\Common\Interfaces;

/**
 * Base service interface for business logic layer
 */
interface ServiceInterface
{
    /**
     * Validate data before processing
     * 
     * @param array<string, mixed> $data
     * @return bool
     * @throws \App\Common\Exceptions\ValidationException
     */
    public function validate(array $data): bool;
    
    /**
     * Begin database transaction
     * 
     * @return void
     */
    public function beginTransaction(): void;
    
    /**
     * Commit database transaction
     * 
     * @return void
     */
    public function commit(): void;
    
    /**
     * Rollback database transaction
     * 
     * @return void
     */
    public function rollback(): void;
} 