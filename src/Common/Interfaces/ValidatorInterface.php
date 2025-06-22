<?php

declare(strict_types=1);

namespace App\Common\Interfaces;

/**
 * Interface for data validators
 */
interface ValidatorInterface
{
    /**
     * Validate data against rules
     * 
     * @param array<string, mixed> $data
     * @param array<string, mixed> $rules
     * @return bool
     */
    public function validate(array $data, array $rules): bool;
    
    /**
     * Get validation errors
     * 
     * @return array<string, array<string>>
     */
    public function getErrors(): array;
    
    /**
     * Check if validation has errors
     * 
     * @return bool
     */
    public function hasErrors(): bool;
    
    /**
     * Add custom validation rule
     * 
     * @param string $name
     * @param callable $callback
     * @return void
     */
    public function addRule(string $name, callable $callback): void;
} 