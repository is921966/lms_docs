<?php

declare(strict_types=1);

namespace Competency\Http\Resources;

use Competency\Domain\Entities\CompetencyCategory;
use Illuminate\Http\Resources\Json\JsonResource;

class CompetencyCategoryResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @param \Illuminate\Http\Request $request
     * @return array<string, mixed>
     */
    public function toArray($request): array
    {
        /** @var CompetencyCategory $category */
        $category = $this->resource;

        return [
            'id' => $category->getId()->getValue(),
            'name' => $category->getName(),
            'description' => $category->getDescription(),
            'is_active' => $category->isActive(),
            'parent_id' => $category->hasParent() ? $category->getParent()->getId()->getValue() : null,
            'parent' => $category->hasParent() ? [
                'id' => $category->getParent()->getId()->getValue(),
                'name' => $category->getParent()->getName()
            ] : null,
            'color' => $category->getColor(),
            'icon' => $category->getIcon(),
            'created_at' => now()->toIso8601String(), // Would come from entity in real implementation
            'updated_at' => now()->toIso8601String()  // Would come from entity in real implementation
        ];
    }
}
