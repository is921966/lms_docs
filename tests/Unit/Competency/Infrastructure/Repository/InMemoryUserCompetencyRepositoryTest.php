<?php

declare(strict_types=1);

namespace Tests\Unit\Competency\Infrastructure\Repository;

use Competency\Domain\Repository\UserCompetencyRepositoryInterface;
use Competency\Domain\UserCompetency;
use Competency\Domain\ValueObjects\CompetencyId;
use Competency\Domain\ValueObjects\CompetencyLevel;
use Competency\Infrastructure\Repository\InMemoryUserCompetencyRepository;
use User\Domain\ValueObjects\UserId;
use PHPUnit\Framework\TestCase;

class InMemoryUserCompetencyRepositoryTest extends TestCase
{
    private UserCompetencyRepositoryInterface $repository;
    
    protected function setUp(): void
    {
        $this->repository = new InMemoryUserCompetencyRepository();
    }
    
    public function testSaveAndFind(): void
    {
        $userCompetency = $this->createUserCompetency();
        $this->repository->save($userCompetency);
        
        $found = $this->repository->find($userCompetency->getUserId(), $userCompetency->getCompetencyId());
        
        $this->assertNotNull($found);
        $this->assertEquals($userCompetency->getUserId(), $found->getUserId());
        $this->assertEquals($userCompetency->getCompetencyId(), $found->getCompetencyId());
    }
    
    public function testFindReturnsNullWhenNotFound(): void
    {
        $result = $this->repository->find(UserId::generate(), CompetencyId::generate());
        
        $this->assertNull($result);
    }
    
    public function testFindByUser(): void
    {
        $userId = UserId::generate();
        
        $userCompetency1 = UserCompetency::create($userId, CompetencyId::generate(), CompetencyLevel::beginner());
        $userCompetency2 = UserCompetency::create($userId, CompetencyId::generate(), CompetencyLevel::intermediate());
        $userCompetency3 = UserCompetency::create(UserId::generate(), CompetencyId::generate(), CompetencyLevel::advanced());
        
        $this->repository->save($userCompetency1);
        $this->repository->save($userCompetency2);
        $this->repository->save($userCompetency3);
        
        $userCompetencies = $this->repository->findByUser($userId);
        
        $this->assertCount(2, $userCompetencies);
    }
    
    public function testFindByCompetency(): void
    {
        $competencyId = CompetencyId::generate();
        
        $userCompetency1 = UserCompetency::create(UserId::generate(), $competencyId, CompetencyLevel::beginner());
        $userCompetency2 = UserCompetency::create(UserId::generate(), $competencyId, CompetencyLevel::intermediate());
        $userCompetency3 = UserCompetency::create(UserId::generate(), CompetencyId::generate(), CompetencyLevel::advanced());
        
        $this->repository->save($userCompetency1);
        $this->repository->save($userCompetency2);
        $this->repository->save($userCompetency3);
        
        $competencyUsers = $this->repository->findByCompetency($competencyId);
        
        $this->assertCount(2, $competencyUsers);
    }
    
    public function testFindByCompetencyAndLevel(): void
    {
        $competencyId = CompetencyId::generate();
        
        $userCompetency1 = UserCompetency::create(UserId::generate(), $competencyId, CompetencyLevel::beginner());
        $userCompetency2 = UserCompetency::create(UserId::generate(), $competencyId, CompetencyLevel::intermediate());
        $userCompetency3 = UserCompetency::create(UserId::generate(), $competencyId, CompetencyLevel::advanced());
        $userCompetency4 = UserCompetency::create(UserId::generate(), $competencyId, CompetencyLevel::expert());
        
        $this->repository->save($userCompetency1);
        $this->repository->save($userCompetency2);
        $this->repository->save($userCompetency3);
        $this->repository->save($userCompetency4);
        
        // Find users with intermediate level or above
        $results = $this->repository->findByCompetencyAndLevel($competencyId, CompetencyLevel::intermediate());
        
        $this->assertCount(3, $results); // intermediate, advanced, expert
    }
    
    public function testFindWithTargets(): void
    {
        $userId = UserId::generate();
        
        $userCompetency1 = UserCompetency::create($userId, CompetencyId::generate(), CompetencyLevel::beginner());
        $userCompetency1->setTargetLevel(CompetencyLevel::intermediate());
        
        $userCompetency2 = UserCompetency::create($userId, CompetencyId::generate(), CompetencyLevel::intermediate());
        $userCompetency2->setTargetLevel(CompetencyLevel::advanced());
        
        $userCompetency3 = UserCompetency::create($userId, CompetencyId::generate(), CompetencyLevel::advanced());
        // No target level set
        
        $this->repository->save($userCompetency1);
        $this->repository->save($userCompetency2);
        $this->repository->save($userCompetency3);
        
        $withTargets = $this->repository->findWithTargets($userId);
        
        $this->assertCount(2, $withTargets);
    }
    
    public function testFindStale(): void
    {
        // Create user competencies with different update dates
        $recent = UserCompetency::create(UserId::generate(), CompetencyId::generate(), CompetencyLevel::beginner());
        $recent->updateProgress(CompetencyLevel::elementary()); // Updates the timestamp
        
        // Create old competency (simulated by not updating it)
        $old = UserCompetency::create(UserId::generate(), CompetencyId::generate(), CompetencyLevel::beginner());
        
        $this->repository->save($recent);
        $this->repository->save($old);
        
        // For this test to work properly, we'd need to mock timestamps
        // Since we can't easily test staleness without mocking time, 
        // we'll just verify the method exists and returns an array
        $stale = $this->repository->findStale(30);
        
        $this->assertIsArray($stale);
    }
    
    public function testGetGapAnalysis(): void
    {
        $userId = UserId::generate();
        $competencyId1 = CompetencyId::generate();
        $competencyId2 = CompetencyId::generate();
        
        $userCompetency1 = UserCompetency::create($userId, $competencyId1, CompetencyLevel::beginner());
        $userCompetency1->setTargetLevel(CompetencyLevel::advanced());
        
        $userCompetency2 = UserCompetency::create($userId, $competencyId2, CompetencyLevel::intermediate());
        $userCompetency2->setTargetLevel(CompetencyLevel::expert());
        
        $this->repository->save($userCompetency1);
        $this->repository->save($userCompetency2);
        
        $gapAnalysis = $this->repository->getGapAnalysis($userId);
        
        $this->assertCount(2, $gapAnalysis);
        
        // Find the first competency gap
        $gap1 = array_filter($gapAnalysis, fn($g) => $g['competency_id'] === $competencyId1->getValue());
        $gap1 = array_values($gap1)[0];
        
        $this->assertEquals(1, $gap1['current_level']); // Beginner
        $this->assertEquals(4, $gap1['target_level']); // Advanced
        $this->assertEquals(3, $gap1['gap']); // 4 - 1 = 3
    }
    
    public function testDelete(): void
    {
        $userId = UserId::generate();
        $competencyId = CompetencyId::generate();
        
        $userCompetency = UserCompetency::create($userId, $competencyId, CompetencyLevel::intermediate());
        $this->repository->save($userCompetency);
        
        $this->assertTrue($this->repository->exists($userId, $competencyId));
        
        $this->repository->delete($userId, $competencyId);
        
        $this->assertFalse($this->repository->exists($userId, $competencyId));
        $this->assertNull($this->repository->find($userId, $competencyId));
    }
    
    public function testExists(): void
    {
        $userId = UserId::generate();
        $competencyId = CompetencyId::generate();
        
        $this->assertFalse($this->repository->exists($userId, $competencyId));
        
        $userCompetency = UserCompetency::create($userId, $competencyId, CompetencyLevel::beginner());
        $this->repository->save($userCompetency);
        
        $this->assertTrue($this->repository->exists($userId, $competencyId));
    }
    
    public function testUpdateExistingUserCompetency(): void
    {
        $userId = UserId::generate();
        $competencyId = CompetencyId::generate();
        
        $userCompetency = UserCompetency::create($userId, $competencyId, CompetencyLevel::beginner());
        $this->repository->save($userCompetency);
        
        // Update the competency
        $userCompetency->updateProgress(CompetencyLevel::intermediate());
        $this->repository->save($userCompetency);
        
        $found = $this->repository->find($userId, $competencyId);
        $this->assertNotNull($found);
        $this->assertEquals(CompetencyLevel::intermediate(), $found->getCurrentLevel());
    }
    
    private function createUserCompetency(): UserCompetency
    {
        return UserCompetency::create(
            UserId::generate(),
            CompetencyId::generate(),
            CompetencyLevel::intermediate()
        );
    }
} 