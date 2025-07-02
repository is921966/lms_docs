<?php

namespace Illuminate\Http;

class Request
{
    private array $query = [];
    private array $attributes = [];
    private object $user;

    public function query($key = null, $default = null)
    {
        if ($key === null) {
            return $this->query;
        }
        
        return $this->query[$key] ?? $default;
    }

    public function setQuery(array $query): void
    {
        $this->query = $query;
    }

    public function input($key, $default = null)
    {
        return $this->attributes[$key] ?? $default;
    }

    public function setAttribute($key, $value): void
    {
        $this->attributes[$key] = $value;
    }

    public function validate(array $rules): array
    {
        // Simple validation mock - just return the input attributes
        return $this->attributes;
    }

    public function user()
    {
        if (!isset($this->user)) {
            $this->user = new class {
                public $id = 'test-user-id';
                
                public function can($ability, $resource = null)
                {
                    return true; // Allow all for tests
                }
            };
        }
        return $this->user;
    }

    public function setUser($user): void
    {
        $this->user = $user;
    }
} 