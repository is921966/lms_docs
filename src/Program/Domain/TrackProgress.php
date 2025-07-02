<?php

declare(strict_types=1);

namespace Program\Domain;

use Program\Domain\ValueObjects\TrackId;
use User\Domain\ValueObjects\UserId;
use Learning\Domain\ValueObjects\CourseId;

class TrackProgress
{
    private UserId $userId;
    private TrackId $trackId;
    private int $totalCourses;
    /** @var CourseId[] */
    private array $completedCourseIds = [];
    private \DateTimeImmutable $startedAt;
    private ?\DateTimeImmutable $completedAt = null;
    
    private function __construct(
        UserId $userId,
        TrackId $trackId,
        int $totalCourses
    ) {
        if ($totalCourses <= 0) {
            throw new \InvalidArgumentException('Total courses must be greater than zero');
        }
        
        $this->userId = $userId;
        $this->trackId = $trackId;
        $this->totalCourses = $totalCourses;
        $this->startedAt = new \DateTimeImmutable();
    }
    
    public static function create(
        UserId $userId,
        TrackId $trackId,
        int $totalCourses
    ): self {
        return new self($userId, $trackId, $totalCourses);
    }
    
    public function markCourseCompleted(CourseId $courseId): void
    {
        if ($this->hasCourseCompleted($courseId)) {
            throw new \DomainException('Course already completed');
        }
        
        $this->completedCourseIds[] = $courseId;
        
        if ($this->getCompletedCourses() === $this->totalCourses) {
            $this->completedAt = new \DateTimeImmutable();
        }
    }
    
    public function hasCourseCompleted(CourseId $courseId): bool
    {
        foreach ($this->completedCourseIds as $completedId) {
            if ($completedId->equals($courseId)) {
                return true;
            }
        }
        
        return false;
    }
    
    public function reset(): void
    {
        $this->completedCourseIds = [];
        $this->completedAt = null;
        $this->startedAt = new \DateTimeImmutable();
    }
    
    public function getCompletedCourses(): int
    {
        return count($this->completedCourseIds);
    }
    
    public function getProgressPercentage(): int
    {
        if ($this->totalCourses === 0) {
            return 0;
        }
        
        return (int) floor(($this->getCompletedCourses() / $this->totalCourses) * 100);
    }
    
    public function isCompleted(): bool
    {
        return $this->getCompletedCourses() === $this->totalCourses;
    }
    
    // Getters
    public function getUserId(): UserId
    {
        return $this->userId;
    }
    
    public function getTrackId(): TrackId
    {
        return $this->trackId;
    }
    
    public function getTotalCourses(): int
    {
        return $this->totalCourses;
    }
    
    /**
     * @return CourseId[]
     */
    public function getCompletedCourseIds(): array
    {
        return $this->completedCourseIds;
    }
    
    public function getStartedAt(): \DateTimeImmutable
    {
        return $this->startedAt;
    }
    
    public function getCompletedAt(): ?\DateTimeImmutable
    {
        return $this->completedAt;
    }
    
    public function toArray(): array
    {
        return [
            'userId' => $this->userId->getValue(),
            'trackId' => $this->trackId->getValue(),
            'totalCourses' => $this->totalCourses,
            'completedCourses' => $this->getCompletedCourses(),
            'progressPercentage' => $this->getProgressPercentage(),
            'isCompleted' => $this->isCompleted(),
            'completedCourseIds' => array_map(
                fn(CourseId $courseId) => $courseId->getValue(),
                $this->completedCourseIds
            ),
            'startedAt' => $this->startedAt->format('Y-m-d H:i:s'),
            'completedAt' => $this->completedAt?->format('Y-m-d H:i:s')
        ];
    }
} 