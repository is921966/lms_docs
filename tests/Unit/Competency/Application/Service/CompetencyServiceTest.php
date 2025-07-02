<?php

declare(strict_types=1);

namespace Tests\Unit\Competency\Application\Service;

use Competency\Application\Service\CompetencyService;
use Competency\Domain\Competency;
use Competency\Domain\Repository\CompetencyRepositoryInterface;
use Competency\Domain\ValueObjects\CompetencyCategory;
use Competency\Domain\ValueObjects\CompetencyCode;
use Competency\Domain\ValueObjects\CompetencyId;
use Competency\Infrastructure\Repository\InMemoryCompetencyRepository;
use PHPUnit\Framework\TestCase;

class CompetencyServiceTest extends TestCase
{
    private CompetencyService $service;
    private CompetencyRepositoryInterface $repository;
    
    protected function setUp(): void
    {
        $this->repository = new InMemoryCompetencyRepository();
        $this->service = new CompetencyService($this->repository);
    }
    
    public function testCreateCompetency(): void
    {
        $result = $this->service->createCompetency(
            code: 'TECH-001',
            name: 'PHP Development',
            description: 'PHP programming skills',
            category: 'technical'
        );
        
        $this->assertTrue($result['success']);
        $this->assertArrayHasKey('competency_id', $result);
        $this->assertArrayHasKey('code', $result);
        $this->assertEquals('TECH-001', $result['code']);
        $this->assertEquals('PHP Development', $result['name']);
        
        // Verify it was saved
        $saved = $this->repository->findByCode(CompetencyCode::fromString('TECH-001'));
        $this->assertNotNull($saved);
    }
    
    public function testCreateCompetencyWithDuplicateCode(): void
    {
        // First competency
        $this->service->createCompetency(
            code: 'TECH-001',
            name: 'PHP Development',
            description: 'PHP programming skills',
            category: 'technical'
        );
        
        // Try to create with same code
        $result = $this->service->createCompetency(
            code: 'TECH-001',
            name: 'JavaScript Development',
            description: 'JS programming skills',
            category: 'technical'
        );
        
        $this->assertFalse($result['success']);
        $this->assertEquals('Competency with code TECH-001 already exists', $result['error']);
    }
    
    public function testCreateCompetencyWithParent(): void
    {
        // Create parent
        $parentResult = $this->service->createCompetency(
            code: 'TECH-001',
            name: 'Web Development',
            description: 'General web development skills',
            category: 'technical'
        );
        
        // Create child
        $childResult = $this->service->createCompetency(
            code: 'TECH-002',
            name: 'Frontend Development',
            description: 'Frontend specific skills',
            category: 'technical',
            parentId: $parentResult['competency_id']
        );
        
        $this->assertTrue($childResult['success']);
        $this->assertEquals($parentResult['competency_id'], $childResult['parent_id']);
    }
    
    public function testCreateCompetencyWithInvalidCategory(): void
    {
        $result = $this->service->createCompetency(
            code: 'TECH-001',
            name: 'PHP Development',
            description: 'PHP programming skills',
            category: 'invalid_category'
        );
        
        $this->assertFalse($result['success']);
        $this->assertStringContainsString('Invalid category', $result['error']);
    }
    
    public function testUpdateCompetency(): void
    {
        // Create competency
        $createResult = $this->service->createCompetency(
            code: 'TECH-001',
            name: 'PHP Development',
            description: 'PHP programming skills',
            category: 'technical'
        );
        
        // Update it
        $updateResult = $this->service->updateCompetency(
            id: $createResult['competency_id'],
            name: 'Advanced PHP Development',
            description: 'Advanced PHP programming skills'
        );
        
        $this->assertTrue($updateResult['success']);
        $this->assertEquals('Advanced PHP Development', $updateResult['name']);
        $this->assertEquals('Advanced PHP programming skills', $updateResult['description']);
    }
    
    public function testUpdateNonExistentCompetency(): void
    {
        $result = $this->service->updateCompetency(
            id: CompetencyId::generate()->getValue(),
            name: 'Updated Name',
            description: 'Updated Description'
        );
        
        $this->assertFalse($result['success']);
        $this->assertStringContainsString('not found', $result['error']);
    }
    
    public function testDeactivateCompetency(): void
    {
        // Create competency
        $createResult = $this->service->createCompetency(
            code: 'TECH-001',
            name: 'PHP Development',
            description: 'PHP programming skills',
            category: 'technical'
        );
        
        // Deactivate it
        $deactivateResult = $this->service->deactivateCompetency($createResult['competency_id']);
        
        $this->assertTrue($deactivateResult['success']);
        $this->assertFalse($deactivateResult['is_active']);
    }
    
    public function testGetCompetencyById(): void
    {
        // Create competency
        $createResult = $this->service->createCompetency(
            code: 'TECH-001',
            name: 'PHP Development',
            description: 'PHP programming skills',
            category: 'technical'
        );
        
        // Get it
        $result = $this->service->getCompetencyById($createResult['competency_id']);
        
        $this->assertTrue($result['success']);
        $this->assertEquals('TECH-001', $result['data']['code']);
        $this->assertEquals('PHP Development', $result['data']['name']);
    }
    
    public function testGetCompetencyByIdNotFound(): void
    {
        $result = $this->service->getCompetencyById(CompetencyId::generate()->getValue());
        
        $this->assertFalse($result['success']);
        $this->assertStringContainsString('not found', $result['error']);
    }
    
    public function testGetCompetenciesByCategory(): void
    {
        // Create competencies
        $this->service->createCompetency('TECH-001', 'PHP', 'PHP skills', 'technical');
        $this->service->createCompetency('TECH-002', 'JavaScript', 'JS skills', 'technical');
        $this->service->createCompetency('SOFT-001', 'Communication', 'Communication skills', 'soft');
        
        // Get technical competencies
        $result = $this->service->getCompetenciesByCategory('technical');
        
        $this->assertTrue($result['success']);
        $this->assertCount(2, $result['data']);
        $this->assertEquals('TECH-001', $result['data'][0]['code']);
        $this->assertEquals('TECH-002', $result['data'][1]['code']);
    }
    
    public function testGetActiveCompetencies(): void
    {
        // Create competencies
        $comp1 = $this->service->createCompetency('TECH-001', 'PHP', 'PHP skills', 'technical');
        $comp2 = $this->service->createCompetency('TECH-002', 'JavaScript', 'JS skills', 'technical');
        $comp3 = $this->service->createCompetency('TECH-003', 'Python', 'Python skills', 'technical');
        
        // Deactivate one
        $this->service->deactivateCompetency($comp2['competency_id']);
        
        // Get active competencies
        $result = $this->service->getActiveCompetencies();
        
        $this->assertTrue($result['success']);
        $this->assertCount(2, $result['data']);
        
        $codes = array_column($result['data'], 'code');
        $this->assertContains('TECH-001', $codes);
        $this->assertContains('TECH-003', $codes);
        $this->assertNotContains('TECH-002', $codes);
    }
    
    public function testSearchCompetencies(): void
    {
        // Create competencies
        $this->service->createCompetency('TECH-001', 'PHP Development', 'Backend PHP programming', 'technical');
        $this->service->createCompetency('TECH-002', 'JavaScript Development', 'Frontend programming', 'technical');
        $this->service->createCompetency('SOFT-001', 'Team Development', 'Team building skills', 'soft');
        
        // Search for "development"
        $result = $this->service->searchCompetencies('development');
        
        $this->assertTrue($result['success']);
        $this->assertCount(3, $result['data']);
        
        // Search for "PHP"
        $result2 = $this->service->searchCompetencies('PHP');
        
        $this->assertTrue($result2['success']);
        $this->assertCount(1, $result2['data']);
        $this->assertEquals('TECH-001', $result2['data'][0]['code']);
    }
    
    public function testGetCompetencyTree(): void
    {
        // Create parent
        $parent = $this->service->createCompetency('TECH-001', 'Web Development', 'General web dev', 'technical');
        
        // Create children
        $child1 = $this->service->createCompetency(
            'TECH-002', 
            'Frontend', 
            'Frontend skills', 
            'technical',
            $parent['competency_id']
        );
        
        $child2 = $this->service->createCompetency(
            'TECH-003', 
            'Backend', 
            'Backend skills', 
            'technical',
            $parent['competency_id']
        );
        
        // Get tree
        $result = $this->service->getCompetencyTree($parent['competency_id']);
        
        $this->assertTrue($result['success']);
        $this->assertEquals('TECH-001', $result['data']['code']);
        $this->assertCount(2, $result['data']['children']);
        $this->assertEquals('TECH-002', $result['data']['children'][0]['code']);
        $this->assertEquals('TECH-003', $result['data']['children'][1]['code']);
    }
    
    public function testGenerateNextCode(): void
    {
        // Create some competencies
        $this->service->createCompetency('TECH-001', 'PHP', 'PHP skills', 'technical');
        $this->service->createCompetency('TECH-002', 'JavaScript', 'JS skills', 'technical');
        $this->service->createCompetency('TECH-005', 'Python', 'Python skills', 'technical');
        
        // Generate next code
        $result = $this->service->generateNextCode('TECH');
        
        $this->assertTrue($result['success']);
        $this->assertEquals('TECH-006', $result['code']);
    }
    
    public function testBulkCreateCompetencies(): void
    {
        $competencies = [
            ['code' => 'TECH-001', 'name' => 'PHP', 'description' => 'PHP skills', 'category' => 'technical'],
            ['code' => 'TECH-002', 'name' => 'JavaScript', 'description' => 'JS skills', 'category' => 'technical'],
            ['code' => 'SOFT-001', 'name' => 'Communication', 'description' => 'Communication', 'category' => 'soft'],
        ];
        
        $result = $this->service->bulkCreateCompetencies($competencies);
        
        $this->assertTrue($result['success']);
        $this->assertEquals(3, $result['created']);
        $this->assertEquals(0, $result['failed']);
        
        // Verify all were created
        $this->assertNotNull($this->repository->findByCode(CompetencyCode::fromString('TECH-001')));
        $this->assertNotNull($this->repository->findByCode(CompetencyCode::fromString('TECH-002')));
        $this->assertNotNull($this->repository->findByCode(CompetencyCode::fromString('SOFT-001')));
    }
} 