<?php

declare(strict_types=1);

namespace Tests\Unit\Competency\Application\DTO;

use App\Competency\Application\DTO\AssessmentDTO;
use App\Competency\Domain\CompetencyAssessment;
use App\Competency\Domain\Service\CompetencyAssessmentService;
use App\Competency\Domain\ValueObjects\AssessmentScore;
use App\Competency\Domain\ValueObjects\CompetencyId;
use App\Competency\Domain\ValueObjects\CompetencyLevel;
use App\User\Domain\ValueObjects\UserId;
use PHPUnit\Framework\TestCase;

class AssessmentDTOTest extends TestCase
{
    public function testCreateFromArray(): void
    {
        $data = [
            'id' => 'assessment-123',
            'user_id' => 'user-456',
            'competency_id' => 'comp-789',
            'assessor_id' => 'assessor-012',
            'level' => 'intermediate',
            'score' => 75,
            'comment' => 'Good progress',
            'is_self_assessment' => false,
            'is_confirmed' => false,
            'assessed_at' => '2025-01-27 10:00:00'
        ];
        
        $dto = AssessmentDTO::fromArray($data);
        
        $this->assertEquals('assessment-123', $dto->id);
        $this->assertEquals('user-456', $dto->userId);
        $this->assertEquals('comp-789', $dto->competencyId);
        $this->assertEquals('assessor-012', $dto->assessorId);
        $this->assertEquals('intermediate', $dto->level);
        $this->assertEquals(75, $dto->score);
        $this->assertEquals('Good progress', $dto->comment);
        $this->assertFalse($dto->isSelfAssessment);
        $this->assertFalse($dto->isConfirmed);
        $this->assertEquals('2025-01-27 10:00:00', $dto->assessedAt);
    }
    
    public function testCreateFromEntity(): void
    {
        $service = new CompetencyAssessmentService();
        $assessment = $service->createAssessment(
            competencyId: CompetencyId::generate(),
            userId: UserId::generate(),
            assessorId: UserId::generate(),
            level: CompetencyLevel::intermediate(),
            score: AssessmentScore::fromPercentage(75),
            comment: 'Good progress'
        );
        
        $dto = AssessmentDTO::fromEntity($assessment);
        
        $this->assertEquals($assessment->getId(), $dto->id);
        $this->assertEquals($assessment->getUserId()->getValue(), $dto->userId);
        $this->assertEquals($assessment->getCompetencyId()->getValue(), $dto->competencyId);
        $this->assertEquals($assessment->getAssessorId()->getValue(), $dto->assessorId);
        $this->assertEquals('intermediate', $dto->level);
        $this->assertEquals(75, $dto->score);
        $this->assertEquals('Good progress', $dto->comment);
        $this->assertFalse($dto->isSelfAssessment);
        $this->assertFalse($dto->isConfirmed);
        $this->assertNotNull($dto->assessedAt);
    }
    
    public function testToArray(): void
    {
        $dto = new AssessmentDTO(
            id: 'assessment-123',
            userId: 'user-456',
            competencyId: 'comp-789',
            assessorId: 'assessor-012',
            level: 'intermediate',
            score: 75,
            comment: 'Good progress',
            isSelfAssessment: false,
            isConfirmed: false,
            assessedAt: '2025-01-27 10:00:00',
            confirmedAt: null,
            confirmedBy: null
        );
        
        $array = $dto->toArray();
        
        $this->assertEquals([
            'id' => 'assessment-123',
            'user_id' => 'user-456',
            'competency_id' => 'comp-789',
            'assessor_id' => 'assessor-012',
            'level' => 'intermediate',
            'score' => 75,
            'comment' => 'Good progress',
            'is_self_assessment' => false,
            'is_confirmed' => false,
            'assessed_at' => '2025-01-27 10:00:00',
            'confirmed_at' => null,
            'confirmed_by' => null
        ], $array);
    }
} 