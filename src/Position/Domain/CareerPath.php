<?php

declare(strict_types=1);

namespace App\Position\Domain;

use App\Position\Domain\ValueObjects\PositionId;

class CareerPath
{
    private PositionId $fromPositionId;
    private PositionId $toPositionId;
    private array $requirements;
    private int $estimatedDuration; // months
    private bool $isActive;
    private array $milestones = [];
    private \DateTimeImmutable $createdAt;
    private \DateTimeImmutable $updatedAt;
    
    private function __construct(
        PositionId $fromPositionId,
        PositionId $toPositionId,
        array $requirements,
        int $estimatedDuration
    ) {
        if ($estimatedDuration <= 0) {
            throw new \InvalidArgumentException('Estimated duration must be positive');
        }
        
        $this->fromPositionId = $fromPositionId;
        $this->toPositionId = $toPositionId;
        $this->requirements = $requirements;
        $this->estimatedDuration = $estimatedDuration;
        $this->isActive = true;
        $this->createdAt = new \DateTimeImmutable();
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public static function create(
        PositionId $fromPositionId,
        PositionId $toPositionId,
        array $requirements,
        int $estimatedDuration
    ): self {
        return new self($fromPositionId, $toPositionId, $requirements, $estimatedDuration);
    }
    
    public function addMilestone(string $title, string $description, int $monthsFromStart): void
    {
        if ($monthsFromStart > $this->estimatedDuration) {
            throw new \DomainException('Milestone cannot be after estimated duration');
        }
        
        if ($monthsFromStart <= 0) {
            throw new \InvalidArgumentException('Milestone time must be positive');
        }
        
        $this->milestones[] = [
            'title' => $title,
            'description' => $description,
            'monthsFromStart' => $monthsFromStart
        ];
        
        // Sort milestones by monthsFromStart
        usort($this->milestones, function ($a, $b) {
            return $a['monthsFromStart'] <=> $b['monthsFromStart'];
        });
        
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function removeMilestone(string $title): void
    {
        $this->milestones = array_values(
            array_filter(
                $this->milestones,
                fn($milestone) => $milestone['title'] !== $title
            )
        );
        
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function updateRequirements(array $requirements): void
    {
        $this->requirements = $requirements;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function updateEstimatedDuration(int $months): void
    {
        if ($months <= 0) {
            throw new \InvalidArgumentException('Estimated duration must be positive');
        }
        
        $this->estimatedDuration = $months;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function activate(): void
    {
        $this->isActive = true;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function deactivate(): void
    {
        $this->isActive = false;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function getDurationInYears(): float
    {
        return round($this->estimatedDuration / 12, 1);
    }
    
    // Getters
    public function getFromPositionId(): PositionId
    {
        return $this->fromPositionId;
    }
    
    public function getToPositionId(): PositionId
    {
        return $this->toPositionId;
    }
    
    public function getRequirements(): array
    {
        return $this->requirements;
    }
    
    public function getEstimatedDuration(): int
    {
        return $this->estimatedDuration;
    }
    
    public function isActive(): bool
    {
        return $this->isActive;
    }
    
    public function getMilestones(): array
    {
        return $this->milestones;
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