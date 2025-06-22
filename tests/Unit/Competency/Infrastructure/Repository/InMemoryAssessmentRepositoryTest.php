<?php

declare(strict_types=1);

namespace Tests\Unit\Competency\Infrastructure\Repository;

use App\Competency\Domain\CompetencyAssessment;
use App\Competency\Domain\Repository\AssessmentRepositoryInterface;
use App\Competency\Domain\ValueObjects\AssessmentScore;
use App\Competency\Domain\ValueObjects\CompetencyId;
use App\Competency\Domain\ValueObjects\CompetencyLevel;
use App\Competency\Infrastructure\Repository\InMemoryAssessmentRepository;
use App\User\Domain\ValueObjects\UserId;
use PHPUnit\Framework\TestCase;

class InMemoryAssessmentRepositoryTest extends TestCase
{
    private AssessmentRepositoryInterface $repository;
    
    protected function setUp(): void
    {
        $this->repository = new InMemoryAssessmentRepository();
    }
    
    public function testSaveAndFindById(): void
    {
        $assessment = $this->createAssessment();
        $this->repository->save($assessment);
        
        $found = $this->repository->findById($assessment->getId());
        
        $this->assertNotNull($found);
        $this->assertEquals($assessment->getId(), $found->getId());
        $this->assertEquals($assessment->getUserId(), $found->getUserId());
    }
    
    public function testFindByIdReturnsNullWhenNotFound(): void
    {
        $result = $this->repository->findById('ASSESS-999');
        
        $this->assertNull($result);
    }
    
    public function testFindByUser(): void
    {
        $userId = UserId::generate();
        $assessment1 = $this->createAssessment('ASSESS-001', $userId);
        $assessment2 = $this->createAssessment('ASSESS-002', $userId);
        $assessment3 = $this->createAssessment('ASSESS-003', UserId::generate());
        
        $this->repository->save($assessment1);
        $this->repository->save($assessment2);
        $this->repository->save($assessment3);
        
        $userAssessments = $this->repository->findByUser($userId);
        
        $this->assertCount(2, $userAssessments);
        $this->assertContains($assessment1->getId(), array_map(fn($a) => $a->getId(), $userAssessments));
        $this->assertContains($assessment2->getId(), array_map(fn($a) => $a->getId(), $userAssessments));
    }
    
    public function testFindByUserAndCompetency(): void
    {
        $userId = UserId::generate();
        $competencyId = CompetencyId::generate();
        
        $assessment1 = $this->createAssessment('ASSESS-001', $userId, $competencyId);
        $assessment2 = $this->createAssessment('ASSESS-002', $userId, $competencyId);
        $assessment3 = $this->createAssessment('ASSESS-003', $userId, CompetencyId::generate());
        
        $this->repository->save($assessment1);
        $this->repository->save($assessment2);
        $this->repository->save($assessment3);
        
        $assessments = $this->repository->findByUserAndCompetency($userId, $competencyId);
        
        $this->assertCount(2, $assessments);
        $this->assertContains($assessment1->getId(), array_map(fn($a) => $a->getId(), $assessments));
        $this->assertContains($assessment2->getId(), array_map(fn($a) => $a->getId(), $assessments));
    }
    
    public function testFindByCompetency(): void
    {
        $competencyId = CompetencyId::generate();
        
        $assessment1 = $this->createAssessment('ASSESS-001', UserId::generate(), $competencyId);
        $assessment2 = $this->createAssessment('ASSESS-002', UserId::generate(), $competencyId);
        $assessment3 = $this->createAssessment('ASSESS-003', UserId::generate(), CompetencyId::generate());
        
        $this->repository->save($assessment1);
        $this->repository->save($assessment2);
        $this->repository->save($assessment3);
        
        $assessments = $this->repository->findByCompetency($competencyId);
        
        $this->assertCount(2, $assessments);
    }
    
    public function testFindByAssessor(): void
    {
        $assessorId = UserId::generate();
        
        $assessment1 = $this->createAssessment('ASSESS-001', UserId::generate(), CompetencyId::generate(), $assessorId);
        $assessment2 = $this->createAssessment('ASSESS-002', UserId::generate(), CompetencyId::generate(), $assessorId);
        $assessment3 = $this->createAssessment('ASSESS-003', UserId::generate(), CompetencyId::generate(), UserId::generate());
        
        $this->repository->save($assessment1);
        $this->repository->save($assessment2);
        $this->repository->save($assessment3);
        
        $assessments = $this->repository->findByAssessor($assessorId);
        
        $this->assertCount(2, $assessments);
    }
    
    public function testGetHistory(): void
    {
        $userId = UserId::generate();
        $competencyId = CompetencyId::generate();
        
        // Create assessments with different dates
        $assessment1 = $this->createAssessmentWithDate('ASSESS-001', $userId, $competencyId, '-30 days');
        $assessment2 = $this->createAssessmentWithDate('ASSESS-002', $userId, $competencyId, '-20 days');
        $assessment3 = $this->createAssessmentWithDate('ASSESS-003', $userId, $competencyId, '-10 days');
        $assessment4 = $this->createAssessmentWithDate('ASSESS-004', $userId, $competencyId, '-5 days');
        
        $this->repository->save($assessment1);
        $this->repository->save($assessment2);
        $this->repository->save($assessment3);
        $this->repository->save($assessment4);
        
        $history = $this->repository->getHistory($userId, $competencyId, 3);
        
        $this->assertCount(3, $history);
        // Should be ordered by date descending
        $this->assertEquals('ASSESS-004', $history[0]->getId());
        $this->assertEquals('ASSESS-003', $history[1]->getId());
        $this->assertEquals('ASSESS-002', $history[2]->getId());
    }
    
    public function testGetLatest(): void
    {
        $userId = UserId::generate();
        $competencyId = CompetencyId::generate();
        
        $assessment1 = $this->createAssessmentWithDate('ASSESS-001', $userId, $competencyId, '-30 days');
        $assessment2 = $this->createAssessmentWithDate('ASSESS-002', $userId, $competencyId, '-5 days');
        $assessment3 = $this->createAssessmentWithDate('ASSESS-003', $userId, $competencyId, '-15 days');
        
        $this->repository->save($assessment1);
        $this->repository->save($assessment2);
        $this->repository->save($assessment3);
        
        $latest = $this->repository->getLatest($userId, $competencyId);
        
        $this->assertNotNull($latest);
        $this->assertEquals('ASSESS-002', $latest->getId());
    }
    
    public function testGetLatestReturnsNullWhenNoAssessments(): void
    {
        $latest = $this->repository->getLatest(UserId::generate(), CompetencyId::generate());
        
        $this->assertNull($latest);
    }
    
    public function testFindPendingConfirmation(): void
    {
        $assessment1 = $this->createAssessment('ASSESS-001');
        $assessment2 = $this->createAssessment('ASSESS-002');
        $assessment3 = $this->createAssessment('ASSESS-003');
        
        // Confirm assessment2
        $assessment2->confirm(UserId::generate());
        
        $this->repository->save($assessment1);
        $this->repository->save($assessment2);
        $this->repository->save($assessment3);
        
        $pending = $this->repository->findPendingConfirmation();
        
        $this->assertCount(2, $pending);
        $this->assertContains($assessment1->getId(), array_map(fn($a) => $a->getId(), $pending));
        $this->assertContains($assessment3->getId(), array_map(fn($a) => $a->getId(), $pending));
    }
    
    public function testGetStatistics(): void
    {
        $userId = UserId::generate();
        
        // Create assessments
        $assessment1 = $this->createAssessment('ASSESS-001', $userId);
        $assessment2 = $this->createAssessment('ASSESS-002', $userId);
        $assessment3 = $this->createAssessment('ASSESS-003', $userId);
        $assessment4 = $this->createAssessment('ASSESS-004', $userId); // Self assessment
        
        // Make assessment4 a self-assessment
        $assessment4 = CompetencyAssessment::create(
            'ASSESS-004',
            CompetencyId::generate(),
            $userId,
            $userId, // Same as userId for self-assessment
            CompetencyLevel::intermediate(),
            AssessmentScore::fromPercentage(70)
        );
        
        // Confirm assessments 1 and 2
        $assessment1->confirm(UserId::generate());
        $assessment2->confirm(UserId::generate());
        
        $this->repository->save($assessment1);
        $this->repository->save($assessment2);
        $this->repository->save($assessment3);
        $this->repository->save($assessment4);
        
        $stats = $this->repository->getStatistics($userId);
        
        $this->assertEquals(4, $stats['total']);
        $this->assertEquals(2, $stats['confirmed']);
        $this->assertEquals(1, $stats['self_assessments']);
        $this->assertEquals(77.5, $stats['average_score']); // (80+80+80+70)/4
    }
    
    public function testHasAssessment(): void
    {
        $userId = UserId::generate();
        $competencyId = CompetencyId::generate();
        
        $assessment = $this->createAssessment('ASSESS-001', $userId, $competencyId);
        $this->repository->save($assessment);
        
        $this->assertTrue($this->repository->hasAssessment($userId, $competencyId));
        $this->assertFalse($this->repository->hasAssessment(UserId::generate(), $competencyId));
        $this->assertFalse($this->repository->hasAssessment($userId, CompetencyId::generate()));
    }
    
    private function createAssessment(
        string $id = 'ASSESS-001',
        ?UserId $userId = null,
        ?CompetencyId $competencyId = null,
        ?UserId $assessorId = null
    ): CompetencyAssessment {
        return CompetencyAssessment::create(
            $id,
            $competencyId ?? CompetencyId::generate(),
            $userId ?? UserId::generate(),
            $assessorId ?? UserId::generate(),
            CompetencyLevel::intermediate(),
            AssessmentScore::fromPercentage(80)
        );
    }
    
    private function createAssessmentWithDate(
        string $id,
        UserId $userId,
        CompetencyId $competencyId,
        string $dateModifier
    ): CompetencyAssessment {
        return CompetencyAssessment::createWithDate(
            $id,
            $competencyId,
            $userId,
            UserId::generate(),
            CompetencyLevel::intermediate(),
            AssessmentScore::fromPercentage(75),
            new \DateTimeImmutable($dateModifier)
        );
    }
} 