<?php

declare(strict_types=1);

namespace Learning\Domain;

use Common\Traits\HasDomainEvents;
use Learning\Domain\Events\CourseCreated;
use Learning\Domain\ValueObjects\CourseId;
use Learning\Domain\ValueObjects\CourseCode;
use Learning\Domain\ValueObjects\CourseStatus;
use Learning\Domain\ValueObjects\Duration;
use DomainException;

class Course
{
    use HasDomainEvents;
    
    private CourseId $id;
    private CourseCode $code;
    private string $title;
    private string $description;
    private CourseStatus $status;
    private Duration $duration;
    private array $modules = [];
    private array $prerequisites = [];
    private array $metadata = [];
    private \DateTimeImmutable $createdAt;
    private ?\DateTimeImmutable $updatedAt = null;
    private ?\DateTimeImmutable $publishedAt = null;
    
    private function __construct(
        CourseId $id,
        CourseCode $code,
        string $title,
        string $description,
        Duration $duration,
        CourseStatus $status,
        \DateTimeImmutable $createdAt
    ) {
        $this->id = $id;
        $this->code = $code;
        $this->title = $title;
        $this->description = $description;
        $this->duration = $duration;
        $this->status = $status;
        $this->createdAt = $createdAt;
    }
    
    public static function create(
        CourseId $id,
        CourseCode $code,
        string $title,
        string $description,
        Duration $duration
    ): self {
        $course = new self(
            $id,
            $code,
            $title,
            $description,
            $duration,
            CourseStatus::draft(),
            new \DateTimeImmutable()
        );
        
        $course->recordDomainEvent(CourseCreated::create(
            $id,
            $code,
            $title,
            $description,
            CourseStatus::draft()
        ));
        
        return $course;
    }
    
    public function updateDetails(string $title, string $description): void
    {
        if ($this->status->isArchived()) {
            throw new DomainException('Cannot update archived course');
        }
        
        $this->title = $title;
        $this->description = $description;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function publish(): void
    {
        if (empty($this->modules)) {
            throw new DomainException('Cannot publish course without modules');
        }
        
        if (!$this->status->canTransitionTo(CourseStatus::published())) {
            throw new DomainException('Invalid status transition to published');
        }
        
        $this->status = CourseStatus::published();
        $this->publishedAt = new \DateTimeImmutable();
    }
    
    public function archive(): void
    {
        if (!$this->status->isPublished()) {
            throw new DomainException('Only published courses can be archived');
        }
        
        $this->status = CourseStatus::archived();
    }
    
    public function addModule(array $module): void
    {
        if ($this->status->isArchived()) {
            throw new DomainException('Cannot add modules to archived course');
        }
        
        $this->modules[] = $module;
    }
    
    public function setPrerequisites(array $prerequisites): void
    {
        if ($this->status->isArchived()) {
            throw new DomainException('Cannot update prerequisites for archived course');
        }
        
        $this->prerequisites = $prerequisites;
    }
    
    public function addMetadata(string $key, mixed $value): void
    {
        $this->metadata[$key] = $value;
    }
    
    public function setMetadata(string $key, mixed $value): void
    {
        $this->metadata[$key] = $value;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function calculateTotalDuration(): Duration
    {
        $totalMinutes = 0;
        foreach ($this->modules as $module) {
            $totalMinutes += $module['duration'] ?? 0;
        }
        
        return Duration::fromMinutes($totalMinutes);
    }
    
    public function canEnroll(): bool
    {
        return $this->status->canEnroll();
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
    
    public function getStatus(): CourseStatus
    {
        return $this->status;
    }
    
    public function getDuration(): Duration
    {
        return $this->duration;
    }
    
    public function getModules(): array
    {
        return $this->modules;
    }
    
    public function getPrerequisites(): array
    {
        return $this->prerequisites;
    }
    
    public function getMetadata(): array
    {
        return $this->metadata;
    }
    
    public function getCreatedAt(): \DateTimeImmutable
    {
        return $this->createdAt;
    }
    
    public function getPublishedAt(): ?\DateTimeImmutable
    {
        return $this->publishedAt;
    }
    
    public function getUpdatedAt(): ?\DateTimeImmutable
    {
        return $this->updatedAt;
    }
} 