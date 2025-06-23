<?php

declare(strict_types=1);

namespace App\Position\Domain\Service;

use App\Position\Domain\CareerPath;

class CareerProgressionService
{
    private const ELIGIBILITY_THRESHOLD_PERCENT = 90;
    
    /**
     * Calculate progress percentage (0-100)
     */
    public function calculateProgress(CareerPath $careerPath, int $monthsCompleted): int
    {
        if ($monthsCompleted <= 0) {
            return 0;
        }
        
        $estimatedDuration = $careerPath->getEstimatedDuration();
        if ($monthsCompleted >= $estimatedDuration) {
            return 100;
        }
        
        return (int) round(($monthsCompleted / $estimatedDuration) * 100);
    }
    
    /**
     * Get remaining months in career path
     */
    public function getRemainingMonths(CareerPath $careerPath, int $monthsCompleted): int
    {
        $remaining = $careerPath->getEstimatedDuration() - $monthsCompleted;
        return max(0, $remaining);
    }
    
    /**
     * Check if eligible for promotion (>= 90% progress)
     */
    public function isEligibleForPromotion(CareerPath $careerPath, int $monthsCompleted): bool
    {
        $progress = $this->calculateProgress($careerPath, $monthsCompleted);
        return $progress >= self::ELIGIBILITY_THRESHOLD_PERCENT;
    }
    
    /**
     * Get next milestone to achieve
     */
    public function getNextMilestone(CareerPath $careerPath, int $monthsCompleted): ?array
    {
        $milestones = $careerPath->getMilestones();
        
        foreach ($milestones as $milestone) {
            if ($milestone['monthsFromStart'] > $monthsCompleted) {
                return $milestone;
            }
        }
        
        return null;
    }
    
    /**
     * Get completed milestones
     * @return array[]
     */
    public function getCompletedMilestones(CareerPath $careerPath, int $monthsCompleted): array
    {
        $milestones = $careerPath->getMilestones();
        $completed = [];
        
        foreach ($milestones as $milestone) {
            if ($milestone['monthsFromStart'] <= $monthsCompleted) {
                $completed[] = $milestone;
            }
        }
        
        return $completed;
    }
    
    /**
     * Get estimated completion date
     */
    public function getEstimatedCompletionDate(
        CareerPath $careerPath, 
        \DateTimeImmutable $startDate,
        int $monthsCompleted
    ): \DateTimeImmutable {
        $remainingMonths = $this->getRemainingMonths($careerPath, $monthsCompleted);
        return $startDate->modify("+{$remainingMonths} months");
    }
    
    /**
     * Check if career path is overdue
     */
    public function isOverdue(CareerPath $careerPath, int $monthsCompleted): bool
    {
        return $monthsCompleted > $careerPath->getEstimatedDuration();
    }
} 