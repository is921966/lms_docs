<?php

declare(strict_types=1);

namespace Learning\Http\Requests;

final class UpdateCourseRequest
{
    private array $data;
    private array $errors = [];
    
    public function __construct(array $data)
    {
        $this->data = $data;
        $this->validate();
    }
    
    private function validate(): void
    {
        // Title validation (optional)
        if (isset($this->data['title'])) {
            if (strlen($this->data['title']) > 255) {
                $this->errors['title'] = 'Title must not exceed 255 characters';
            }
        }
        
        // Description validation (optional)
        if (isset($this->data['description']) && !is_string($this->data['description'])) {
            $this->errors['description'] = 'Description must be a string';
        }
        
        // Duration validation (optional)
        if (isset($this->data['duration_hours'])) {
            if (!is_numeric($this->data['duration_hours']) || $this->data['duration_hours'] < 1) {
                $this->errors['duration_hours'] = 'Duration must be at least 1 hour';
            }
        }
        
        // Price validation (optional)
        if (isset($this->data['price'])) {
            if (!is_numeric($this->data['price']) || $this->data['price'] < 0) {
                $this->errors['price'] = 'Price cannot be negative';
            }
        }
        
        // Category ID validation (optional)
        if (isset($this->data['category_id'])) {
            if (!$this->isValidUuid($this->data['category_id'])) {
                $this->errors['category_id'] = 'Category ID must be a valid UUID';
            }
        }
        
        // Tags validation (optional)
        if (isset($this->data['tags'])) {
            if (!is_array($this->data['tags'])) {
                $this->errors['tags'] = 'Tags must be an array';
            } else {
                foreach ($this->data['tags'] as $index => $tag) {
                    if (!is_string($tag)) {
                        $this->errors["tags.$index"] = 'Each tag must be a string';
                    } elseif (strlen($tag) > 50) {
                        $this->errors["tags.$index"] = 'Tag must not exceed 50 characters';
                    }
                }
            }
        }
        
        // Status validation (optional)
        if (isset($this->data['status'])) {
            $allowedStatuses = ['draft', 'published', 'archived'];
            if (!in_array($this->data['status'], $allowedStatuses, true)) {
                $this->errors['status'] = 'Invalid course status';
            }
        }
    }
    
    private function isValidUuid(string $uuid): bool
    {
        return preg_match('/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i', $uuid) === 1;
    }
    
    public function isValid(): bool
    {
        return empty($this->errors);
    }
    
    public function getErrors(): array
    {
        return $this->errors;
    }
    
    public function getTitle(): ?string
    {
        return $this->data['title'] ?? null;
    }
    
    public function getDescription(): ?string
    {
        return $this->data['description'] ?? null;
    }
    
    public function getDurationHours(): ?int
    {
        return isset($this->data['duration_hours']) ? (int) $this->data['duration_hours'] : null;
    }
    
    public function getPrice(): ?float
    {
        return isset($this->data['price']) ? (float) $this->data['price'] : null;
    }
    
    public function getCategoryId(): ?string
    {
        return $this->data['category_id'] ?? null;
    }
    
    public function getTags(): ?array
    {
        return $this->data['tags'] ?? null;
    }
    
    public function getStatus(): ?string
    {
        return $this->data['status'] ?? null;
    }
    
    public function toArray(): array
    {
        $result = [];
        
        if (isset($this->data['title'])) {
            $result['title'] = $this->getTitle();
        }
        if (isset($this->data['description'])) {
            $result['description'] = $this->getDescription();
        }
        if (isset($this->data['duration_hours'])) {
            $result['duration_hours'] = $this->getDurationHours();
        }
        if (isset($this->data['price'])) {
            $result['price'] = $this->getPrice();
        }
        if (isset($this->data['category_id'])) {
            $result['category_id'] = $this->getCategoryId();
        }
        if (isset($this->data['tags'])) {
            $result['tags'] = $this->getTags();
        }
        if (isset($this->data['status'])) {
            $result['status'] = $this->getStatus();
        }
        
        return $result;
    }
} 