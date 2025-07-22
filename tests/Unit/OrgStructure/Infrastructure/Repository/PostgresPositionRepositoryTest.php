<?php

namespace Tests\Unit\OrgStructure\Infrastructure\Repository;

use PHPUnit\Framework\TestCase;
use App\OrgStructure\Infrastructure\Repository\PostgresPositionRepository;
use App\OrgStructure\Domain\Models\Position;
use App\OrgStructure\Domain\ValueObjects\PositionId;
use App\OrgStructure\Domain\ValueObjects\DepartmentId;
use PDO;

class PostgresPositionRepositoryTest extends TestCase
{
    private PostgresPositionRepository $repository;
    private PDO $pdo;
    
    protected function setUp(): void
    {
        $this->pdo = $this->createMock(PDO::class);
        $this->repository = new PostgresPositionRepository($this->pdo);
    }
    
    public function testFindByIdReturnsNullWhenNotFound(): void
    {
        // Arrange
        $id = PositionId::generate();
        $stmt = $this->createMock(\PDOStatement::class);
        
        $stmt->expects($this->once())
            ->method('execute')
            ->willReturn(true);
            
        $stmt->expects($this->once())
            ->method('fetch')
            ->willReturn(false);
            
        $this->pdo->expects($this->once())
            ->method('prepare')
            ->willReturn($stmt);
        
        // Act
        $result = $this->repository->findById($id);
        
        // Assert
        $this->assertNull($result);
    }
    
    public function testFindByIdReturnsPosition(): void
    {
        // Arrange
        $id = PositionId::generate();
        $stmt = $this->createMock(\PDOStatement::class);
        
        $data = [
            'id' => $id->toString(),
            'code' => 'POS001',
            'title' => 'Software Developer',
            'category' => 'technical',
            'department_id' => null,
            'is_active' => true
        ];
        
        $stmt->expects($this->once())
            ->method('execute')
            ->willReturn(true);
            
        $stmt->expects($this->once())
            ->method('fetch')
            ->with(PDO::FETCH_ASSOC)
            ->willReturn($data);
            
        $this->pdo->expects($this->once())
            ->method('prepare')
            ->willReturn($stmt);
        
        // Act
        $result = $this->repository->findById($id);
        
        // Assert
        $this->assertNotNull($result);
        $this->assertInstanceOf(Position::class, $result);
        $this->assertEquals('Software Developer', $result->getTitle());
    }
    
    public function testSaveNewPosition(): void
    {
        // Arrange
        $position = new Position(
            PositionId::generate(),
            'POS001',
            'Software Developer',
            'technical'
        );
        
        $stmt = $this->createMock(\PDOStatement::class);
        
        $stmt->expects($this->once())
            ->method('execute')
            ->willReturn(true);
            
        $this->pdo->expects($this->once())
            ->method('prepare')
            ->with($this->stringContains('INSERT INTO positions'))
            ->willReturn($stmt);
        
        // Act
        $this->repository->save($position);
        
        // Assert - no exception thrown
        $this->assertTrue(true);
    }
    
    public function testFindAllActiveReturnsArray(): void
    {
        // Arrange
        $stmt = $this->createMock(\PDOStatement::class);
        
        $positions = [
            [
                'id' => PositionId::generate()->toString(),
                'code' => 'POS001',
                'title' => 'Software Developer',
                'category' => 'technical',
                'department_id' => null,
                'is_active' => true
            ],
            [
                'id' => PositionId::generate()->toString(),
                'code' => 'POS002',
                'title' => 'HR Manager',
                'category' => 'management',
                'department_id' => null,
                'is_active' => true
            ]
        ];
        
        $stmt->expects($this->once())
            ->method('execute')
            ->willReturn(true);
            
        $stmt->expects($this->once())
            ->method('fetchAll')
            ->with(PDO::FETCH_ASSOC)
            ->willReturn($positions);
            
        $this->pdo->expects($this->once())
            ->method('prepare')
            ->willReturn($stmt);
        
        // Act
        $result = $this->repository->findAllActive();
        
        // Assert
        $this->assertIsArray($result);
        $this->assertCount(2, $result);
        $this->assertInstanceOf(Position::class, $result[0]);
        $this->assertInstanceOf(Position::class, $result[1]);
    }
    
    public function testFindByDepartmentReturnsPositions(): void
    {
        // Arrange
        $departmentId = DepartmentId::generate();
        $stmt = $this->createMock(\PDOStatement::class);
        
        $positions = [
            [
                'id' => PositionId::generate()->toString(),
                'code' => 'POS001',
                'title' => 'Software Developer',
                'category' => 'technical',
                'department_id' => $departmentId->toString(),
                'is_active' => true
            ]
        ];
        
        $stmt->expects($this->once())
            ->method('execute')
            ->willReturn(true);
            
        $stmt->expects($this->once())
            ->method('fetchAll')
            ->with(PDO::FETCH_ASSOC)
            ->willReturn($positions);
            
        $this->pdo->expects($this->once())
            ->method('prepare')
            ->with($this->stringContains('department_id = :department_id'))
            ->willReturn($stmt);
        
        // Act
        $result = $this->repository->findByDepartment($departmentId);
        
        // Assert
        $this->assertIsArray($result);
        $this->assertCount(1, $result);
        $this->assertInstanceOf(Position::class, $result[0]);
    }
    
    public function testDeleteRemovesPosition(): void
    {
        // Arrange
        $id = PositionId::generate();
        $stmt = $this->createMock(\PDOStatement::class);
        
        $stmt->expects($this->once())
            ->method('execute')
            ->willReturn(true);
            
        $this->pdo->expects($this->once())
            ->method('prepare')
            ->with($this->stringContains('DELETE FROM positions'))
            ->willReturn($stmt);
        
        // Act
        $this->repository->delete($id);
        
        // Assert - no exception thrown
        $this->assertTrue(true);
    }
    
    public function testBeginTransactionStartsTransaction(): void
    {
        // Arrange
        $this->pdo->expects($this->once())
            ->method('beginTransaction')
            ->willReturn(true);
        
        // Act
        $this->repository->beginTransaction();
        
        // Assert - no exception thrown
        $this->assertTrue(true);
    }
    
    public function testCommitCommitsTransaction(): void
    {
        // Arrange
        $this->pdo->expects($this->once())
            ->method('commit')
            ->willReturn(true);
        
        // Act
        $this->repository->commit();
        
        // Assert - no exception thrown
        $this->assertTrue(true);
    }
    
    public function testRollbackRollsBackTransaction(): void
    {
        // Arrange
        $this->pdo->expects($this->once())
            ->method('rollback')
            ->willReturn(true);
        
        // Act
        $this->repository->rollback();
        
        // Assert - no exception thrown
        $this->assertTrue(true);
    }
} 