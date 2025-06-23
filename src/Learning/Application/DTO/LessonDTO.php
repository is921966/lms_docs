<?php

declare(strict_types=1);

namespace App\Learning\Application\DTO;

use App\Learning\Domain\Lesson;
use App\Learning\Domain\ValueObjects\LessonType;

final class LessonDTO
{
    public function __construct(
        public readonly ?string $id,
        public readonly string $moduleId,
        public readonly string $title,
        public readonly string $type,
        public readonly string $content,
        public readonly int $orderIndex,
        public readonly int $durationMinutes,
        public readonly bool $isCompleted,
        public readonly float $completionPercentage,
        public readonly array $resources,
        public readonly bool $isInteractive,
        public readonly bool $isGradable,
        public readonly ?string $createdAt = null,
        public readonly ?string $updatedAt = null
    ) {}
    
    public static function fromArray(array $data): self
    {
        $type = strtolower($data['type'] ?? 'text');
        
        return new self(
            id: $data['id'] ?? null,
            moduleId: $data['moduleId'],
            title: $data['title'],
            type: $type,
            content: $data['content'],
            orderIndex: $data['orderIndex'],
            durationMinutes: $data['durationMinutes'],
            isCompleted: $data['isCompleted'] ?? false,
            completionPercentage: $data['completionPercentage'] ?? 0.0,
            resources: $data['resources'] ?? [],
            isInteractive: self::determineIsInteractive($type),
            isGradable: self::determineIsGradable($type),
            createdAt: $data['createdAt'] ?? null,
            updatedAt: $data['updatedAt'] ?? null
        );
    }
    
    public static function fromEntity(Lesson $lesson, bool $isCompleted = false, float $completionPercentage = 0.0): self
    {
        $type = strtolower($lesson->getType()->value);
        
        return new self(
            id: $lesson->getId()->toString(),
            moduleId: $lesson->getModuleId()->toString(),
            title: $lesson->getTitle(),
            type: $type,
            content: $lesson->getContent(),
            orderIndex: $lesson->getOrderIndex(),
            durationMinutes: $lesson->getDurationMinutes(),
            isCompleted: $isCompleted,
            completionPercentage: $completionPercentage,
            resources: $lesson->getResources(),
            isInteractive: $lesson->isInteractive(),
            isGradable: $lesson->isGradable(),
            createdAt: $lesson->getCreatedAt()->format('c'),
            updatedAt: $lesson->getUpdatedAt()->format('c')
        );
    }
    
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'moduleId' => $this->moduleId,
            'title' => $this->title,
            'type' => $this->type,
            'content' => $this->content,
            'orderIndex' => $this->orderIndex,
            'durationMinutes' => $this->durationMinutes,
            'isCompleted' => $this->isCompleted,
            'completionPercentage' => $this->completionPercentage,
            'resources' => $this->resources,
            'isInteractive' => $this->isInteractive,
            'isGradable' => $this->isGradable,
            'createdAt' => $this->createdAt,
            'updatedAt' => $this->updatedAt,
        ];
    }
    
    private static function determineIsInteractive(string $type): bool
    {
        return in_array($type, ['quiz', 'assignment'], true);
    }
    
    private static function determineIsGradable(string $type): bool
    {
        return in_array($type, ['quiz', 'assignment'], true);
    }
} 