<?php

namespace Tests\Stubs;

/**
 * Simple Redis stub for testing
 */
class RedisStub
{
    private array $data = [];
    
    public function get(string $key): mixed
    {
        return $this->data[$key] ?? false;
    }
    
    public function set(string $key, mixed $value): bool
    {
        $this->data[$key] = $value;
        return true;
    }
    
    public function setex(string $key, int $ttl, mixed $value): bool
    {
        $this->data[$key] = $value;
        return true;
    }
    
    public function exists(string $key): bool
    {
        return isset($this->data[$key]);
    }
    
    public function del(string $key): int
    {
        if (isset($this->data[$key])) {
            unset($this->data[$key]);
            return 1;
        }
        return 0;
    }
    
    public function expire(string $key, int $ttl): bool
    {
        return isset($this->data[$key]);
    }
} 