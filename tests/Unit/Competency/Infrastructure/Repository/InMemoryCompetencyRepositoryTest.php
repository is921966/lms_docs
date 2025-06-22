<?php

declare(strict_types=1);

namespace Tests\Unit\Competency\Infrastructure\Repository;

use App\Competency\Domain\Competency;
use App\Competency\Domain\Repository\CompetencyRepositoryInterface;
use App\Competency\Domain\ValueObjects\CompetencyCategory;
use App\Competency\Domain\ValueObjects\CompetencyCode;
use App\Competency\Domain\ValueObjects\CompetencyId;
use App\Competency\Infrastructure\Repository\InMemoryCompetencyRepository;
use PHPUnit\Framework\TestCase;

class InMemoryCompetencyRepositoryTest extends TestCase
{
    private CompetencyRepositoryInterface $repository;
    
    protected function setUp(): void
    {
        $this->repository = new InMemoryCompetencyRepository();
    }
    
    public function testSaveAndFindById(): void
    {
        $competency = $this->createCompetency();
        $this->repository->save($competency);
        
        $found = $this->repository->findById($competency->getId());
        
        $this->assertNotNull($found);
        $this->assertEquals($competency->getId(), $found->getId());
        $this->assertEquals($competency->getName(), $found->getName());
    }
    
    public function testFindByIdReturnsNullWhenNotFound(): void
    {
        $result = $this->repository->findById(CompetencyId::generate());
        
        $this->assertNull($result);
    }
    
    public function testFindByCode(): void
    {
        $competency = $this->createCompetency();
        $this->repository->save($competency);
        
        $found = $this->repository->findByCode($competency->getCode());
        
        $this->assertNotNull($found);
        $this->assertEquals($competency->getCode(), $found->getCode());
    }
    
    public function testFindByCategory(): void
    {
        $technical1 = $this->createCompetency('TECH-001', CompetencyCategory::technical());
        $technical2 = $this->createCompetency('TECH-002', CompetencyCategory::technical());
        $soft = $this->createCompetency('SOFT-001', CompetencyCategory::soft());
        
        $this->repository->save($technical1);
        $this->repository->save($technical2);
        $this->repository->save($soft);
        
        $technicalCompetencies = $this->repository->findByCategory(CompetencyCategory::technical());
        
        $this->assertCount(2, $technicalCompetencies);
        $this->assertTrue($this->hasCompetencyWithCode($technicalCompetencies, 'TECH-001'));
        $this->assertTrue($this->hasCompetencyWithCode($technicalCompetencies, 'TECH-002'));
    }
    
    public function testFindActive(): void
    {
        $active1 = $this->createCompetency('COMP-001');
        $active2 = $this->createCompetency('COMP-002');
        $inactive = $this->createCompetency('COMP-003');
        $inactive->deactivate();
        
        $this->repository->save($active1);
        $this->repository->save($active2);
        $this->repository->save($inactive);
        
        $activeCompetencies = $this->repository->findActive();
        
        $this->assertCount(2, $activeCompetencies);
        $this->assertTrue($this->hasCompetencyWithCode($activeCompetencies, 'COMP-001'));
        $this->assertTrue($this->hasCompetencyWithCode($activeCompetencies, 'COMP-002'));
    }
    
    public function testFindChildren(): void
    {
        $parent = $this->createCompetency('PARENT-001');
        $child1 = $this->createCompetency('CHILD-001', CompetencyCategory::technical(), $parent->getId());
        $child2 = $this->createCompetency('CHILD-002', CompetencyCategory::technical(), $parent->getId());
        $unrelated = $this->createCompetency('OTHER-001');
        
        $this->repository->save($parent);
        $this->repository->save($child1);
        $this->repository->save($child2);
        $this->repository->save($unrelated);
        
        $children = $this->repository->findChildren($parent->getId());
        
        $this->assertCount(2, $children);
        $this->assertTrue($this->hasCompetencyWithCode($children, 'CHILD-001'));
        $this->assertTrue($this->hasCompetencyWithCode($children, 'CHILD-002'));
    }
    
    public function testSearch(): void
    {
        $php = $this->createCompetency('TECH-PHP', CompetencyCategory::technical(), null, 'PHP Development', 'Skills in PHP programming');
        $javascript = $this->createCompetency('TECH-JS', CompetencyCategory::technical(), null, 'JavaScript', 'Frontend development skills');
        $communication = $this->createCompetency('SOFT-COMM', CompetencyCategory::soft(), null, 'Communication', 'Effective communication');
        
        $this->repository->save($php);
        $this->repository->save($javascript);
        $this->repository->save($communication);
        
        // Search by name
        $results = $this->repository->search('PHP');
        $this->assertCount(1, $results);
        $this->assertEquals('TECH-PHP', $results[0]->getCode()->getValue());
        
        // Search by description
        $results = $this->repository->search('development');
        $this->assertCount(2, $results);
        
        // Case insensitive search
        $results = $this->repository->search('communication');
        $this->assertCount(1, $results);
    }
    
    public function testExistsByCode(): void
    {
        $competency = $this->createCompetency();
        $this->repository->save($competency);
        
        $this->assertTrue($this->repository->existsByCode($competency->getCode()));
        $this->assertFalse($this->repository->existsByCode(CompetencyCode::fromString('NON-EXISTENT')));
    }
    
    public function testGetNextCode(): void
    {
        $this->repository->save($this->createCompetency('TECH-001'));
        $this->repository->save($this->createCompetency('TECH-002'));
        $this->repository->save($this->createCompetency('TECH-005'));
        
        $nextCode = $this->repository->getNextCode('TECH');
        
        $this->assertEquals('TECH-006', $nextCode->getValue());
    }
    
    public function testGetNextCodeForNewPrefix(): void
    {
        $nextCode = $this->repository->getNextCode('NEW');
        
        $this->assertEquals('NEW-001', $nextCode->getValue());
    }
    
    public function testDelete(): void
    {
        $competency = $this->createCompetency();
        $this->repository->save($competency);
        
        $this->repository->delete($competency->getId());
        
        // Should be soft deleted (deactivated)
        $found = $this->repository->findById($competency->getId());
        $this->assertNotNull($found);
        $this->assertFalse($found->isActive());
    }
    
    public function testUpdateExistingCompetency(): void
    {
        $competency = $this->createCompetency();
        $this->repository->save($competency);
        
        $competency->update('Updated Name', 'Updated Description');
        $this->repository->save($competency);
        
        $found = $this->repository->findById($competency->getId());
        $this->assertEquals('Updated Name', $found->getName());
        $this->assertEquals('Updated Description', $found->getDescription());
    }
    
    private function createCompetency(
        string $code = 'TECH-001',
        ?CompetencyCategory $category = null,
        ?CompetencyId $parentId = null,
        string $name = 'Test Competency',
        string $description = 'Test Description'
    ): Competency {
        $competency = Competency::create(
            id: CompetencyId::generate(),
            code: CompetencyCode::fromString($code),
            name: $name,
            description: $description,
            category: $category ?? CompetencyCategory::technical(),
            parentId: $parentId
        );
        
        $competency->pullDomainEvents(); // Clear events for cleaner tests
        
        return $competency;
    }
    
    private function hasCompetencyWithCode(array $competencies, string $code): bool
    {
        foreach ($competencies as $competency) {
            if ($competency->getCode()->getValue() === $code) {
                return true;
            }
        }
        return false;
    }
} 