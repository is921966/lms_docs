<?php

declare(strict_types=1);

namespace Tests\Unit\Position\Infrastructure\Repository;

use App\Position\Infrastructure\Repository\InMemoryPositionRepository;
use App\Position\Domain\Position;
use App\Position\Domain\ValueObjects\PositionId;
use App\Position\Domain\ValueObjects\PositionCode;
use App\Position\Domain\ValueObjects\PositionLevel;
use App\Position\Domain\ValueObjects\Department;
use PHPUnit\Framework\TestCase;

class InMemoryPositionRepositoryTest extends TestCase
{
    private InMemoryPositionRepository $repository;
    
    protected function setUp(): void
    {
        $this->repository = new InMemoryPositionRepository();
    }
    
    public function testSaveAndFindById(): void
    {
        $position = $this->createPosition();
        
        $this->repository->save($position);
        
        $found = $this->repository->findById($position->getId());
        
        $this->assertNotNull($found);
        $this->assertTrue($position->getId()->equals($found->getId()));
        $this->assertEquals($position->getTitle(), $found->getTitle());
    }
    
    public function testFindByIdReturnsNullWhenNotFound(): void
    {
        $result = $this->repository->findById(PositionId::generate());
        
        $this->assertNull($result);
    }
    
    public function testFindByCode(): void
    {
        $position = $this->createPosition();
        $this->repository->save($position);
        
        $found = $this->repository->findByCode($position->getCode());
        
        $this->assertNotNull($found);
        $this->assertEquals($position->getCode()->getValue(), $found->getCode()->getValue());
    }
    
    public function testFindByCodeReturnsNullWhenNotFound(): void
    {
        $result = $this->repository->findByCode(PositionCode::fromString('NF-404'));
        
        $this->assertNull($result);
    }
    
    public function testFindByDepartment(): void
    {
        $department = Department::fromString('IT');
        
        $position1 = $this->createPosition('DEV-001', 'Developer', $department);
        $position2 = $this->createPosition('DEV-002', 'Senior Developer', $department);
        $position3 = $this->createPosition('HR-001', 'HR Manager', Department::fromString('HR'));
        
        $this->repository->save($position1);
        $this->repository->save($position2);
        $this->repository->save($position3);
        
        $results = $this->repository->findByDepartment($department);
        
        $this->assertCount(2, $results);
        $this->assertContains($position1, $results);
        $this->assertContains($position2, $results);
        $this->assertNotContains($position3, $results);
    }
    
    public function testFindByLevel(): void
    {
        $level = PositionLevel::fromValue(2);
        
        $position1 = $this->createPosition('POS-001', 'Position 1', null, $level);
        $position2 = $this->createPosition('POS-002', 'Position 2', null, $level);
        $position3 = $this->createPosition('POS-003', 'Position 3', null, PositionLevel::fromValue(3));
        
        $this->repository->save($position1);
        $this->repository->save($position2);
        $this->repository->save($position3);
        
        $results = $this->repository->findByLevel($level);
        
        $this->assertCount(2, $results);
        $this->assertContains($position1, $results);
        $this->assertContains($position2, $results);
        $this->assertNotContains($position3, $results);
    }
    
    public function testFindActive(): void
    {
        $position1 = $this->createPosition('POS-001', 'Active 1');
        $position2 = $this->createPosition('POS-002', 'Active 2');
        $position3 = $this->createPosition('POS-003', 'Archived');
        $position3->archive();
        
        $this->repository->save($position1);
        $this->repository->save($position2);
        $this->repository->save($position3);
        
        $results = $this->repository->findActive();
        
        $this->assertCount(2, $results);
        $this->assertContains($position1, $results);
        $this->assertContains($position2, $results);
        $this->assertNotContains($position3, $results);
    }
    
    public function testUpdateExistingPosition(): void
    {
        $position = $this->createPosition();
        $this->repository->save($position);
        
        $position->update('New Title', 'New Description', PositionLevel::fromValue(3));
        $this->repository->save($position);
        
        $found = $this->repository->findById($position->getId());
        
        $this->assertEquals('New Title', $found->getTitle());
        $this->assertEquals('New Description', $found->getDescription());
        $this->assertEquals(3, $found->getLevel()->getValue());
    }
    
    public function testExists(): void
    {
        $position = $this->createPosition();
        $this->repository->save($position);
        
        $this->assertTrue($this->repository->exists($position->getId()));
        $this->assertFalse($this->repository->exists(PositionId::generate()));
    }
    
    public function testCountByDepartment(): void
    {
        $itDepartment = Department::fromString('IT');
        $hrDepartment = Department::fromString('HR');
        
        $this->repository->save($this->createPosition('IT-001', 'Dev 1', $itDepartment));
        $this->repository->save($this->createPosition('IT-002', 'Dev 2', $itDepartment));
        $this->repository->save($this->createPosition('HR-001', 'HR 1', $hrDepartment));
        
        $this->assertEquals(2, $this->repository->countByDepartment($itDepartment));
        $this->assertEquals(1, $this->repository->countByDepartment($hrDepartment));
        $this->assertEquals(0, $this->repository->countByDepartment(Department::fromString('Finance')));
    }
    
    private function createPosition(
        string $code = 'POS-001',
        string $title = 'Test Position',
        ?Department $department = null,
        ?PositionLevel $level = null
    ): Position {
        return Position::create(
            id: PositionId::generate(),
            code: PositionCode::fromString($code),
            title: $title,
            department: $department ?? Department::fromString('IT'),
            level: $level ?? PositionLevel::fromValue(2),
            description: 'Test position description'
        );
    }
} 