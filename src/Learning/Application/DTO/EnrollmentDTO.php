<?php

declare(strict_types=1);

namespace Learning\Application\DTO;

use Learning\Domain\Enrollment;
use Learning\Domain\ValueObjects\CourseId;
use User\Domain\ValueObjects\UserId;

final class EnrollmentDTO
{
    public function __construct(
        public readonly ?string $id,
        public readonly string $userId,
        public readonly string $courseId,
        public readonly string $enrolledBy,
        public readonly string $status,
        public readonly float $progressPercentage,
        public readonly ?float $completionScore,
        public readonly ?string $expiryDate,
        public readonly ?string $activatedAt,
        public readonly ?string $completedAt,
        public readonly ?string $cancelledAt,
        public readonly ?string $expiredAt,
        public readonly ?string $cancellationReason,
        public readonly ?string $createdAt = null,
        public readonly ?string $updatedAt = null
    ) {}
    
    public static function fromArray(array $data): self
    {
        return new self(
            id: $data['id'] ?? null,
            userId: $data['userId'],
            courseId: $data['courseId'],
            enrolledBy: $data['enrolledBy'],
            status: $data['status'] ?? 'pending',
            progressPercentage: $data['progressPercentage'] ?? 0.0,
            completionScore: $data['completionScore'] ?? null,
            expiryDate: $data['expiryDate'] ?? null,
            activatedAt: $data['activatedAt'] ?? null,
            completedAt: $data['completedAt'] ?? null,
            cancelledAt: $data['cancelledAt'] ?? null,
            expiredAt: $data['expiredAt'] ?? null,
            cancellationReason: $data['cancellationReason'] ?? null,
            createdAt: $data['createdAt'] ?? null,
            updatedAt: $data['updatedAt'] ?? null
        );
    }
    
    public static function fromEntity(Enrollment $enrollment): self
    {
        return new self(
            id: $enrollment->getId()->getValue(),
            userId: $enrollment->getUserId()->getValue(),
            courseId: $enrollment->getCourseId()->getValue(),
            enrolledBy: $enrollment->getEnrolledBy()->getValue(),
            status: $enrollment->getStatus()->value,
            progressPercentage: $enrollment->getProgressPercentage(),
            completionScore: $enrollment->getCompletionScore(),
            expiryDate: $enrollment->getExpiryDate()?->format('c'),
            activatedAt: $enrollment->getActivatedAt()?->format('c'),
            completedAt: $enrollment->getCompletedAt()?->format('c'),
            cancelledAt: $enrollment->getCancelledAt()?->format('c'),
            expiredAt: $enrollment->getExpiredAt()?->format('c'),
            cancellationReason: $enrollment->getCancellationReason(),
            createdAt: $enrollment->getCreatedAt()->format('c'),
            updatedAt: $enrollment->getUpdatedAt()->format('c')
        );
    }
    
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'userId' => $this->userId,
            'courseId' => $this->courseId,
            'enrolledBy' => $this->enrolledBy,
            'status' => $this->status,
            'progressPercentage' => $this->progressPercentage,
            'completionScore' => $this->completionScore,
            'expiryDate' => $this->expiryDate,
            'activatedAt' => $this->activatedAt,
            'completedAt' => $this->completedAt,
            'cancelledAt' => $this->cancelledAt,
            'expiredAt' => $this->expiredAt,
            'cancellationReason' => $this->cancellationReason,
            'createdAt' => $this->createdAt,
            'updatedAt' => $this->updatedAt,
        ];
    }
    
    public function toNewEntity(): Enrollment
    {
        if ($this->id !== null) {
            throw new \InvalidArgumentException('Cannot create new entity from DTO with ID');
        }
        
        return Enrollment::create(
            userId: UserId::fromString($this->userId),
            courseId: CourseId::fromString($this->courseId),
            enrolledBy: UserId::fromString($this->enrolledBy)
        );
    }
} 