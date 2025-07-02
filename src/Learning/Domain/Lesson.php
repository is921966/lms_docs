<?php

declare(strict_types=1);

namespace Learning\Domain;

use Learning\Domain\ValueObjects\LessonId;
use Learning\Domain\ValueObjects\ModuleId;
use Learning\Domain\ValueObjects\LessonType;

class Lesson
{
    private LessonId $id;
    private ModuleId $moduleId;
    private string $title;
    private LessonType $type;
    private string $content;
    private int $orderIndex;
    private int $durationMinutes;
    private array $resources = [];
    private \DateTimeImmutable $createdAt;
    private \DateTimeImmutable $updatedAt;
    
    private function __construct(
        LessonId $id,
        ModuleId $moduleId,
        string $title,
        LessonType $type,
        string $content,
        int $orderIndex,
        int $durationMinutes
    ) {
        $this->id = $id;
        $this->moduleId = $moduleId;
        $this->title = $title;
        $this->type = $type;
        $this->content = $content;
        $this->setOrderIndex($orderIndex);
        $this->durationMinutes = $durationMinutes;
        $this->createdAt = new \DateTimeImmutable();
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public static function create(
        ModuleId $moduleId,
        string $title,
        LessonType $type,
        string $content,
        int $orderIndex,
        int $durationMinutes
    ): self {
        return new self(
            LessonId::generate(),
            $moduleId,
            $title,
            $type,
            $content,
            $orderIndex,
            $durationMinutes
        );
    }
    
    public function updateBasicInfo(string $title, string $content, int $durationMinutes): void
    {
        $this->title = $title;
        $this->content = $content;
        $this->durationMinutes = $durationMinutes;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function setOrderIndex(int $orderIndex): void
    {
        if ($orderIndex < 1) {
            throw new \InvalidArgumentException('Order index must be positive');
        }
        
        $this->orderIndex = $orderIndex;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function addResource(string $name, string $url): void
    {
        $this->resources[$name] = $url;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function removeResource(string $name): void
    {
        unset($this->resources[$name]);
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function isInteractive(): bool
    {
        return $this->type->isInteractive();
    }
    
    public function isGradable(): bool
    {
        return $this->type->isGradable();
    }
    
    // Getters
    public function getId(): LessonId
    {
        return $this->id;
    }
    
    public function getModuleId(): ModuleId
    {
        return $this->moduleId;
    }
    
    public function getTitle(): string
    {
        return $this->title;
    }
    
    public function getType(): LessonType
    {
        return $this->type;
    }
    
    public function getContent(): string
    {
        return $this->content;
    }
    
    public function getOrderIndex(): int
    {
        return $this->orderIndex;
    }
    
    public function getDurationMinutes(): int
    {
        return $this->durationMinutes;
    }
    
    public function getResources(): array
    {
        return $this->resources;
    }
    
    public function getCreatedAt(): \DateTimeImmutable
    {
        return $this->createdAt;
    }
    
    public function getUpdatedAt(): \DateTimeImmutable
    {
        return $this->updatedAt;
    }
} 