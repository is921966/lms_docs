<?php

declare(strict_types=1);

namespace Tests\Unit\Position\Infrastructure\Repository;

use App\Position\Infrastructure\Repository\InMemoryPositionProfileRepository;
use App\Position\Domain\PositionProfile;
use App\Position\Domain\ValueObjects\PositionId;
use App\Competency\Domain\ValueObjects\CompetencyId;
use App\Competency\Domain\ValueObjects\CompetencyLevel;
use PHPUnit\Framework\TestCase;

class InMemoryPositionProfileRepositoryTest extends TestCase
{
    private InMemoryPositionProfileRepository $repository;
    
    protected function setUp(): void
    {
        $this->repository = new InMemoryPositionProfileRepository();
    }
    
    public function testSaveAndFindByPositionId(): void
    {
        $profile = $this->createProfile();
        
        $this->repository->save($profile);
        
        $found = $this->repository->findByPositionId($profile->getPositionId());
        
        $this->assertNotNull($found);
        $this->assertTrue($profile->getPositionId()->equals($found->getPositionId()));
        $this->assertEquals($profile->getResponsibilities(), $found->getResponsibilities());
    }
    
    public function testFindByPositionIdReturnsNullWhenNotFound(): void
    {
        $result = $this->repository->findByPositionId(PositionId::generate());
        
        $this->assertNull($result);
    }
    
    public function testFindByCompetencyId(): void
    {
        $competencyId = CompetencyId::generate();
        
        $profile1 = $this->createProfile();
        $profile1->addRequiredCompetency($competencyId, CompetencyLevel::intermediate());
        
        $profile2 = $this->createProfile(PositionId::generate());
        $profile2->addDesiredCompetency($competencyId, CompetencyLevel::beginner());
        
        $profile3 = $this->createProfile(PositionId::generate());
        // This profile doesn't require the competency
        
        $this->repository->save($profile1);
        $this->repository->save($profile2);
        $this->repository->save($profile3);
        
        $results = $this->repository->findByCompetencyId($competencyId);
        
        $this->assertCount(2, $results);
        $this->assertContains($profile1, $results);
        $this->assertContains($profile2, $results);
        $this->assertNotContains($profile3, $results);
    }
    
    public function testFindAll(): void
    {
        $profile1 = $this->createProfile();
        $profile2 = $this->createProfile(PositionId::generate());
        $profile3 = $this->createProfile(PositionId::generate());
        
        $this->repository->save($profile1);
        $this->repository->save($profile2);
        $this->repository->save($profile3);
        
        $results = $this->repository->findAll();
        
        $this->assertCount(3, $results);
        $this->assertContains($profile1, $results);
        $this->assertContains($profile2, $results);
        $this->assertContains($profile3, $results);
    }
    
    public function testUpdateExistingProfile(): void
    {
        $profile = $this->createProfile();
        $this->repository->save($profile);
        
        $profile->updateResponsibilities(['New responsibility 1', 'New responsibility 2']);
        $this->repository->save($profile);
        
        $found = $this->repository->findByPositionId($profile->getPositionId());
        
        $this->assertCount(2, $found->getResponsibilities());
        $this->assertContains('New responsibility 1', $found->getResponsibilities());
    }
    
    public function testDelete(): void
    {
        $profile = $this->createProfile();
        $this->repository->save($profile);
        
        $this->assertNotNull($this->repository->findByPositionId($profile->getPositionId()));
        
        $this->repository->delete($profile->getPositionId());
        
        $this->assertNull($this->repository->findByPositionId($profile->getPositionId()));
    }
    
    public function testExists(): void
    {
        $profile = $this->createProfile();
        $this->repository->save($profile);
        
        $this->assertTrue($this->repository->exists($profile->getPositionId()));
        $this->assertFalse($this->repository->exists(PositionId::generate()));
    }
    
    public function testCountByCompetencyId(): void
    {
        $competencyId1 = CompetencyId::generate();
        $competencyId2 = CompetencyId::generate();
        
        $profile1 = $this->createProfile();
        $profile1->addRequiredCompetency($competencyId1, CompetencyLevel::intermediate());
        
        $profile2 = $this->createProfile(PositionId::generate());
        $profile2->addRequiredCompetency($competencyId1, CompetencyLevel::intermediate());
        $profile2->addDesiredCompetency($competencyId2, CompetencyLevel::beginner());
        
        $this->repository->save($profile1);
        $this->repository->save($profile2);
        
        $this->assertEquals(2, $this->repository->countByCompetencyId($competencyId1));
        $this->assertEquals(1, $this->repository->countByCompetencyId($competencyId2));
        $this->assertEquals(0, $this->repository->countByCompetencyId(CompetencyId::generate()));
    }
    
    private function createProfile(?PositionId $positionId = null): PositionProfile
    {
        return PositionProfile::create(
            positionId: $positionId ?? PositionId::generate(),
            responsibilities: ['Test responsibility 1', 'Test responsibility 2'],
            requirements: ['Test requirement 1', 'Test requirement 2']
        );
    }
} 