<?php

declare(strict_types=1);

namespace Competency\Http\Resources;

use Competency\Domain\Entities\Competency;
use Illuminate\Http\Resources\Json\JsonResource;

class CompetencyResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @param \Illuminate\Http\Request $request
     * @return array<string, mixed>
     */
    public function toArray($request): array
    {
        /** @var Competency $competency */
        $competency = $this->resource;

        return [
            'id' => $competency->getId()->getValue(),
            'name' => $competency->getName(),
            'description' => $competency->getDescription(),
            'category' => [
                'id' => $competency->getCategory()->getId()->getValue(),
                'name' => $competency->getCategory()->getName(),
                'description' => $competency->getCategory()->getDescription()
            ],
            'is_active' => $competency->isActive(),
            'is_core' => $this->getIsCore($competency),
            'required_level' => $this->getRequiredLevel($competency),
            'skill_levels' => $this->getSkillLevels($competency),
            'created_at' => $this->getCreatedAt($competency),
            'updated_at' => $this->getUpdatedAt($competency)
        ];
    }

    /**
     * Get is_core flag (from metadata or default)
     */
    private function getIsCore(Competency $competency): bool
    {
        // This would come from metadata or a property
        // For now, return false as default
        return false;
    }

    /**
     * Get required level (from metadata or default)
     */
    private function getRequiredLevel(Competency $competency): ?int
    {
        // This would come from metadata or a property
        // For now, return null as default
        return null;
    }

    /**
     * Get skill levels array
     */
    private function getSkillLevels(Competency $competency): array
    {
        $levels = $competency->getSkillLevels();
        
        return array_map(function ($level) {
            return [
                'level' => $level->getLevel(),
                'name' => $level->getName(),
                'description' => $level->getDescription()
            ];
        }, $levels);
    }

    /**
     * Get created timestamp
     */
    private function getCreatedAt(Competency $competency): ?string
    {
        // In a real implementation, this would come from the entity
        return now()->toIso8601String();
    }

    /**
     * Get updated timestamp
     */
    private function getUpdatedAt(Competency $competency): ?string
    {
        // In a real implementation, this would come from the entity
        return now()->toIso8601String();
    }
}
