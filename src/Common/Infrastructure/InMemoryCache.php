<?php

declare(strict_types=1);

namespace App\Common\Infrastructure;

use App\Common\Interfaces\CacheInterface;

/**
 * In-memory cache implementation
 */
class InMemoryCache implements CacheInterface
{
    private array $data = [];
    private array $expiry = [];
    
    /**
     * Get item from cache
     */
    public function get(string $key): mixed
    {
        if (!$this->has($key)) {
            return null;
        }
        
        return $this->data[$key];
    }
    
    /**
     * Check if item exists
     */
    public function has(string $key): bool
    {
        if (!isset($this->data[$key])) {
            return false;
        }
        
        // Check expiry
        if (isset($this->expiry[$key]) && $this->expiry[$key] < time()) {
            unset($this->data[$key]);
            unset($this->expiry[$key]);
            return false;
        }
        
        return true;
    }
    
    /**
     * Set item in cache
     */
    public function set(string $key, mixed $value, ?int $ttl = null): bool
    {
        $this->data[$key] = $value;
        
        if ($ttl !== null) {
            $this->expiry[$key] = time() + $ttl;
        }
        
        return true;
    }
    
    /**
     * Delete item from cache
     */
    public function delete(string $key): bool
    {
        unset($this->data[$key]);
        unset($this->expiry[$key]);
        return true;
    }
    
    /**
     * Clear all cache
     */
    public function clear(): bool
    {
        $this->data = [];
        $this->expiry = [];
        return true;
    }
} 