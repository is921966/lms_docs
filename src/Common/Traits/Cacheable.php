<?php

declare(strict_types=1);

namespace Common\Traits;

use Psr\Cache\CacheItemPoolInterface;

/**
 * Trait for adding caching capabilities to services
 */
trait Cacheable
{
    protected ?CacheItemPoolInterface $cache = null;
    protected int $defaultTtl = 3600; // 1 hour
    
    /**
     * Set cache pool
     */
    public function setCache(CacheItemPoolInterface $cache): void
    {
        $this->cache = $cache;
    }
    
    /**
     * Get cached value or execute callback
     * 
     * @param string $key
     * @param callable $callback
     * @param int|null $ttl
     * @return mixed
     */
    protected function remember(string $key, callable $callback, ?int $ttl = null): mixed
    {
        if ($this->cache === null) {
            return $callback();
        }
        
        $item = $this->cache->getItem($this->sanitizeCacheKey($key));
        
        if (!$item->isHit()) {
            $value = $callback();
            $item->set($value);
            $item->expiresAfter($ttl ?? $this->defaultTtl);
            $this->cache->save($item);
            
            return $value;
        }
        
        return $item->get();
    }
    
    /**
     * Clear cache by key
     */
    protected function forget(string $key): void
    {
        if ($this->cache !== null) {
            $this->cache->deleteItem($this->sanitizeCacheKey($key));
        }
    }
    
    /**
     * Clear cache by tags
     */
    protected function flush(array $tags = []): void
    {
        if ($this->cache !== null && method_exists($this->cache, 'invalidateTags')) {
            $this->cache->invalidateTags($tags);
        }
    }
    
    /**
     * Sanitize cache key
     */
    private function sanitizeCacheKey(string $key): string
    {
        return preg_replace('/[^A-Za-z0-9_.-]/', '_', $key) ?? $key;
    }
} 