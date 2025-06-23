<?php

declare(strict_types=1);

namespace App\Position\Domain;

use App\Position\Domain\Events\PositionArchived;
use App\Position\Domain\Events\PositionCreated;
use App\Position\Domain\Events\PositionUpdated;
use App\Position\Domain\ValueObjects\Department;
use App\Position\Domain\ValueObjects\PositionCode;
use App\Position\Domain\ValueObjects\PositionId;
use App\Position\Domain\ValueObjects\PositionLevel;

class Position
{
    private PositionId $id;
    private PositionCode $code;
    private string $title;
    private Department $department;
    private PositionLevel $level;
    private string $description;
    private ?PositionId $parentId;
    private bool $isActive;
    private \DateTimeImmutable $createdAt;
    private \DateTimeImmutable $updatedAt;
    
    private array $domainEvents = [];
    
    private function __construct(
        PositionId $id,
        PositionCode $code,
        string $title,
        Department $department,
        PositionLevel $level,
        string $description,
        ?PositionId $parentId = null
    ) {
        $this->id = $id;
        $this->code = $code;
        $this->title = $title;
        $this->department = $department;
        $this->level = $level;
        $this->description = $description;
        $this->parentId = $parentId;
        $this->isActive = true;
        $this->createdAt = new \DateTimeImmutable();
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public static function create(
        PositionId $id,
        PositionCode $code,
        string $title,
        Department $department,
        PositionLevel $level,
        string $description,
        ?PositionId $parentId = null
    ): self {
        $position = new self(
            $id,
            $code,
            $title,
            $department,
            $level,
            $description,
            $parentId
        );
        
        $position->recordEvent(
            PositionCreated::occur(
                $id,
                $code->getValue(),
                $title,
                $department->getValue()
            )
        );
        
        return $position;
    }
    
    public function update(
        string $title,
        string $description,
        PositionLevel $level
    ): void {
        $changes = [];
        
        if ($this->title !== $title) {
            $changes['title'] = ['old' => $this->title, 'new' => $title];
            $this->title = $title;
        }
        
        if ($this->description !== $description) {
            $changes['description'] = ['old' => $this->description, 'new' => $description];
            $this->description = $description;
        }
        
        if (!$this->level->equals($level)) {
            $changes['level'] = ['old' => $this->level->getName(), 'new' => $level->getName()];
            $this->level = $level;
        }
        
        if (!empty($changes)) {
            $this->updatedAt = new \DateTimeImmutable();
            $this->recordEvent(PositionUpdated::occur($this->id, $changes));
        }
    }
    
    public function changeParent(PositionId $newParentId): void
    {
        $this->parentId = $newParentId;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function removeParent(): void
    {
        $this->parentId = null;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function archive(): void
    {
        if (!$this->isActive) {
            throw new \DomainException('Position is already archived');
        }
        
        $this->isActive = false;
        $this->updatedAt = new \DateTimeImmutable();
        $this->recordEvent(PositionArchived::occur($this->id));
    }
    
    public function restore(): void
    {
        if ($this->isActive) {
            throw new \DomainException('Position is already active');
        }
        
        $this->isActive = true;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function equals(Position $other): bool
    {
        return $this->id->equals($other->id);
    }
    
    public function getRequiredCompetencyCount(): int
    {
        // This will be implemented when we add PositionProfile
        return 0;
    }
    
    // Domain Events methods
    protected function recordEvent(object $event): void
    {
        $this->domainEvents[] = $event;
    }
    
    public function releaseEvents(): array
    {
        $events = $this->domainEvents;
        $this->domainEvents = [];
        return $events;
    }
    
    // Getters
    public function getId(): PositionId
    {
        return $this->id;
    }
    
    public function getCode(): PositionCode
    {
        return $this->code;
    }
    
    public function getTitle(): string
    {
        return $this->title;
    }
    
    public function getDepartment(): Department
    {
        return $this->department;
    }
    
    public function getLevel(): PositionLevel
    {
        return $this->level;
    }
    
    public function getDescription(): string
    {
        return $this->description;
    }
    
    public function getParentId(): ?PositionId
    {
        return $this->parentId;
    }
    
    public function isActive(): bool
    {
        return $this->isActive;
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
