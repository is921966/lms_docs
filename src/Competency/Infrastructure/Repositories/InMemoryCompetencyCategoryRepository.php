<?php

declare(strict_types=1);

namespace Competency\Infrastructure\Repositories;

use Competency\Domain\Entities\CompetencyCategory;
use Competency\Domain\Repositories\CompetencyCategoryRepositoryInterface;
use Competency\Domain\ValueObjects\CategoryId;

/**
 * In-memory implementation of CompetencyCategoryRepository for testing
 */
class InMemoryCompetencyCategoryRepository implements CompetencyCategoryRepositoryInterface
{
    /**
     * @var array<string, CompetencyCategory>
     */
    private array $categories = [];

    public function save(CompetencyCategory $category): void
    {
        $this->categories[$category->getId()->getValue()] = $category;
    }

    public function findById(string $id): ?CompetencyCategory
    {
        return $this->categories[$id] ?? null;
    }

    public function findByName(string $name): ?CompetencyCategory
    {
        foreach ($this->categories as $category) {
            if ($category->getName() === $name) {
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
                fn(CompetencyCategory $category) => $category->isActive()
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
    public function findByParentId(?string $parentId): array
    {
        return array_values(
            array_filter(
                $this->categories,
                function (CompetencyCategory $category) use ($parentId) {
                    if ($parentId === null) {
                        return !$category->hasParent();
                    }
                    return $category->hasParent() && 
                           $category->getParent()->getId()->getValue() === $parentId;
                }
            )
        );
    }

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
}
