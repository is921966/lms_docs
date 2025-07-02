<?php

declare(strict_types=1);

namespace Tests\Integration\Program;

use Program\Infrastructure\Persistence\InMemoryProgramRepository;
use Program\Domain\Program;
use Program\Domain\ValueObjects\ProgramId;
use Program\Domain\ValueObjects\ProgramCode;
use Program\Domain\ValueObjects\ProgramStatus;
use PHPUnit\Framework\TestCase;

class InMemoryProgramRepositoryTest extends TestCase
{
    private InMemoryProgramRepository $repository;
    
    protected function setUp(): void
    {
        $this->repository = new InMemoryProgramRepository();
    }
    
    public function testCanSaveAndFindProgram(): void
    {
        // Arrange
        $program = Program::create(
            ProgramId::generate(),
            ProgramCode::fromString('LEAD-101'),
            'Leadership Program',
            'Leadership development program'
        );
        
        // Act
        $this->repository->save($program);
        $found = $this->repository->findById($program->getId());
        
        // Assert
        $this->assertNotNull($found);
        $this->assertTrue($program->getId()->equals($found->getId()));
        $this->assertEquals($program->getTitle(), $found->getTitle());
    }
    
    public function testReturnsNullWhenProgramNotFound(): void
    {
        // Arrange
        $id = ProgramId::generate();
        
        // Act
        $found = $this->repository->findById($id);
        
        // Assert
        $this->assertNull($found);
    }
    
    public function testCanFindByCode(): void
    {
        // Arrange
        $code = ProgramCode::fromString('TECH-201');
        $program = Program::create(
            ProgramId::generate(),
            $code,
            'Technical Leadership',
            'Technical leadership program'
        );
        $this->repository->save($program);
        
        // Act
        $found = $this->repository->findByCode($code);
        
        // Assert
        $this->assertNotNull($found);
        $this->assertTrue($code->equals($found->getCode()));
    }
    
    public function testCanFindAllPrograms(): void
    {
        // Arrange
        $program1 = $this->createProgram('PROG-001');
        $program2 = $this->createProgram('PROG-002');
        $program3 = $this->createProgram('PROG-003');
        
        $this->repository->save($program1);
        $this->repository->save($program2);
        $this->repository->save($program3);
        
        // Act
        $all = $this->repository->findAll();
        
        // Assert
        $this->assertCount(3, $all);
    }
    
    public function testCanFindActivePrograms(): void
    {
        // Arrange
        $program1 = $this->createProgram('PROG-001');
        $program2 = $this->createProgram('PROG-002');
        $program3 = $this->createProgram('PROG-003');
        
        $program2->forceStatus(ProgramStatus::active());
        $program3->forceStatus(ProgramStatus::archived());
        
        $this->repository->save($program1);
        $this->repository->save($program2);
        $this->repository->save($program3);
        
        // Act
        $active = $this->repository->findActive();
        
        // Assert
        $this->assertCount(1, $active);
        $this->assertTrue($program2->getId()->equals($active[0]->getId()));
    }
    
    public function testCanDeleteProgram(): void
    {
        // Arrange
        $program = $this->createProgram('PROG-001');
        $this->repository->save($program);
        
        // Act
        $this->repository->delete($program->getId());
        $found = $this->repository->findById($program->getId());
        
        // Assert
        $this->assertNull($found);
    }
    
    public function testCanGenerateNextIdentity(): void
    {
        // Act
        $id1 = $this->repository->nextIdentity();
        $id2 = $this->repository->nextIdentity();
        
        // Assert
        $this->assertInstanceOf(ProgramId::class, $id1);
        $this->assertInstanceOf(ProgramId::class, $id2);
        $this->assertFalse($id1->equals($id2));
    }
    
    public function testUpdatesExistingProgram(): void
    {
        // Arrange
        $program = $this->createProgram('PROG-001');
        $this->repository->save($program);
        
        // Act
        $program->updateBasicInfo('Updated Title', 'Updated Description');
        $this->repository->save($program);
        
        $found = $this->repository->findById($program->getId());
        
        // Assert
        $this->assertEquals('Updated Title', $found->getTitle());
        $this->assertEquals('Updated Description', $found->getDescription());
    }
    
    private function createProgram(string $code): Program
    {
        return Program::create(
            ProgramId::generate(),
            ProgramCode::fromString($code),
            'Test Program ' . $code,
            'Test Description'
        );
    }
} 