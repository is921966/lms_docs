<?php

declare(strict_types=1);

namespace App\Course\Domain\Entities;

use App\Common\Domain\AggregateRoot;
use App\Common\Exceptions\InvalidArgumentException;
use App\Course\Domain\ValueObjects\CourseId;
use App\Course\Domain\ValueObjects\CourseCode;
use App\Course\Domain\ValueObjects\Duration;
use App\Course\Domain\ValueObjects\Price;
use App\Course\Domain\Events\CourseCreated;
use App\Course\Domain\Events\CoursePublished;

class Course extends AggregateRoot
{
    private const STATUS_DRAFT = 'draft';
    private const STATUS_PUBLISHED = 'published';
    private const STATUS_ARCHIVED = 'archived';
    
    private CourseId $id;
    private CourseCode $code;
    private string $title;
    private string $description;
    private Duration $duration;
    private Price $price;
    private string $status;
    private \DateTimeImmutable $createdAt;
    private ?\DateTimeImmutable $publishedAt = null;
    private ?\DateTimeImmutable $archivedAt = null;
    
    public function __construct(
        CourseId $id,
        CourseCode $code,
        string $title,
        string $description,
        Duration $duration,
        Price $price
    ) {
        if (empty(trim($title))) {
            throw new InvalidArgumentException('Course title cannot be empty');
        }
        
        if (empty(trim($description))) {
            throw new InvalidArgumentException('Course description cannot be empty');
        }
        
        $this->id = $id;
        $this->code = $code;
        $this->title = trim($title);
        $this->description = trim($description);
        $this->duration = $duration;
        $this->price = $price;
        $this->status = self::STATUS_DRAFT;
        $this->createdAt = new \DateTimeImmutable();
        
        $this->recordEvent(new CourseCreated(
            $id->value(),
            $code->value(),
            $this->title,
            $this->description,
            $duration->inMinutes(),
            $price->amount(),
            $price->currency()
        ));
    }
    
    public function publish(): void
    {
        if ($this->status === self::STATUS_PUBLISHED) {
            throw new InvalidArgumentException('Course is already published');
        }
        
        if ($this->status === self::STATUS_ARCHIVED) {
            throw new InvalidArgumentException('Cannot publish archived course');
        }
        
        $this->status = self::STATUS_PUBLISHED;
        $this->publishedAt = new \DateTimeImmutable();
        
        $this->recordEvent(new CoursePublished(
            $this->id->value(),
            $this->code->value(),
            $this->title
        ));
    }
    
    public function archive(): void
    {
        if ($this->status === self::STATUS_ARCHIVED) {
            throw new InvalidArgumentException('Course is already archived');
        }
        
        $this->status = self::STATUS_ARCHIVED;
        $this->archivedAt = new \DateTimeImmutable();
    }
    
    public function updateDetails(string $title, string $description, Price $price): void
    {
        if ($this->status === self::STATUS_PUBLISHED) {
            throw new InvalidArgumentException('Cannot update published course');
        }
        
        if (empty(trim($title))) {
            throw new InvalidArgumentException('Course title cannot be empty');
        }
        
        if (empty(trim($description))) {
            throw new InvalidArgumentException('Course description cannot be empty');
        }
        
        $this->title = trim($title);
        $this->description = trim($description);
        $this->price = $price;
    }
    
    // Getters
    public function id(): CourseId
    {
        return $this->id;
    }
    
    public function code(): CourseCode
    {
        return $this->code;
    }
    
    public function title(): string
    {
        return $this->title;
    }
    
    public function description(): string
    {
        return $this->description;
    }
    
    public function duration(): Duration
    {
        return $this->duration;
    }
    
    public function price(): Price
    {
        return $this->price;
    }
    
    public function status(): string
    {
        return $this->status;
    }
    
    public function createdAt(): \DateTimeImmutable
    {
        return $this->createdAt;
    }
    
    public function publishedAt(): ?\DateTimeImmutable
    {
        return $this->publishedAt;
    }
    
    public function isPublished(): bool
    {
        return $this->status === self::STATUS_PUBLISHED;
    }
    
    public function isDraft(): bool
    {
        return $this->status === self::STATUS_DRAFT;
    }
    
    public function isArchived(): bool
    {
        return $this->status === self::STATUS_ARCHIVED;
    }
} 