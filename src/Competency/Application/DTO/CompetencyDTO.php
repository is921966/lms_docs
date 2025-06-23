<?php

declare(strict_types=1);

namespace App\Competency\Application\DTO;

use App\Competency\Domain\Competency;

final class CompetencyDTO
{
    public function __construct(
        public readonly string $id,
        public readonly string $code,
        public readonly string $name,
        public readonly string $description,
        public readonly string $category,
        public readonly ?string $parentId,
        public readonly bool $isActive
    ) {
    }
    
    public static function fromArray(array $data): self
    {
        return new self(
            id: $data['id'],
            code: $data['code'],
            name: $data['name'],
            description: $data['description'],
            category: $data['category'],
            parentId: $data['parent_id'] ?? null,
            isActive: $data['is_active'] ?? true
        );
    }
    
    public static function fromEntity(Competency $competency): self
    {
        return new self(
            id: $competency->getId()->getValue(),
            code: $competency->getCode()->getValue(),
            name: $competency->getName(),
            description: $competency->getDescription(),
            category: $competency->getCategory()->getValue(),
            parentId: $competency->getParentId()?->getValue(),
            isActive: $competency->isActive()
        );
    }
    
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'code' => $this->code,
            'name' => $this->name,
            'description' => $this->description,
            'category' => $this->category,
            'parent_id' => $this->parentId,
            'is_active' => $this->isActive
        ];
    }
} 