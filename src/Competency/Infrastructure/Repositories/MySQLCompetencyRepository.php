<?php

declare(strict_types=1);

namespace Competency\Infrastructure\Repositories;

use Competency\Domain\Entities\Competency;
use Competency\Domain\Entities\CompetencyCategory;
use Competency\Domain\Repositories\CompetencyRepositoryInterface;
use Competency\Domain\ValueObjects\CategoryId;
use Competency\Domain\ValueObjects\CompetencyId;
use Competency\Domain\ValueObjects\SkillLevel;
use Illuminate\Support\Facades\DB;

/**
 * MySQL implementation of CompetencyRepository
 */
class MySQLCompetencyRepository implements CompetencyRepositoryInterface
{
    public function save(Competency $competency): void
    {
        DB::table('competencies')->updateOrInsert(
            ['id' => $competency->getId()->getValue()],
            [
                'name' => $competency->getName(),
                'description' => $competency->getDescription(),
                'category_id' => $competency->getCategory()->getId()->getValue(),
                'is_active' => $competency->isActive(),
                'updated_at' => now(),
                'created_at' => DB::raw('IFNULL(created_at, NOW())')
            ]
        );
    }

    public function findById(string $id): ?Competency
    {
        $data = DB::table('competencies')
            ->where('id', $id)
            ->first();

        return $data ? $this->mapToEntity($data) : null;
    }

    public function findByName(string $name): ?Competency
    {
        $data = DB::table('competencies')
            ->where('name', $name)
            ->first();

        return $data ? $this->mapToEntity($data) : null;
    }

    public function findByCategory(string $categoryId): array
    {
        $results = DB::table('competencies')
            ->where('category_id', $categoryId)
            ->get();

        return $results->map(fn($data) => $this->mapToEntity($data))->toArray();
    }

    public function findAll(): array
    {
        $results = DB::table('competencies')->get();
        
        return $results->map(fn($data) => $this->mapToEntity($data))->toArray();
    }

    public function delete(string $id): void
    {
        DB::table('competencies')->where('id', $id)->delete();
    }

    /**
     * Map database row to entity
     */
    private function mapToEntity($data): Competency
    {
        // First, load the category
        $categoryData = DB::table('competency_categories')
            ->where('id', $data->category_id)
            ->first();

        if (!$categoryData) {
            throw new \RuntimeException("Category not found: {$data->category_id}");
        }

        $category = CompetencyCategory::createWithId(
            CategoryId::fromString($categoryData->id),
            $categoryData->name,
            $categoryData->description
        );

        $competency = Competency::createWithId(
            CompetencyId::fromString($data->id),
            $data->name,
            $data->description,
            $category
        );

        // Activate/deactivate based on database value
        if (!$data->is_active) {
            $competency->deactivate();
        }

        return $competency;
    }
}
