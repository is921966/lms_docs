<?php

declare(strict_types=1);

namespace App\Course\Domain\Entities;

use App\Common\Exceptions\InvalidArgumentException;
use App\Course\Domain\ValueObjects\Duration;
use Ramsey\Uuid\Uuid;

class Lesson
{
    private const VALID_TYPES = ['text', 'video', 'audio', 'quiz', 'assignment'];
    
    private string $id;
    private string $moduleId;
    private string $title;
    private string $description;
    private string $content;
    private Duration $duration;
    private int $order;
    private string $type;
    private \DateTimeImmutable $createdAt;
    private ?\DateTimeImmutable $updatedAt = null;
    
    public function __construct(
        string $moduleId,
        string $title,
        string $description,
        string $content,
        Duration $duration,
        int $order,
        string $type = 'text'
    ) {
        if (empty(trim($title))) {
            throw new InvalidArgumentException('Lesson title cannot be empty');
        }
        
        if ($order < 1) {
            throw new InvalidArgumentException('Lesson order must be positive');
        }
        
        if (!in_array($type, self::VALID_TYPES, true)) {
            throw new InvalidArgumentException('Invalid lesson type');
        }
        
        $this->id = 'LSN-' . Uuid::uuid4()->toString();
        $this->moduleId = $moduleId;
        $this->title = trim($title);
        $this->description = trim($description);
        $this->content = $content;
        $this->duration = $duration;
        $this->order = $order;
        $this->type = $type;
        $this->createdAt = new \DateTimeImmutable();
    }
    
    public function markAsCompleted(string $userId): bool
    {
        // This would typically record completion in a separate tracking entity/table
        // For now, just return true to indicate successful marking
        return true;
    }
    
    public function updateContent(string $content, Duration $duration): void
    {
        $this->content = $content;
        $this->duration = $duration;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function updateOrder(int $newOrder): void
    {
        if ($newOrder < 1) {
            throw new InvalidArgumentException('Lesson order must be positive');
        }
        
        $this->order = $newOrder;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    // Getters
    public function id(): string
    {
        return $this->id;
    }
    
    public function moduleId(): string
    {
        return $this->moduleId;
    }
    
    public function title(): string
    {
        return $this->title;
    }
    
    public function description(): string
    {
        return $this->description;
    }
    
    public function content(): string
    {
        return $this->content;
    }
    
    public function duration(): Duration
    {
        return $this->duration;
    }
    
    public function order(): int
    {
        return $this->order;
    }
    
    public function type(): string
    {
        return $this->type;
    }
    
    public function createdAt(): \DateTimeImmutable
    {
        return $this->createdAt;
    }
    
    public function updatedAt(): ?\DateTimeImmutable
    {
        return $this->updatedAt;
    }
} 