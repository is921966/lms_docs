<?php

namespace CompetencyService\Application\DTOs;

use CompetencyService\Domain\Entities\Competency;

final class CompetencyDTO
{
    public function __construct(
        public readonly string $id,
        public readonly string $code,
        public readonly string $name,
        public readonly string $description,
        public readonly string $category,
        public readonly array $levels,
        public readonly bool $isActive,
        public readonly string $createdAt,
        public readonly ?string $updatedAt
    ) {}
    
    public static function fromEntity(Competency $competency): self
    {
        return new self(
            id: $competency->getId()->toString(),
            code: $competency->getCode()->getValue(),
            name: $competency->getName(),
            description: $competency->getDescription(),
            category: $competency->getCategory(),
            levels: array_map(fn($level) => $level->toArray(), $competency->getLevels()),
            isActive: $competency->isActive(),
            createdAt: $competency->toArray()['created_at'],
            updatedAt: $competency->toArray()['updated_at']
        );
    }
} 