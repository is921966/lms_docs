<?php

declare(strict_types=1);

namespace App\Competency\Application\Service;

use App\Competency\Domain\Repository\AssessmentRepositoryInterface;
use App\Competency\Domain\Repository\UserCompetencyRepositoryInterface;
use App\Competency\Domain\Service\CompetencyAssessmentService;
use App\Competency\Domain\UserCompetency;
use App\Competency\Domain\ValueObjects\AssessmentScore;
use App\Competency\Domain\ValueObjects\CompetencyId;
use App\Competency\Domain\ValueObjects\CompetencyLevel;
use App\User\Domain\ValueObjects\UserId;

class AssessmentService
{
    public function __construct(
        private readonly AssessmentRepositoryInterface $assessmentRepository,
        private readonly UserCompetencyRepositoryInterface $userCompetencyRepository,
        private readonly CompetencyAssessmentService $domainService
    ) {
    }
    
    public function createAssessment(
        string $userId,
        string $competencyId,
        string $assessorId,
        string $level,
        int $score,
        ?string $comment = null
    ): array {
        try {
            // Validate level
            $levelObj = match ($level) {
                'beginner' => CompetencyLevel::beginner(),
                'elementary' => CompetencyLevel::elementary(),
                'intermediate' => CompetencyLevel::intermediate(),
                'advanced' => CompetencyLevel::advanced(),
                'expert' => CompetencyLevel::expert(),
                default => throw new \InvalidArgumentException("Invalid level: $level")
            };
            
            // Validate score
            if ($score < 0 || $score > 100) {
                return $this->error('Score must be between 0 and 100');
            }
            
            // Create value objects
            $userIdObj = UserId::fromString($userId);
            $competencyIdObj = CompetencyId::fromString($competencyId);
            $assessorIdObj = UserId::fromString($assessorId);
            $scoreObj = AssessmentScore::fromPercentage($score);
            
            // Create assessment using domain service
            $assessment = $this->domainService->createAssessment(
                competencyId: $competencyIdObj,
                userId: $userIdObj,
                assessorId: $assessorIdObj,
                level: $levelObj,
                score: $scoreObj,
                comment: $comment
            );
            
            // Save assessment
            $this->assessmentRepository->save($assessment);
            
            // Update or create UserCompetency
            $this->updateUserCompetency($userIdObj, $competencyIdObj, $levelObj);
            
            return $this->success([
                'assessment_id' => $assessment->getId(),
                'user_id' => $userId,
                'competency_id' => $competencyId,
                'assessor_id' => $assessorId,
                'level' => $level,
                'score' => $score,
                'comment' => $comment,
                'is_self_assessment' => $assessment->isSelfAssessment(),
                'assessed_at' => $assessment->getAssessedAt()->format('Y-m-d H:i:s')
            ]);
            
        } catch (\Exception $e) {
            return $this->error($e->getMessage());
        }
    }
    
    private function updateUserCompetency(
        UserId $userId,
        CompetencyId $competencyId,
        CompetencyLevel $newLevel
    ): void {
        $userCompetency = $this->userCompetencyRepository->find($userId, $competencyId);
        
        if ($userCompetency === null) {
            // Create new UserCompetency
            $userCompetency = UserCompetency::create($userId, $competencyId, $newLevel);
        } else {
            // Update existing
            $userCompetency->updateProgress($newLevel);
        }
        
        $this->userCompetencyRepository->save($userCompetency);
    }
    
    private function success(array $data = []): array
    {
        return array_merge(['success' => true], $data);
    }
    
    private function error(string $message): array
    {
        return ['success' => false, 'error' => $message];
    }
    
    public function updateAssessment(
        string $assessmentId,
        string $level,
        int $score,
        ?string $comment = null
    ): array {
        try {
            $assessment = $this->assessmentRepository->findById($assessmentId);
            
            if (!$assessment) {
                return $this->error('Assessment not found');
            }
            
            if ($assessment->isConfirmed()) {
                return $this->error('Cannot update confirmed assessment');
            }
            
            // Validate level
            $levelObj = match ($level) {
                'beginner' => CompetencyLevel::beginner(),
                'elementary' => CompetencyLevel::elementary(),
                'intermediate' => CompetencyLevel::intermediate(),
                'advanced' => CompetencyLevel::advanced(),
                'expert' => CompetencyLevel::expert(),
                default => throw new \InvalidArgumentException("Invalid level: $level")
            };
            
            // Validate score
            if ($score < 0 || $score > 100) {
                return $this->error('Score must be between 0 and 100');
            }
            
            $scoreObj = AssessmentScore::fromPercentage($score);
            
            // Update assessment
            $assessment->update($levelObj, $scoreObj, $comment);
            $this->assessmentRepository->save($assessment);
            
            // Update UserCompetency
            $userCompetency = $this->userCompetencyRepository->find(
                $assessment->getUserId(),
                $assessment->getCompetencyId()
            );
            
            if ($userCompetency) {
                $userCompetency->updateProgress($levelObj);
                $this->userCompetencyRepository->save($userCompetency);
            }
            
            return $this->success([
                'assessment_id' => $assessment->getId(),
                'level' => $level,
                'score' => $score,
                'comment' => $comment,
                'updated_at' => (new \DateTimeImmutable())->format('Y-m-d H:i:s')
            ]);
            
        } catch (\Exception $e) {
            return $this->error($e->getMessage());
        }
    }
    
    public function confirmAssessment(
        string $assessmentId,
        string $confirmerId
    ): array {
        try {
            $assessment = $this->assessmentRepository->findById($assessmentId);
            
            if (!$assessment) {
                return $this->error('Assessment not found');
            }
            
            if ($assessment->isConfirmed()) {
                return $this->error('Assessment already confirmed');
            }
            
            $confirmerIdObj = UserId::fromString($confirmerId);
            $assessment->confirm($confirmerIdObj);
            $this->assessmentRepository->save($assessment);
            
            return $this->success([
                'assessment_id' => $assessment->getId(),
                'is_confirmed' => $assessment->isConfirmed(),
                'confirmed_at' => $assessment->getConfirmedAt()?->format('Y-m-d H:i:s'),
                'confirmed_by' => $confirmerId
            ]);
            
        } catch (\Exception $e) {
            return $this->error($e->getMessage());
        }
    }
    
    public function getUserAssessments(string $userId): array
    {
        try {
            $userIdObj = UserId::fromString($userId);
            $assessments = $this->assessmentRepository->findByUser($userIdObj);
            
            $data = array_map(function ($assessment) {
                return [
                    'id' => $assessment->getId(),
                    'user_id' => $assessment->getUserId()->getValue(),
                    'competency_id' => $assessment->getCompetencyId()->getValue(),
                    'level' => strtolower($assessment->getLevel()->getName()),
                    'score' => $assessment->getScore()->getRoundedPercentage(),
                    'assessor_id' => $assessment->getAssessorId()->getValue(),
                    'is_self_assessment' => $assessment->isSelfAssessment(),
                    'is_confirmed' => $assessment->isConfirmed(),
                    'assessed_at' => $assessment->getAssessedAt()->format('Y-m-d H:i:s'),
                    'comment' => $assessment->getComment()
                ];
            }, $assessments);
            
            return $this->success(['data' => $data]);
            
        } catch (\Exception $e) {
            return $this->error($e->getMessage());
        }
    }
    
    public function getAssessmentHistory(
        string $userId,
        string $competencyId,
        int $limit = 10
    ): array {
        try {
            $userIdObj = UserId::fromString($userId);
            $competencyIdObj = CompetencyId::fromString($competencyId);
            
            $assessments = $this->assessmentRepository->getHistory(
                $userIdObj,
                $competencyIdObj,
                $limit
            );
            
            $data = array_map(function ($assessment) {
                return [
                    'id' => $assessment->getId(),
                    'user_id' => $assessment->getUserId()->getValue(),
                    'competency_id' => $assessment->getCompetencyId()->getValue(),
                    'level' => strtolower($assessment->getLevel()->getName()),
                    'score' => $assessment->getScore()->getRoundedPercentage(),
                    'assessor_id' => $assessment->getAssessorId()->getValue(),
                    'is_self_assessment' => $assessment->isSelfAssessment(),
                    'is_confirmed' => $assessment->isConfirmed(),
                    'assessed_at' => $assessment->getAssessedAt()->format('Y-m-d H:i:s'),
                    'comment' => $assessment->getComment()
                ];
            }, $assessments);
            
            return $this->success(['data' => $data]);
            
        } catch (\Exception $e) {
            return $this->error($e->getMessage());
        }
    }
    
    public function getUserCompetencyStats(string $userId): array
    {
        try {
            $userIdObj = UserId::fromString($userId);
            $stats = $this->assessmentRepository->getStatistics($userIdObj);
            
            return $this->success(['stats' => $stats]);
            
        } catch (\Exception $e) {
            return $this->error($e->getMessage());
        }
    }
} 