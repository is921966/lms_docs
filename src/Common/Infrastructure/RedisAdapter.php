<?php

declare(strict_types=1);

namespace App\Common\Infrastructure;

use Symfony\Component\Cache\Adapter\AbstractAdapter;
use Symfony\Component\Cache\CacheItem;
use Psr\Cache\CacheItemInterface;

/**
 * Redis adapter that can work with Redis or in-memory storage
 */
class RedisAdapter extends AbstractAdapter
{
    private array $cache = [];
    private array $deferred = [];
    private ?\Redis $redis;
    
    public function __construct(?\Redis $redis = null, string $namespace = '', int $defaultLifetime = 0)
    {
        $this->redis = $redis;
        parent::__construct($namespace, $defaultLifetime);
    }
    
    protected function doFetch(array $ids): iterable
    {
        if ($this->redis) {
            $values = [];
            foreach ($ids as $id) {
                $value = $this->redis->get($id);
                if ($value !== false) {
                    $values[$id] = unserialize($value);
                }
            }
            return $values;
        }
        
        $values = [];
        foreach ($ids as $id) {
            if (isset($this->cache[$id])) {
                $item = $this->cache[$id];
                if (!$item['expiry'] || $item['expiry'] > time()) {
                    $values[$id] = $item['value'];
                } else {
                    unset($this->cache[$id]);
                }
            }
        }
        return $values;
    }
    
    protected function doHave(string $id): bool
    {
        if ($this->redis) {
            return $this->redis->exists($id) > 0;
        }
        
        if (!isset($this->cache[$id])) {
            return false;
        }
        
        $item = $this->cache[$id];
        if ($item['expiry'] && $item['expiry'] <= time()) {
            unset($this->cache[$id]);
            return false;
        }
        
        return true;
    }
    
    protected function doClear(string $namespace): bool
    {
        if ($this->redis) {
            // In real implementation, would use SCAN to find keys with namespace
            return true;
        }
        
        $this->cache = [];
        return true;
    }
    
    protected function doDelete(array $ids): bool
    {
        if ($this->redis) {
            return $this->redis->del(...$ids) > 0;
        }
        
        foreach ($ids as $id) {
            unset($this->cache[$id]);
        }
        return true;
    }
    
    protected function doSave(array $values, int $lifetime): array|bool
    {
        if ($this->redis) {
            $failed = [];
            foreach ($values as $id => $value) {
                $serialized = serialize($value);
                if ($lifetime > 0) {
                    if (!$this->redis->setex($id, $lifetime, $serialized)) {
                        $failed[] = $id;
                    }
                } else {
                    if (!$this->redis->set($id, $serialized)) {
                        $failed[] = $id;
                    }
                }
            }
            return $failed;
        }
        
        $expiry = $lifetime > 0 ? time() + $lifetime : null;
        foreach ($values as $id => $value) {
            $this->cache[$id] = [
                'value' => $value,
                'expiry' => $expiry
            ];
        }
        return [];
    }
} 