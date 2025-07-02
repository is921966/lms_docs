<?php

declare(strict_types=1);

namespace Learning\Application\DTO;

use Learning\Domain\Module;

final class ModuleDTO
{
    public function __construct(
        public readonly ?string $id,
        public readonly string $courseId,
        public readonly string $title,
        public readonly string $description,
        public readonly int $orderIndex,
        public readonly int $durationMinutes,
        public readonly bool $isRequired,
        public readonly int $lessonCount,
        public readonly int $completedLessons,
        public readonly ?string $createdAt = null,
        public readonly ?string $updatedAt = null
    ) {}
    
    public static function fromArray(array $data): self
    {
        return new self(
            id: $data['id'] ?? null,
            courseId: $data['courseId'],
            title: $data['title'],
            description: $data['description'],
            orderIndex: $data['orderIndex'],
            durationMinutes: $data['durationMinutes'],
            isRequired: $data['isRequired'] ?? true,
            lessonCount: $data['lessonCount'] ?? 0,
            completedLessons: $data['completedLessons'] ?? 0,
            createdAt: $data['createdAt'] ?? null,
            updatedAt: $data['updatedAt'] ?? null
        );
    }
    
    public static function fromEntity(Module $module, int $completedLessons = 0): self
    {
        return new self(
            id: $module->getId()->getValue(),
            courseId: $module->getCourseId()->getValue(),
            title: $module->getTitle(),
            description: $module->getDescription(),
            orderIndex: $module->getOrderIndex(),
            durationMinutes: $module->getDurationMinutes(),
            isRequired: $module->isRequired(),
            lessonCount: count($module->getLessons()),
            completedLessons: $completedLessons,
            createdAt: $module->getCreatedAt()->format('c'),
            updatedAt: $module->getUpdatedAt()->format('c')
        );
    }
    
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'courseId' => $this->courseId,
            'title' => $this->title,
            'description' => $this->description,
            'orderIndex' => $this->orderIndex,
            'durationMinutes' => $this->durationMinutes,
            'isRequired' => $this->isRequired,
            'lessonCount' => $this->lessonCount,
            'completedLessons' => $this->completedLessons,
            'progressPercentage' => $this->getProgressPercentage(),
            'createdAt' => $this->createdAt,
            'updatedAt' => $this->updatedAt,
        ];
    }
    
    public function getProgressPercentage(): float
    {
        if ($this->lessonCount === 0) {
            return 0.0;
        }
        
        return round(($this->completedLessons / $this->lessonCount) * 100, 2);
    }
} 