<?php

namespace CompetencyService\Application\Services;

use CompetencyService\Domain\Repositories\MatrixRepositoryInterface;
use CompetencyService\Domain\Repositories\AssessmentRepositoryInterface;
use CompetencyService\Domain\ValueObjects\MatrixId;
use CompetencyService\Domain\ValueObjects\UserId;
use DomainException;

class MatrixCalculatorService
{
    public function __construct(
        private readonly MatrixRepositoryInterface $matrixRepository,
        private readonly AssessmentRepositoryInterface $assessmentRepository
    ) {}
    
    public function calculateUserMatrixProgress(string $userId, string $matrixId): array
    {
        // Get matrix
        $matrix = $this->matrixRepository->findById(MatrixId::fromString($matrixId));
        
        if ($matrix === null) {
            throw new DomainException("Matrix with id {$matrixId} not found");
        }
        
        // Get user assessments
        $userAssessments = $this->assessmentRepository->findByUser(new UserId($userId));
        
        // Convert to format expected by matrix
        $assessmentData = [];
        foreach ($userAssessments as $assessment) {
            if ($assessment->getStatus() === 'completed' && $assessment->getScore() !== null) {
                $assessmentData[] = [
                    'competency_id' => $assessment->getCompetencyId()->toString(),
                    'level' => $assessment->getScore()->getLevel()
                ];
            }
        }
        
        // Calculate completeness
        $completeness = $matrix->calculateCompleteness($assessmentData);
        
        // Add detailed requirement status
        $requirementDetails = [];
        foreach ($matrix->getRequirements() as $requirement) {
            $competencyId = $requirement->getCompetencyId()->toString();
            $userLevel = 0;
            
            // Find user level for this competency
            foreach ($assessmentData as $data) {
                if ($data['competency_id'] === $competencyId) {
                    $userLevel = $data['level'];
                    break;
                }
            }
            
            $requirementDetails[] = [
                'competency_id' => $competencyId,
                'required_level' => $requirement->getRequiredLevel(),
                'user_level' => $userLevel,
                'type' => $requirement->getType(),
                'is_satisfied' => $requirement->isSatisfiedBy($userLevel),
                'gap' => max(0, $requirement->getRequiredLevel() - $userLevel)
            ];
        }
        
        return [
            'user_id' => $userId,
            'matrix_id' => $matrixId,
            'matrix_name' => $matrix->getName(),
            'position_id' => $matrix->getPositionId(),
            'completeness' => $completeness,
            'requirements' => $requirementDetails,
            'recommendations' => $this->generateRecommendations($requirementDetails),
            'calculated_at' => (new \DateTimeImmutable())->format('Y-m-d H:i:s')
        ];
    }
    
    public function compareUsersForPosition(string $positionId, array $userIds): array
    {
        // Get all matrices for position
        $matrices = $this->matrixRepository->findByPosition($positionId);
        
        if (empty($matrices)) {
            throw new DomainException("No competency matrices found for position {$positionId}");
        }
        
        // Use first active matrix
        $matrix = null;
        foreach ($matrices as $m) {
            if ($m->isActive()) {
                $matrix = $m;
                break;
            }
        }
        
        if ($matrix === null) {
            throw new DomainException("No active competency matrix found for position {$positionId}");
        }
        
        $comparisons = [];
        
        foreach ($userIds as $userId) {
            try {
                $progress = $this->calculateUserMatrixProgress($userId, $matrix->getId()->toString());
                
                $comparisons[] = [
                    'user_id' => $userId,
                    'overall_percentage' => $progress['completeness']['overall_percentage'],
                    'core_percentage' => $progress['completeness']['core_percentage'],
                    'nice_to_have_percentage' => $progress['completeness']['nice_to_have_percentage'],
                    'total_gap' => array_sum(array_column($progress['requirements'], 'gap'))
                ];
            } catch (\Exception $e) {
                $comparisons[] = [
                    'user_id' => $userId,
                    'overall_percentage' => 0,
                    'core_percentage' => 0,
                    'nice_to_have_percentage' => 0,
                    'total_gap' => PHP_INT_MAX,
                    'error' => $e->getMessage()
                ];
            }
        }
        
        // Sort by overall percentage (descending)
        usort($comparisons, function ($a, $b) {
            return $b['overall_percentage'] <=> $a['overall_percentage'];
        });
        
        return [
            'position_id' => $positionId,
            'matrix_id' => $matrix->getId()->toString(),
            'matrix_name' => $matrix->getName(),
            'comparisons' => $comparisons
        ];
    }
    
    public function getCompetencyGapAnalysis(string $userId, string $matrixId): array
    {
        $progress = $this->calculateUserMatrixProgress($userId, $matrixId);
        
        // Group gaps by type
        $gaps = [
            'core' => [],
            'nice-to-have' => [],
            'optional' => []
        ];
        
        foreach ($progress['requirements'] as $req) {
            if ($req['gap'] > 0) {
                $gaps[$req['type']][] = [
                    'competency_id' => $req['competency_id'],
                    'current_level' => $req['user_level'],
                    'required_level' => $req['required_level'],
                    'gap' => $req['gap']
                ];
            }
        }
        
        // Sort gaps by size (largest first)
        foreach ($gaps as &$typeGaps) {
            usort($typeGaps, function ($a, $b) {
                return $b['gap'] <=> $a['gap'];
            });
        }
        
        return [
            'user_id' => $userId,
            'matrix_id' => $matrixId,
            'gaps' => $gaps,
            'priority_gaps' => array_slice($gaps['core'], 0, 5), // Top 5 core gaps
            'total_core_gaps' => count($gaps['core']),
            'total_nice_to_have_gaps' => count($gaps['nice-to-have']),
            'development_plan' => $this->generateDevelopmentPlan($gaps)
        ];
    }
    
    private function generateRecommendations(array $requirementDetails): array
    {
        $recommendations = [];
        
        // Find biggest gaps in core competencies
        $coreGaps = [];
        foreach ($requirementDetails as $req) {
            if ($req['type'] === 'core' && $req['gap'] > 0) {
                $coreGaps[] = $req;
            }
        }
        
        usort($coreGaps, function ($a, $b) {
            return $b['gap'] <=> $a['gap'];
        });
        
        if (!empty($coreGaps)) {
            $recommendations[] = [
                'priority' => 'high',
                'message' => 'Focus on improving core competencies with the largest gaps',
                'competencies' => array_slice(array_column($coreGaps, 'competency_id'), 0, 3)
            ];
        }
        
        // Check for quick wins (gaps of 1 level)
        $quickWins = array_filter($requirementDetails, function ($req) {
            return $req['gap'] === 1;
        });
        
        if (!empty($quickWins)) {
            $recommendations[] = [
                'priority' => 'medium',
                'message' => 'Quick wins: competencies that need only 1 level improvement',
                'competencies' => array_column($quickWins, 'competency_id')
            ];
        }
        
        return $recommendations;
    }
    
    private function generateDevelopmentPlan(array $gaps): array
    {
        $plan = [];
        
        // Phase 1: Critical core competencies
        if (!empty($gaps['core'])) {
            $plan[] = [
                'phase' => 1,
                'duration' => '3-6 months',
                'focus' => 'Core competencies',
                'competencies' => array_slice($gaps['core'], 0, 3)
            ];
        }
        
        // Phase 2: Remaining core + high-priority nice-to-have
        $phase2Competencies = array_merge(
            array_slice($gaps['core'], 3),
            array_slice($gaps['nice-to-have'], 0, 2)
        );
        
        if (!empty($phase2Competencies)) {
            $plan[] = [
                'phase' => 2,
                'duration' => '6-9 months',
                'focus' => 'Complete core competencies and high-priority nice-to-have',
                'competencies' => $phase2Competencies
            ];
        }
        
        // Phase 3: Nice-to-have and optional
        $phase3Competencies = array_merge(
            array_slice($gaps['nice-to-have'], 2),
            $gaps['optional']
        );
        
        if (!empty($phase3Competencies)) {
            $plan[] = [
                'phase' => 3,
                'duration' => '9-12 months',
                'focus' => 'Nice-to-have and optional competencies',
                'competencies' => $phase3Competencies
            ];
        }
        
        return $plan;
    }
} 