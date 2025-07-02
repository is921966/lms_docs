<?php

declare(strict_types=1);

namespace Competency\Infrastructure\Repositories;

use Competency\Domain\Repositories\CompetencyCategoryRepositoryInterface;

/**
 * In-memory implementation of CompetencyCategoryRepository for testing
 */
class InMemoryCompetencyCategoryRepository implements CompetencyCategoryRepositoryInterface
{
    /**
     * @var array<string, object>
     */
    private array $categories = [];

    public function save(array $category): void
    {
        if (!isset($category['id'])) {
            throw new \InvalidArgumentException('Category must have an id');
        }
        
        $categoryObject = (object) array_merge([
            'name' => '',
            'description' => '',
            'is_active' => true
        ], $category);
        
        $this->categories[$category['id']] = $categoryObject;
    }

    public function findById(string $id): ?object
    {
        return $this->categories[$id] ?? null;
    }

    public function findByName(string $name): ?object
    {
        foreach ($this->categories as $category) {
            if ($category->name === $name) {
                return $category;
            }
        }
        return null;
    }

    public function findAll(): array
    {
        return array_values($this->categories);
    }

    public function findActive(): array
    {
        return array_values(
            array_filter(
                $this->categories,
                fn(object $category) => $category->is_active ?? true
            )
        );
    }

    public function delete(string $id): void
    {
        unset($this->categories[$id]);
    }

    /**
     * Additional helper methods for testing
     */
    public function exists(string $id): bool
    {
        return isset($this->categories[$id]);
    }

    /**
     * Clear all categories (useful for testing)
     */
    public function clear(): void
    {
        $this->categories = [];
    }

    /**
     * Count categories (useful for testing)
     */
    public function count(): int
    {
        return count($this->categories);
    }
    
    /**
     * Initialize with default categories
     */
    public function initializeDefaults(): void
    {
        $defaultCategories = [
            ['id' => 'technical', 'name' => 'Technical Skills', 'description' => 'Technical competencies'],
            ['id' => 'soft', 'name' => 'Soft Skills', 'description' => 'Interpersonal and communication skills'],
            ['id' => 'leadership', 'name' => 'Leadership', 'description' => 'Leadership and management skills'],
            ['id' => 'business', 'name' => 'Business', 'description' => 'Business and domain knowledge']
        ];
        
        foreach ($defaultCategories as $category) {
            $this->save($category);
        }
    }
} 