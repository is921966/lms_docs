<?php

declare(strict_types=1);

namespace App\Common\Interfaces;

/**
 * Cache interface
 */
interface CacheInterface
{
    /**
     * Get item from cache
     */
    public function get(string $key): mixed;
    
    /**
     * Check if item exists
     */
    public function has(string $key): bool;
    
    /**
     * Set item in cache
     */
    public function set(string $key, mixed $value, ?int $ttl = null): bool;
    
    /**
     * Delete item from cache
     */
    public function delete(string $key): bool;
    
    /**
     * Clear all cache
     */
    public function clear(): bool;
} 