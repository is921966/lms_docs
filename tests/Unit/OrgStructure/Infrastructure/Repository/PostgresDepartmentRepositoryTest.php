<?php

namespace Tests\Unit\OrgStructure\Infrastructure\Repository;

use PHPUnit\Framework\TestCase;
use App\OrgStructure\Infrastructure\Repository\PostgresDepartmentRepository;
use App\OrgStructure\Domain\Models\Department;
use App\OrgStructure\Domain\ValueObjects\DepartmentId;
use App\OrgStructure\Domain\ValueObjects\DepartmentCode;
use App\OrgStructure\Domain\Exceptions\InvalidDepartmentException;
use PDO;
use PDOException;

class PostgresDepartmentRepositoryTest extends TestCase
{
    private PostgresDepartmentRepository $repository;
    private PDO $pdo;
    
    protected function setUp(): void
    {
        // Создаем mock PDO для тестирования
        $this->pdo = $this->createMock(PDO::class);
        $this->repository = new PostgresDepartmentRepository($this->pdo);
    }
    
    public function testFindByIdReturnsNullWhenNotFound(): void
    {
        // Arrange
        $id = DepartmentId::generate();
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
    
    public function testFindByIdReturnsDepartment(): void
    {
        // Arrange
        $id = DepartmentId::generate();
        $stmt = $this->createMock(\PDOStatement::class);
        
        $data = [
            'id' => $id->toString(),
            'department_code' => 'DEPT001',
            'name' => 'IT Department',
            'parent_id' => null,
            'level' => 0,
            'path' => '/IT',
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
        $this->assertInstanceOf(Department::class, $result);
        $this->assertEquals('IT Department', $result->getName());
    }
    
    public function testSaveNewDepartment(): void
    {
        // Arrange
        $department = new Department(
            DepartmentId::generate(),
            new DepartmentCode('DEPT001'),
            'IT Department'
        );
        
        $stmt = $this->createMock(\PDOStatement::class);
        
        $stmt->expects($this->once())
            ->method('execute')
            ->willReturn(true);
            
        $this->pdo->expects($this->once())
            ->method('prepare')
            ->with($this->stringContains('INSERT INTO departments'))
            ->willReturn($stmt);
        
        // Act
        $this->repository->save($department);
        
        // Assert - no exception thrown
        $this->assertTrue(true);
    }
    
    public function testFindAllActiveReturnsArray(): void
    {
        // Arrange
        $stmt = $this->createMock(\PDOStatement::class);
        
        $departments = [
            [
                'id' => DepartmentId::generate()->toString(),
                'department_code' => 'DEPT001',
                'name' => 'IT Department',
                'parent_id' => null,
                'level' => 0,
                'path' => '/IT',
                'is_active' => true
            ],
            [
                'id' => DepartmentId::generate()->toString(),
                'department_code' => 'DEPT002',
                'name' => 'HR Department',
                'parent_id' => null,
                'level' => 0,
                'path' => '/HR',
                'is_active' => true
            ]
        ];
        
        $stmt->expects($this->once())
            ->method('execute')
            ->willReturn(true);
            
        $stmt->expects($this->once())
            ->method('fetchAll')
            ->with(PDO::FETCH_ASSOC)
            ->willReturn($departments);
            
        $this->pdo->expects($this->once())
            ->method('prepare')
            ->willReturn($stmt);
        
        // Act
        $result = $this->repository->findAllActive();
        
        // Assert
        $this->assertIsArray($result);
        $this->assertCount(2, $result);
        $this->assertInstanceOf(Department::class, $result[0]);
        $this->assertInstanceOf(Department::class, $result[1]);
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
    
    public function testDeleteRemovesDepartment(): void
    {
        // Arrange
        $id = DepartmentId::generate();
        $stmt = $this->createMock(\PDOStatement::class);
        
        $stmt->expects($this->once())
            ->method('execute')
            ->willReturn(true);
            
        $this->pdo->expects($this->once())
            ->method('prepare')
            ->with($this->stringContains('DELETE FROM departments'))
            ->willReturn($stmt);
        
        // Act
        $this->repository->delete($id);
        
        // Assert - no exception thrown
        $this->assertTrue(true);
    }
    
    public function testFindByCodeReturnsDepartment(): void
    {
        // Arrange
        $code = new DepartmentCode('DEPT001');
        $stmt = $this->createMock(\PDOStatement::class);
        
        $data = [
            'id' => DepartmentId::generate()->toString(),
            'department_code' => 'DEPT001',
            'name' => 'IT Department',
            'parent_id' => null,
            'level' => 0,
            'path' => '/IT',
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
            ->with($this->stringContains('department_code = :code'))
            ->willReturn($stmt);
        
        // Act
        $result = $this->repository->findByCode($code);
        
        // Assert
        $this->assertNotNull($result);
        $this->assertInstanceOf(Department::class, $result);
        $this->assertEquals('DEPT001', $result->getCode()->toString());
    }
} 