<?php

declare(strict_types=1);

namespace Tests\Unit\Competency\Domain;

use App\Competency\Domain\Competency;
use App\Competency\Domain\ValueObjects\CompetencyCategory;
use App\Competency\Domain\ValueObjects\CompetencyCode;
use App\Competency\Domain\ValueObjects\CompetencyId;
use App\Competency\Domain\ValueObjects\CompetencyLevel;
use App\Competency\Domain\Events\CompetencyCreated;
use App\Competency\Domain\Events\CompetencyUpdated;
use App\Competency\Domain\Events\CompetencyDeactivated;
use PHPUnit\Framework\TestCase;

class CompetencyTest extends TestCase
{
    public function testCreateCompetency(): void
    {
        $id = CompetencyId::generate();
        $code = CompetencyCode::fromString('TECH-PHP-001');
        $category = CompetencyCategory::technical();
        
        $competency = Competency::create(
            id: $id,
            code: $code,
            name: 'PHP Development',
            description: 'Ability to develop applications using PHP',
            category: $category
        );
        
        $this->assertEquals($id, $competency->getId());
        $this->assertEquals($code, $competency->getCode());
        $this->assertEquals('PHP Development', $competency->getName());
        $this->assertEquals('Ability to develop applications using PHP', $competency->getDescription());
        $this->assertEquals($category, $competency->getCategory());
        $this->assertTrue($competency->isActive());
        $this->assertNull($competency->getParentId());
        $this->assertCount(5, $competency->getLevels()); // Default levels
        
        // Check domain event
        $events = $competency->pullDomainEvents();
        $this->assertCount(1, $events);
        $this->assertInstanceOf(CompetencyCreated::class, $events[0]);
    }
    
    public function testCreateCompetencyWithParent(): void
    {
        $parentId = CompetencyId::generate();
        $competency = Competency::create(
            id: CompetencyId::generate(),
            code: CompetencyCode::fromString('TECH-PHP-002'),
            name: 'Laravel Framework',
            description: 'Expertise in Laravel framework',
            category: CompetencyCategory::technical(),
            parentId: $parentId
        );
        
        $this->assertEquals($parentId, $competency->getParentId());
    }
    
    public function testCreateCompetencyWithCustomLevels(): void
    {
        $customLevels = [
            CompetencyLevel::beginner(),
            CompetencyLevel::intermediate(),
            CompetencyLevel::expert()
        ];
        
        $competency = Competency::create(
            id: CompetencyId::generate(),
            code: CompetencyCode::fromString('SOFT-COMM-001'),
            name: 'Communication',
            description: 'Effective communication skills',
            category: CompetencyCategory::soft(),
            levels: $customLevels
        );
        
        $this->assertCount(3, $competency->getLevels());
        $this->assertEquals($customLevels, $competency->getLevels());
    }
    
    public function testUpdateCompetency(): void
    {
        $competency = $this->createSampleCompetency();
        $competency->pullDomainEvents(); // Clear creation event
        
        $competency->update(
            name: 'Updated PHP Development',
            description: 'Updated description'
        );
        
        $this->assertEquals('Updated PHP Development', $competency->getName());
        $this->assertEquals('Updated description', $competency->getDescription());
        
        // Check domain event
        $events = $competency->pullDomainEvents();
        $this->assertCount(1, $events);
        $this->assertInstanceOf(CompetencyUpdated::class, $events[0]);
    }
    
    public function testChangeCategory(): void
    {
        $competency = $this->createSampleCompetency();
        $competency->pullDomainEvents(); // Clear creation event
        $newCategory = CompetencyCategory::business();
        
        $competency->changeCategory($newCategory);
        
        $this->assertEquals($newCategory, $competency->getCategory());
        
        $events = $competency->pullDomainEvents();
        $this->assertCount(1, $events);
        $this->assertInstanceOf(CompetencyUpdated::class, $events[0]);
    }
    
    public function testDeactivateCompetency(): void
    {
        $competency = $this->createSampleCompetency();
        $competency->pullDomainEvents(); // Clear creation event
        
        $competency->deactivate();
        
        $this->assertFalse($competency->isActive());
        
        $events = $competency->pullDomainEvents();
        $this->assertCount(1, $events);
        $this->assertInstanceOf(CompetencyDeactivated::class, $events[0]);
    }
    
    public function testActivateCompetency(): void
    {
        $competency = $this->createSampleCompetency();
        $competency->deactivate();
        $competency->pullDomainEvents(); // Clear events
        
        $competency->activate();
        
        $this->assertTrue($competency->isActive());
        
        $events = $competency->pullDomainEvents();
        $this->assertCount(1, $events);
        $this->assertInstanceOf(CompetencyUpdated::class, $events[0]);
    }
    
    public function testSetParent(): void
    {
        $competency = $this->createSampleCompetency();
        $parentId = CompetencyId::generate();
        
        $competency->setParent($parentId);
        
        $this->assertEquals($parentId, $competency->getParentId());
    }
    
    public function testRemoveParent(): void
    {
        $parentId = CompetencyId::generate();
        $competency = Competency::create(
            id: CompetencyId::generate(),
            code: CompetencyCode::fromString('TECH-PHP-003'),
            name: 'Test',
            description: 'Test',
            category: CompetencyCategory::technical(),
            parentId: $parentId
        );
        
        $competency->removeParent();
        
        $this->assertNull($competency->getParentId());
    }
    
    public function testUpdateLevels(): void
    {
        $competency = $this->createSampleCompetency();
        $newLevels = [
            CompetencyLevel::beginner(),
            CompetencyLevel::expert()
        ];
        
        $competency->updateLevels($newLevels);
        
        $this->assertCount(2, $competency->getLevels());
        $this->assertEquals($newLevels, $competency->getLevels());
    }
    
    public function testCannotUpdateLevelsWithEmptyArray(): void
    {
        $competency = $this->createSampleCompetency();
        
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Competency must have at least one level');
        
        $competency->updateLevels([]);
    }
    
    public function testAddMetadata(): void
    {
        $competency = $this->createSampleCompetency();
        
        $competency->addMetadata('required_experience_years', 5);
        $competency->addMetadata('certification_required', true);
        
        $metadata = $competency->getMetadata();
        $this->assertEquals(5, $metadata['required_experience_years']);
        $this->assertTrue($metadata['certification_required']);
    }
    
    public function testRemoveMetadata(): void
    {
        $competency = $this->createSampleCompetency();
        $competency->addMetadata('test_key', 'test_value');
        
        $competency->removeMetadata('test_key');
        
        $metadata = $competency->getMetadata();
        $this->assertArrayNotHasKey('test_key', $metadata);
    }
    
    public function testIsSubcompetencyOf(): void
    {
        $parentId = CompetencyId::generate();
        $competency = Competency::create(
            id: CompetencyId::generate(),
            code: CompetencyCode::fromString('TECH-PHP-004'),
            name: 'Test',
            description: 'Test',
            category: CompetencyCategory::technical(),
            parentId: $parentId
        );
        
        $this->assertTrue($competency->isSubcompetencyOf($parentId));
        $this->assertFalse($competency->isSubcompetencyOf(CompetencyId::generate()));
    }
    
    public function testGetDefaultLevels(): void
    {
        $competency = $this->createSampleCompetency();
        $levels = $competency->getLevels();
        
        $this->assertCount(5, $levels);
        $this->assertEquals(CompetencyLevel::beginner(), $levels[0]);
        $this->assertEquals(CompetencyLevel::elementary(), $levels[1]);
        $this->assertEquals(CompetencyLevel::intermediate(), $levels[2]);
        $this->assertEquals(CompetencyLevel::advanced(), $levels[3]);
        $this->assertEquals(CompetencyLevel::expert(), $levels[4]);
    }
    
    private function createSampleCompetency(): Competency
    {
        return Competency::create(
            id: CompetencyId::generate(),
            code: CompetencyCode::fromString('TECH-PHP-001'),
            name: 'PHP Development',
            description: 'Ability to develop applications using PHP',
            category: CompetencyCategory::technical()
        );
    }
} 