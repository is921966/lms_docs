<?php

declare(strict_types=1);

namespace App\Position\Application\DTO;

final class CareerProgressDTO
{
    public function __construct(
        public readonly string $employeeId,
        public readonly string $fromPositionId,
        public readonly string $toPositionId,
        public readonly int $monthsCompleted,
        public readonly int $progressPercentage,
        public readonly int $remainingMonths,
        public readonly bool $isEligibleForPromotion,
        public readonly array $completedMilestones,
        public readonly ?array $nextMilestone,
        public readonly array $requirements,
        public readonly \DateTimeImmutable $estimatedCompletionDate
    ) {
    }
    
    public function toArray(): array
    {
        return [
            'employeeId' => $this->employeeId,
            'fromPositionId' => $this->fromPositionId,
            'toPositionId' => $this->toPositionId,
            'monthsCompleted' => $this->monthsCompleted,
            'progressPercentage' => $this->progressPercentage,
            'remainingMonths' => $this->remainingMonths,
            'isEligibleForPromotion' => $this->isEligibleForPromotion,
            'completedMilestones' => $this->completedMilestones,
            'nextMilestone' => $this->nextMilestone,
            'requirements' => $this->requirements,
            'estimatedCompletionDate' => $this->estimatedCompletionDate->format('c')
        ];
    }
}
