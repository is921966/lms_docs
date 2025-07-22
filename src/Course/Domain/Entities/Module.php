<?php

declare(strict_types=1);

namespace App\Course\Domain\Entities;

use App\Common\Exceptions\InvalidArgumentException;
use App\Course\Domain\ValueObjects\CourseId;
use Ramsey\Uuid\Uuid;

class Module
{
    private string $id;
    private CourseId $courseId;
    private string $title;
    private string $description;
    private int $order;
    private \DateTimeImmutable $createdAt;
    private ?\DateTimeImmutable $updatedAt = null;
    
    public function __construct(
        CourseId $courseId,
        string $title,
        string $description,
        int $order
    ) {
        if (empty(trim($title))) {
            throw new InvalidArgumentException('Module title cannot be empty');
        }
        
        if ($order < 1) {
            throw new InvalidArgumentException('Module order must be positive');
        }
        
        $this->id = 'MOD-' . Uuid::uuid4()->toString();
        $this->courseId = $courseId;
        $this->title = trim($title);
        $this->description = trim($description);
        $this->order = $order;
        $this->createdAt = new \DateTimeImmutable();
    }
    
    public function updateOrder(int $newOrder): void
    {
        if ($newOrder < 1) {
            throw new InvalidArgumentException('Module order must be positive');
        }
        
        $this->order = $newOrder;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function updateDetails(string $title, string $description): void
    {
        if (empty(trim($title))) {
            throw new InvalidArgumentException('Module title cannot be empty');
        }
        
        $this->title = trim($title);
        $this->description = trim($description);
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    // Getters
    public function id(): string
    {
        return $this->id;
    }
    
    public function courseId(): CourseId
    {
        return $this->courseId;
    }
    
    public function title(): string
    {
        return $this->title;
    }
    
    public function description(): string
    {
        return $this->description;
    }
    
    public function order(): int
    {
        return $this->order;
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