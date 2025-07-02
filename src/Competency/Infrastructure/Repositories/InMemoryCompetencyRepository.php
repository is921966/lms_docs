<?php

declare(strict_types=1);

namespace Competency\Infrastructure\Repositories;

use Competency\Domain\Competency;
use Competency\Domain\Repositories\CompetencyRepositoryInterface;
use Competency\Domain\ValueObjects\CategoryId;
use Competency\Domain\ValueObjects\CompetencyId;

/**
 * In-memory implementation of CompetencyRepository for testing
 */
class InMemoryCompetencyRepository implements CompetencyRepositoryInterface
{
    /**
     * @var array<string, Competency>
     */
    private array $competencies = [];

    public function save(Competency $competency): void
    {
        $this->competencies[$competency->getId()->getValue()] = $competency;
    }

    public function findById(string $id): ?Competency
    {
        return $this->competencies[$id] ?? null;
    }

    public function findByName(string $name): ?Competency
    {
        foreach ($this->competencies as $competency) {
            if ($competency->getName() === $name) {
                return $competency;
            }
        }
        return null;
    }

    public function findByCategory(string $categoryId): array
    {
        return array_values(
            array_filter(
                $this->competencies,
                fn(Competency $competency) => $competency->getCategory()->getValue() === $categoryId
            )
        );
    }

    public function findAll(): array
    {
        return array_values($this->competencies);
    }

    public function delete(string $id): void
    {
        unset($this->competencies[$id]);
    }

    /**
     * Additional helper methods for testing
     */
    public function exists(string $id): bool
    {
        return isset($this->competencies[$id]);
    }

    /**
     * Clear all competencies (useful for testing)
     */
    public function clear(): void
    {
        $this->competencies = [];
    }

    /**
     * Count competencies (useful for testing)
     */
    public function count(): int
    {
        return count($this->competencies);
    }
}
