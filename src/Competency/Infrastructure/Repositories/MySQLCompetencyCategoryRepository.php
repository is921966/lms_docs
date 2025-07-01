<?php

declare(strict_types=1);

namespace Competency\Infrastructure\Repositories;

use Competency\Domain\Entities\CompetencyCategory;
use Competency\Domain\Repositories\CompetencyCategoryRepositoryInterface;
use Competency\Domain\ValueObjects\CategoryId;
use Illuminate\Support\Facades\DB;

/**
 * MySQL implementation of CompetencyCategoryRepository
 */
class MySQLCompetencyCategoryRepository implements CompetencyCategoryRepositoryInterface
{
    public function save(CompetencyCategory $category): void
    {
        $parentId = null;
        if ($category->hasParent()) {
            $parentId = $category->getParent()->getId()->getValue();
        }

        DB::table('competency_categories')->updateOrInsert(
            ['id' => $category->getId()->getValue()],
            [
                'name' => $category->getName(),
                'description' => $category->getDescription(),
                'parent_id' => $parentId,
                'is_active' => $category->isActive(),
                'updated_at' => now(),
                'created_at' => DB::raw('IFNULL(created_at, NOW())')
            ]
        );
    }

    public function findById(string $id): ?CompetencyCategory
    {
        $data = DB::table('competency_categories')
            ->where('id', $id)
            ->first();

        return $data ? $this->mapToEntity($data) : null;
    }

    public function findByName(string $name): ?CompetencyCategory
    {
        $data = DB::table('competency_categories')
            ->where('name', $name)
            ->first();

        return $data ? $this->mapToEntity($data) : null;
    }

    public function findAll(): array
    {
        $results = DB::table('competency_categories')->get();
        
        return $this->mapCollectionToEntities($results);
    }

    public function findActive(): array
    {
        $results = DB::table('competency_categories')
            ->where('is_active', true)
            ->get();
        
        return $this->mapCollectionToEntities($results);
    }

    public function delete(string $id): void
    {
        DB::table('competency_categories')->where('id', $id)->delete();
    }

    /**
     * Map database row to entity
     */
    private function mapToEntity($data): CompetencyCategory
    {
        $category = CompetencyCategory::createWithId(
            CategoryId::fromString($data->id),
            $data->name,
            $data->description
        );

        // Set parent if exists
        if ($data->parent_id) {
            $parent = $this->findById($data->parent_id);
            if ($parent) {
                $category->setParent($parent);
            }
        }

        // Activate/deactivate based on database value
        if (!$data->is_active) {
            $category->deactivate();
        }

        return $category;
    }

    /**
     * Map collection of database rows to entities
     */
    private function mapCollectionToEntities($collection): array
    {
        // First pass: create all categories without parents
        $categories = [];
        foreach ($collection as $data) {
            $category = CompetencyCategory::createWithId(
                CategoryId::fromString($data->id),
                $data->name,
                $data->description
            );

            if (!$data->is_active) {
                $category->deactivate();
            }

            $categories[$data->id] = [
                'entity' => $category,
                'parent_id' => $data->parent_id
            ];
        }

        // Second pass: set parents
        foreach ($categories as $id => $categoryData) {
            if ($categoryData['parent_id'] && isset($categories[$categoryData['parent_id']])) {
                $categoryData['entity']->setParent($categories[$categoryData['parent_id']]['entity']);
            }
        }

        // Return only the entities
        return array_values(array_map(fn($data) => $data['entity'], $categories));
    }
}
