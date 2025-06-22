<?php

namespace Tests\Stubs;

use Psr\Cache\CacheItemInterface;
use Psr\Cache\CacheItemPoolInterface;

/**
 * Simple cache adapter stub for testing
 */
class CacheAdapterStub implements CacheItemPoolInterface
{
    private array $items = [];
    private array $deferred = [];
    
    public function getItem(string $key): CacheItemInterface
    {
        if (!isset($this->items[$key])) {
            $this->items[$key] = new CacheItemStub($key);
        }
        return $this->items[$key];
    }
    
    public function getItems(array $keys = []): iterable
    {
        $items = [];
        foreach ($keys as $key) {
            $items[$key] = $this->getItem($key);
        }
        return $items;
    }
    
    public function hasItem(string $key): bool
    {
        return isset($this->items[$key]) && $this->items[$key]->isHit();
    }
    
    public function clear(): bool
    {
        $this->items = [];
        $this->deferred = [];
        return true;
    }
    
    public function deleteItem(string $key): bool
    {
        unset($this->items[$key]);
        unset($this->deferred[$key]);
        return true;
    }
    
    public function deleteItems(array $keys): bool
    {
        foreach ($keys as $key) {
            $this->deleteItem($key);
        }
        return true;
    }
    
    public function save(CacheItemInterface $item): bool
    {
        $this->items[$item->getKey()] = $item;
        return true;
    }
    
    public function saveDeferred(CacheItemInterface $item): bool
    {
        $this->deferred[$item->getKey()] = $item;
        return true;
    }
    
    public function commit(): bool
    {
        foreach ($this->deferred as $item) {
            $this->save($item);
        }
        $this->deferred = [];
        return true;
    }
}

/**
 * Cache item stub
 */
class CacheItemStub implements CacheItemInterface
{
    private string $key;
    private mixed $value = null;
    private bool $isHit = false;
    private ?\DateTimeInterface $expiry = null;
    
    public function __construct(string $key)
    {
        $this->key = $key;
    }
    
    public function getKey(): string
    {
        return $this->key;
    }
    
    public function get(): mixed
    {
        return $this->isHit ? $this->value : null;
    }
    
    public function isHit(): bool
    {
        if ($this->expiry && $this->expiry < new \DateTime()) {
            $this->isHit = false;
        }
        return $this->isHit;
    }
    
    public function set(mixed $value): static
    {
        $this->value = $value;
        $this->isHit = true;
        return $this;
    }
    
    public function expiresAt(?\DateTimeInterface $expiration): static
    {
        $this->expiry = $expiration;
        return $this;
    }
    
    public function expiresAfter(\DateInterval|int|null $time): static
    {
        if ($time === null) {
            $this->expiry = null;
        } elseif ($time instanceof \DateInterval) {
            $this->expiry = (new \DateTime())->add($time);
        } else {
            $this->expiry = (new \DateTime())->modify("+{$time} seconds");
        }
        return $this;
    }
} 