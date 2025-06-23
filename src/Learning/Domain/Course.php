<?php

declare(strict_types=1);

namespace App\Learning\Domain;

use App\Learning\Domain\ValueObjects\CourseId;
use App\Learning\Domain\ValueObjects\CourseCode;
use App\Learning\Domain\ValueObjects\CourseType;
use App\Learning\Domain\ValueObjects\CourseStatus;

class Course
{
    private CourseId $id;
    private CourseCode $code;
    private string $title;
    private string $description;
    private CourseType $type;
    private int $durationHours;
    private ?string $imageUrl = null;
    private CourseStatus $status;
    private array $modules = [];
    private array $prerequisites = [];
    private array $tags = [];
    private \DateTimeImmutable $createdAt;
    private \DateTimeImmutable $updatedAt;
    
    private function __construct(
        CourseId $id,
        CourseCode $code,
        string $title,
        string $description,
        CourseType $type,
        int $durationHours
    ) {
        $this->id = $id;
        $this->code = $code;
        $this->title = $title;
        $this->description = $description;
        $this->type = $type;
        $this->durationHours = $durationHours;
        $this->status = CourseStatus::DRAFT;
        $this->createdAt = new \DateTimeImmutable();
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public static function create(
        CourseCode $code,
        string $title,
        string $description,
        CourseType $type,
        int $durationHours
    ): self {
        return new self(
            CourseId::generate(),
            $code,
            $title,
            $description,
            $type,
            $durationHours
        );
    }
    
    public function updateBasicInfo(string $title, string $description, int $durationHours): void
    {
        if ($this->status === CourseStatus::PUBLISHED) {
            throw new \DomainException('Cannot update published course');
        }
        
        $this->title = $title;
        $this->description = $description;
        $this->durationHours = $durationHours;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function setImageUrl(string $imageUrl): void
    {
        $this->imageUrl = $imageUrl;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function addTag(string $tag): void
    {
        if (!in_array($tag, $this->tags, true)) {
            $this->tags[] = $tag;
            $this->updatedAt = new \DateTimeImmutable();
        }
    }
    
    public function removeTag(string $tag): void
    {
        $this->tags = array_values(array_filter($this->tags, fn($t) => $t !== $tag));
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function addPrerequisite(CourseId $courseId): void
    {
        if ($courseId->equals($this->id)) {
            throw new \DomainException('Course cannot be its own prerequisite');
        }
        
        if (!$this->hasPrerequisite($courseId)) {
            $this->prerequisites[] = $courseId;
            $this->updatedAt = new \DateTimeImmutable();
        }
    }
    
    public function hasPrerequisite(CourseId $courseId): bool
    {
        foreach ($this->prerequisites as $prerequisite) {
            if ($prerequisite->equals($courseId)) {
                return true;
            }
        }
        return false;
    }
    
    public function publish(): void
    {
        if (empty($this->title)) {
            throw new \DomainException('Cannot publish course without title');
        }
        
        if (!$this->status->canTransitionTo(CourseStatus::PUBLISHED)) {
            throw new \DomainException('Cannot publish course in current status');
        }
        
        $this->status = CourseStatus::PUBLISHED;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function archive(): void
    {
        if (!$this->status->canTransitionTo(CourseStatus::ARCHIVED)) {
            throw new \DomainException('Cannot archive course in current status');
        }
        
        $this->status = CourseStatus::ARCHIVED;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function reactivate(): void
    {
        if ($this->status !== CourseStatus::ARCHIVED) {
            throw new \DomainException('Can only reactivate archived courses');
        }
        
        $this->status = CourseStatus::DRAFT;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    // Getters
    public function getId(): CourseId
    {
        return $this->id;
    }
    
    public function getCode(): CourseCode
    {
        return $this->code;
    }
    
    public function getTitle(): string
    {
        return $this->title;
    }
    
    public function getDescription(): string
    {
        return $this->description;
    }
    
    public function getType(): CourseType
    {
        return $this->type;
    }
    
    public function getDurationHours(): int
    {
        return $this->durationHours;
    }
    
    public function getImageUrl(): ?string
    {
        return $this->imageUrl;
    }
    
    public function getStatus(): CourseStatus
    {
        return $this->status;
    }
    
    public function getTags(): array
    {
        return $this->tags;
    }
    
    public function getPrerequisites(): array
    {
        return $this->prerequisites;
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