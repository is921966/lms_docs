<?php

namespace CompetencyService\Tests\Unit\Application;

use PHPUnit\Framework\TestCase;
use CompetencyService\Application\Services\CompetencyService;
use CompetencyService\Application\DTOs\CreateCompetencyDTO;
use CompetencyService\Application\DTOs\UpdateCompetencyDTO;
use CompetencyService\Application\DTOs\CompetencyDTO;
use CompetencyService\Domain\Repositories\CompetencyRepositoryInterface;
use CompetencyService\Domain\Entities\Competency;
use CompetencyService\Domain\ValueObjects\CompetencyId;
use CompetencyService\Domain\ValueObjects\CompetencyCode;

class CompetencyServiceTest extends TestCase
{
    private CompetencyRepositoryInterface $repository;
    private CompetencyService $service;
    
    protected function setUp(): void
    {
        $this->repository = $this->createMock(CompetencyRepositoryInterface::class);
        $this->service = new CompetencyService($this->repository);
    }
    
    public function testCreateCompetency(): void
    {
        // Arrange
        $dto = new CreateCompetencyDTO(
            code: 'TECH-001',
            name: 'Software Development',
            description: 'Ability to develop software',
            category: 'Technical'
        );
        
        $this->repository->expects($this->once())
            ->method('findByCode')
            ->willReturn(null);
            
        $this->repository->expects($this->once())
            ->method('save');
        
        // Act
        $result = $this->service->createCompetency($dto);
        
        // Assert
        $this->assertInstanceOf(CompetencyDTO::class, $result);
        $this->assertEquals('TECH-001', $result->code);
        $this->assertEquals('Software Development', $result->name);
    }
    
    public function testCreateCompetencyWithDuplicateCode(): void
    {
        // Arrange
        $dto = new CreateCompetencyDTO(
            code: 'TECH-001',
            name: 'Software Development',
            description: 'Ability to develop software',
            category: 'Technical'
        );
        
        $existingCompetency = new Competency(
            CompetencyId::generate(),
            new CompetencyCode('TECH-001'),
            'Existing',
            'Existing desc',
            'Technical'
        );
        
        $this->repository->expects($this->once())
            ->method('findByCode')
            ->willReturn($existingCompetency);
        
        // Assert
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Competency with code TECH-001 already exists');
        
        // Act
        $this->service->createCompetency($dto);
    }
    
    public function testUpdateCompetency(): void
    {
        // Arrange
        $competencyId = CompetencyId::generate();
        $competency = new Competency(
            $competencyId,
            new CompetencyCode('TECH-001'),
            'Old Name',
            'Old Description',
            'Technical'
        );
        
        $dto = new UpdateCompetencyDTO(
            id: $competencyId->toString(),
            name: 'New Name',
            description: 'New Description'
        );
        
        $this->repository->expects($this->once())
            ->method('findById')
            ->willReturn($competency);
            
        $this->repository->expects($this->once())
            ->method('save');
        
        // Act
        $result = $this->service->updateCompetency($dto);
        
        // Assert
        $this->assertEquals('New Name', $result->name);
        $this->assertEquals('New Description', $result->description);
    }
    
    public function testGetCompetencyById(): void
    {
        // Arrange
        $competencyId = CompetencyId::generate();
        $competency = new Competency(
            $competencyId,
            new CompetencyCode('TECH-001'),
            'Software Development',
            'Description',
            'Technical'
        );
        
        $this->repository->expects($this->once())
            ->method('findById')
            ->willReturn($competency);
        
        // Act
        $result = $this->service->getCompetencyById($competencyId->toString());
        
        // Assert
        $this->assertInstanceOf(CompetencyDTO::class, $result);
        $this->assertEquals($competencyId->toString(), $result->id);
    }
    
    public function testGetAllCompetencies(): void
    {
        // Arrange
        $competencies = [
            new Competency(
                CompetencyId::generate(),
                new CompetencyCode('TECH-001'),
                'Competency 1',
                'Description 1',
                'Technical'
            ),
            new Competency(
                CompetencyId::generate(),
                new CompetencyCode('SOFT-001'),
                'Competency 2',
                'Description 2',
                'Soft Skills'
            )
        ];
        
        $this->repository->expects($this->once())
            ->method('findAll')
            ->willReturn($competencies);
        
        // Act
        $result = $this->service->getAllCompetencies();
        
        // Assert
        $this->assertCount(2, $result);
        $this->assertInstanceOf(CompetencyDTO::class, $result[0]);
        $this->assertInstanceOf(CompetencyDTO::class, $result[1]);
    }
} 