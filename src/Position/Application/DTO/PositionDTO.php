<?php

declare(strict_types=1);

namespace App\Position\Application\DTO;

use App\Position\Domain\Position;

final class PositionDTO
{
    public function __construct(
        public readonly string $id,
        public readonly string $code,
        public readonly string $title,
        public readonly string $department,
        public readonly int $level,
        public readonly string $levelName,
        public readonly string $description,
        public readonly ?string $parentId,
        public readonly bool $isActive,
        public readonly \DateTimeImmutable $createdAt,
        public readonly \DateTimeImmutable $updatedAt
    ) {
    }
    
    public static function fromDomain(Position $position): self
    {
        return new self(
            id: $position->getId()->getValue(),
            code: $position->getCode()->getValue(),
            title: $position->getTitle(),
            department: $position->getDepartment()->getValue(),
            level: $position->getLevel()->getValue(),
            levelName: $position->getLevel()->getName(),
            description: $position->getDescription(),
            parentId: $position->getParentId()?->getValue(),
            isActive: $position->isActive(),
            createdAt: $position->getCreatedAt(),
            updatedAt: $position->getUpdatedAt()
        );
    }
    
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'code' => $this->code,
            'title' => $this->title,
            'department' => $this->department,
            'level' => $this->level,
            'levelName' => $this->levelName,
            'description' => $this->description,
            'parentId' => $this->parentId,
            'isActive' => $this->isActive,
            'createdAt' => $this->createdAt->format('c'),
            'updatedAt' => $this->updatedAt->format('c')
        ];
    }
}
