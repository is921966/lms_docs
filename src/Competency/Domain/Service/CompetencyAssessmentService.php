<?php

declare(strict_types=1);

namespace Competency\Domain\Service;

use Competency\Domain\CompetencyAssessment;
use Competency\Domain\ValueObjects\AssessmentScore;
use Competency\Domain\ValueObjects\CompetencyId;
use Competency\Domain\ValueObjects\CompetencyLevel;
use User\Domain\ValueObjects\UserId;

class CompetencyAssessmentService
{
    private const ASSESSMENT_VALIDITY_DAYS = 365;
    private const HIGH_SCORE_THRESHOLD = 80; // Score above this suggests ready for next level
    
    public function createAssessment(
        CompetencyId $competencyId,
        UserId $userId,
        UserId $assessorId,
        CompetencyLevel $level,
        AssessmentScore $score,
        ?string $comment = null
    ): CompetencyAssessment {
        $assessmentId = $this->generateAssessmentId();
        
        return CompetencyAssessment::create(
            id: $assessmentId,
            competencyId: $competencyId,
            userId: $userId,
            assessorId: $assessorId,
            level: $level,
            score: $score,
            comment: $comment
        );
    }
    
    public function calculateProgress(
        CompetencyLevel $fromLevel,
        CompetencyLevel $toLevel
    ): array {
        $gap = $toLevel->getValue() - $fromLevel->getValue();
        
        return [
            'gap' => $gap,
            'percentage' => 0, // Starting percentage
            'from' => $fromLevel->getName(),
            'to' => $toLevel->getName()
        ];
    }
    
    public function calculateProgressWithCurrent(
        CompetencyLevel $startLevel,
        CompetencyLevel $currentLevel,
        CompetencyLevel $targetLevel
    ): array {
        $totalGap = $targetLevel->getValue() - $startLevel->getValue();
        $completed = $currentLevel->getValue() - $startLevel->getValue();
        $remaining = $targetLevel->getValue() - $currentLevel->getValue();
        
        $percentage = $totalGap > 0 
            ? (int) round(($completed / $totalGap) * 100) 
            : 100;
        
        return [
            'total_gap' => $totalGap,
            'completed' => $completed,
            'remaining' => max(0, $remaining),
            'percentage' => min(100, max(0, $percentage))
        ];
    }
    
    public function isAssessmentValid(CompetencyAssessment $assessment): bool
    {
        $daysSinceAssessment = $assessment->getDaysSinceAssessment();
        
        return $daysSinceAssessment <= self::ASSESSMENT_VALIDITY_DAYS;
    }
    
    public function compareAssessments(
        CompetencyAssessment $assessment1,
        CompetencyAssessment $assessment2
    ): array {
        $levelChange = $assessment2->getLevel()->getValue() - $assessment1->getLevel()->getValue();
        $scoreChange = $assessment2->getScore()->getPercentage() - $assessment1->getScore()->getPercentage();
        
        $direction = match (true) {
            $levelChange > 0 => 'improvement',
            $levelChange < 0 => 'regression',
            $scoreChange > 0 => 'improvement',
            $scoreChange < 0 => 'regression',
            default => 'no_change'
        };
        
        return [
            'level_change' => $levelChange,
            'score_change' => $scoreChange,
            'direction' => $direction,
            'is_progress' => $levelChange > 0 || ($levelChange === 0 && $scoreChange > 0)
        ];
    }
    
    public function generateAssessmentId(): string
    {
        $date = date('Ymd');
        $random = str_pad((string) random_int(1, 9999), 4, '0', STR_PAD_LEFT);
        
        return sprintf('ASSESS-%s-%s', $date, $random);
    }
    
    public function recommendNextLevel(CompetencyAssessment $assessment): CompetencyLevel
    {
        $currentLevel = $assessment->getLevel();
        $score = $assessment->getScore()->getPercentage();
        
        // If score is high enough and not at expert level, recommend next level
        if ($score >= self::HIGH_SCORE_THRESHOLD && $currentLevel->getValue() < 5) {
            return match ($currentLevel->getValue()) {
                1 => CompetencyLevel::elementary(),
                2 => CompetencyLevel::intermediate(),
                3 => CompetencyLevel::advanced(),
                4 => CompetencyLevel::expert(),
                default => $currentLevel
            };
        }
        
        // Otherwise, stay at current level
        return $currentLevel;
    }
} 