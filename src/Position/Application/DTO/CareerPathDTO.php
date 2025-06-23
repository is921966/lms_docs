<?php

declare(strict_types=1);

namespace App\Position\Application\DTO;

use App\Position\Domain\CareerPath;

final class CareerPathDTO
{
    public function __construct(
        public readonly string $id,
        public readonly string $fromPositionId,
        public readonly string $toPositionId,
        public readonly array $requirements,
        public readonly int $estimatedDuration,
        public readonly bool $isActive,
        public readonly array $milestones,
        public readonly \DateTimeImmutable $createdAt,
        public readonly \DateTimeImmutable $updatedAt
    ) {
    }
    
    public static function fromDomain(CareerPath $careerPath, string $id): self
    {
        return new self(
            id: $id,
            fromPositionId: $careerPath->getFromPositionId()->getValue(),
            toPositionId: $careerPath->getToPositionId()->getValue(),
            requirements: $careerPath->getRequirements(),
            estimatedDuration: $careerPath->getEstimatedDuration(),
            isActive: $careerPath->isActive(),
            milestones: $careerPath->getMilestones(),
            createdAt: $careerPath->getCreatedAt(),
            updatedAt: $careerPath->getUpdatedAt()
        );
    }
    
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'fromPositionId' => $this->fromPositionId,
            'toPositionId' => $this->toPositionId,
            'requirements' => $this->requirements,
            'estimatedDuration' => $this->estimatedDuration,
            'isActive' => $this->isActive,
            'milestones' => $this->milestones,
            'createdAt' => $this->createdAt->format('c'),
            'updatedAt' => $this->updatedAt->format('c')
        ];
    }
}
