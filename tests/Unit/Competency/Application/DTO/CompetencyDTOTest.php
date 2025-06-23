<?php

declare(strict_types=1);

namespace Tests\Unit\Competency\Application\DTO;

use App\Competency\Application\DTO\CompetencyDTO;
use App\Competency\Domain\Competency;
use App\Competency\Domain\ValueObjects\CompetencyCategory;
use App\Competency\Domain\ValueObjects\CompetencyCode;
use App\Competency\Domain\ValueObjects\CompetencyId;
use PHPUnit\Framework\TestCase;

class CompetencyDTOTest extends TestCase
{
    public function testCreateFromArray(): void
    {
        $data = [
            'id' => '123e4567-e89b-12d3-a456-426614174000',
            'code' => 'TECH-001',
            'name' => 'PHP Development',
            'description' => 'PHP programming skills',
            'category' => 'technical',
            'parent_id' => null,
            'is_active' => true
        ];
        
        $dto = CompetencyDTO::fromArray($data);
        
        $this->assertEquals('123e4567-e89b-12d3-a456-426614174000', $dto->id);
        $this->assertEquals('TECH-001', $dto->code);
        $this->assertEquals('PHP Development', $dto->name);
        $this->assertEquals('PHP programming skills', $dto->description);
        $this->assertEquals('technical', $dto->category);
        $this->assertNull($dto->parentId);
        $this->assertTrue($dto->isActive);
    }
    
    public function testCreateFromDomainEntity(): void
    {
        $competency = Competency::create(
            id: CompetencyId::generate(),
            code: CompetencyCode::fromString('TECH-001'),
            name: 'PHP Development',
            description: 'PHP programming skills',
            category: CompetencyCategory::technical()
        );
        
        $dto = CompetencyDTO::fromEntity($competency);
        
        $this->assertEquals($competency->getId()->getValue(), $dto->id);
        $this->assertEquals('TECH-001', $dto->code);
        $this->assertEquals('PHP Development', $dto->name);
        $this->assertEquals('PHP programming skills', $dto->description);
        $this->assertEquals('technical', $dto->category);
        $this->assertNull($dto->parentId);
        $this->assertTrue($dto->isActive);
    }
    
    public function testToArray(): void
    {
        $dto = new CompetencyDTO(
            id: '123e4567-e89b-12d3-a456-426614174000',
            code: 'TECH-001',
            name: 'PHP Development',
            description: 'PHP programming skills',
            category: 'technical',
            parentId: null,
            isActive: true
        );
        
        $array = $dto->toArray();
        
        $this->assertEquals([
            'id' => '123e4567-e89b-12d3-a456-426614174000',
            'code' => 'TECH-001',
            'name' => 'PHP Development',
            'description' => 'PHP programming skills',
            'category' => 'technical',
            'parent_id' => null,
            'is_active' => true
        ], $array);
    }
    
    public function testWithParentId(): void
    {
        $parentCompetency = Competency::create(
            id: CompetencyId::generate(),
            code: CompetencyCode::fromString('TECH-000'),
            name: 'Technology',
            description: 'General tech skills',
            category: CompetencyCategory::technical()
        );
        
        $childCompetency = Competency::create(
            id: CompetencyId::generate(),
            code: CompetencyCode::fromString('TECH-001'),
            name: 'PHP Development',
            description: 'PHP programming skills',
            category: CompetencyCategory::technical(),
            parentId: $parentCompetency->getId()
        );
        
        $dto = CompetencyDTO::fromEntity($childCompetency);
        
        $this->assertEquals($parentCompetency->getId()->getValue(), $dto->parentId);
    }
} 