<?php

declare(strict_types=1);

namespace Learning\Domain;

use Learning\Domain\ValueObjects\EnrollmentId;
use Learning\Domain\ValueObjects\EnrollmentStatus;
use Learning\Domain\ValueObjects\CourseId;
use User\Domain\ValueObjects\UserId;

class Enrollment
{
    private EnrollmentId $id;
    private UserId $userId;
    private CourseId $courseId;
    private UserId $enrolledBy;
    private EnrollmentStatus $status;
    private float $progressPercentage = 0.0;
    private ?float $completionScore = null;
    private ?\DateTimeImmutable $expiryDate = null;
    private ?\DateTimeImmutable $activatedAt = null;
    private ?\DateTimeImmutable $completedAt = null;
    private ?\DateTimeImmutable $cancelledAt = null;
    private ?\DateTimeImmutable $expiredAt = null;
    private ?string $cancellationReason = null;
    private \DateTimeImmutable $createdAt;
    private \DateTimeImmutable $updatedAt;
    
    private function __construct(
        EnrollmentId $id,
        UserId $userId,
        CourseId $courseId,
        UserId $enrolledBy
    ) {
        $this->id = $id;
        $this->userId = $userId;
        $this->courseId = $courseId;
        $this->enrolledBy = $enrolledBy;
        $this->status = EnrollmentStatus::PENDING;
        $this->createdAt = new \DateTimeImmutable();
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public static function create(
        UserId $userId,
        CourseId $courseId,
        UserId $enrolledBy
    ): self {
        return new self(
            EnrollmentId::generate(),
            $userId,
            $courseId,
            $enrolledBy
        );
    }
    
    public function activate(): void
    {
        $this->transitionTo(EnrollmentStatus::ACTIVE);
        $this->activatedAt = new \DateTimeImmutable();
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function complete(float $completionScore): void
    {
        if ($completionScore < 0 || $completionScore > 100) {
            throw new \InvalidArgumentException('Completion score must be between 0 and 100');
        }
        
        $this->transitionTo(EnrollmentStatus::COMPLETED);
        $this->completionScore = $completionScore;
        $this->progressPercentage = 100.0;
        $this->completedAt = new \DateTimeImmutable();
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function cancel(string $reason): void
    {
        $this->transitionTo(EnrollmentStatus::CANCELLED);
        $this->cancellationReason = $reason;
        $this->cancelledAt = new \DateTimeImmutable();
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function expire(): void
    {
        $this->transitionTo(EnrollmentStatus::EXPIRED);
        $this->expiredAt = new \DateTimeImmutable();
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function updateProgress(float $percentage): void
    {
        if ($percentage < 0 || $percentage > 100) {
            throw new \InvalidArgumentException('Progress must be between 0 and 100');
        }
        
        if ($this->status !== EnrollmentStatus::ACTIVE) {
            throw new \DomainException('Can only update progress for active enrollments');
        }
        
        $this->progressPercentage = $percentage;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function setExpiryDate(\DateTimeImmutable $expiryDate): void
    {
        $this->expiryDate = $expiryDate;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function isExpired(): bool
    {
        if ($this->expiryDate === null) {
            return false;
        }
        
        return $this->expiryDate < new \DateTimeImmutable();
    }
    
    public function getDurationInDays(): ?int
    {
        if ($this->activatedAt === null) {
            return null;
        }
        
        $endDate = $this->completedAt ?? $this->cancelledAt ?? $this->expiredAt ?? new \DateTimeImmutable();
        $interval = $this->activatedAt->diff($endDate);
        
        return $interval->days;
    }
    
    private function transitionTo(EnrollmentStatus $newStatus): void
    {
        if (!$this->status->canTransitionTo($newStatus)) {
            throw new \DomainException(
                sprintf('Cannot transition from %s to %s', $this->status->value, $newStatus->value)
            );
        }
        
        $this->status = $newStatus;
    }
    
    // Getters
    public function getId(): EnrollmentId
    {
        return $this->id;
    }
    
    public function getUserId(): UserId
    {
        return $this->userId;
    }
    
    public function getCourseId(): CourseId
    {
        return $this->courseId;
    }
    
    public function getEnrolledBy(): UserId
    {
        return $this->enrolledBy;
    }
    
    public function getStatus(): EnrollmentStatus
    {
        return $this->status;
    }
    
    public function getProgressPercentage(): float
    {
        return $this->progressPercentage;
    }
    
    public function getCompletionScore(): ?float
    {
        return $this->completionScore;
    }
    
    public function getExpiryDate(): ?\DateTimeImmutable
    {
        return $this->expiryDate;
    }
    
    public function getActivatedAt(): ?\DateTimeImmutable
    {
        return $this->activatedAt;
    }
    
    public function getCompletedAt(): ?\DateTimeImmutable
    {
        return $this->completedAt;
    }
    
    public function getCancelledAt(): ?\DateTimeImmutable
    {
        return $this->cancelledAt;
    }
    
    public function getExpiredAt(): ?\DateTimeImmutable
    {
        return $this->expiredAt;
    }
    
    public function getCancellationReason(): ?string
    {
        return $this->cancellationReason;
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