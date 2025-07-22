<?php

namespace Tests\Unit\OrgStructure\Infrastructure\Repository;

use PHPUnit\Framework\TestCase;
use App\OrgStructure\Infrastructure\Repository\PostgresEmployeeRepository;
use App\OrgStructure\Domain\Models\Employee;
use App\OrgStructure\Domain\ValueObjects\EmployeeId;
use App\OrgStructure\Domain\ValueObjects\TabNumber;
use App\OrgStructure\Domain\ValueObjects\PersonalInfo;
use App\OrgStructure\Domain\ValueObjects\DepartmentId;
use App\OrgStructure\Domain\ValueObjects\PositionId;
use PDO;

class PostgresEmployeeRepositoryTest extends TestCase
{
    private PostgresEmployeeRepository $repository;
    private PDO $pdo;
    
    protected function setUp(): void
    {
        $this->pdo = $this->createMock(PDO::class);
        $this->repository = new PostgresEmployeeRepository($this->pdo);
    }
    
    public function testFindByIdReturnsNullWhenNotFound(): void
    {
        // Arrange
        $id = EmployeeId::generate();
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
    
    public function testFindByIdReturnsEmployee(): void
    {
        // Arrange
        $id = EmployeeId::generate();
        $stmt = $this->createMock(\PDOStatement::class);
        
        $data = [
            'id' => $id->toString(),
            'tab_number' => 'EMP001',
            'full_name' => 'John Doe',
            'email' => 'john.doe@example.com',
            'phone' => '+7 123 456 78 90',
            'department_id' => null,
            'position_id' => null,
            'manager_id' => null,
            'hire_date' => '2023-01-01',
            'is_active' => true,
            'ldap_dn' => null
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
        $this->assertInstanceOf(Employee::class, $result);
        $this->assertEquals('John Doe', $result->getPersonalInfo()->getFullName());
    }
    
    public function testSaveNewEmployee(): void
    {
        // Arrange
        $personalInfo = new PersonalInfo('John Doe', 'john.doe@example.com', '+7 123 456 78 90');
        $employee = new Employee(
            EmployeeId::generate(),
            new TabNumber('EMP001'),
            $personalInfo,
            DepartmentId::generate(),
            PositionId::generate()
        );
        
        $stmt = $this->createMock(\PDOStatement::class);
        
        $stmt->expects($this->once())
            ->method('execute')
            ->willReturn(true);
            
        $this->pdo->expects($this->once())
            ->method('prepare')
            ->with($this->stringContains('INSERT INTO employees'))
            ->willReturn($stmt);
        
        // Act
        $this->repository->save($employee);
        
        // Assert - no exception thrown
        $this->assertTrue(true);
    }
    
    public function testFindByTabNumberReturnsEmployee(): void
    {
        // Arrange
        $tabNumber = new TabNumber('EMP001');
        $stmt = $this->createMock(\PDOStatement::class);
        
        $data = [
            'id' => EmployeeId::generate()->toString(),
            'tab_number' => 'EMP001',
            'full_name' => 'John Doe',
            'email' => 'john.doe@example.com',
            'phone' => '+7 123 456 78 90',
            'department_id' => null,
            'position_id' => null,
            'manager_id' => null,
            'hire_date' => '2023-01-01',
            'is_active' => true,
            'ldap_dn' => null
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
            ->with($this->stringContains('tab_number = :tab_number'))
            ->willReturn($stmt);
        
        // Act
        $result = $this->repository->findByTabNumber($tabNumber);
        
        // Assert
        $this->assertNotNull($result);
        $this->assertInstanceOf(Employee::class, $result);
        $this->assertEquals('EMP001', $result->getTabNumber()->toString());
    }
    
    public function testFindByDepartmentReturnsEmployees(): void
    {
        // Arrange
        $departmentId = DepartmentId::generate();
        $stmt = $this->createMock(\PDOStatement::class);
        
        $employees = [
            [
                'id' => EmployeeId::generate()->toString(),
                'tab_number' => 'EMP001',
                'full_name' => 'John Doe',
                'email' => 'john.doe@example.com',
                'phone' => '+7 123 456 78 90',
                'department_id' => $departmentId->toString(),
                'position_id' => null,
                'manager_id' => null,
                'hire_date' => '2023-01-01',
                'is_active' => true,
                'ldap_dn' => null
            ]
        ];
        
        $stmt->expects($this->once())
            ->method('execute')
            ->willReturn(true);
            
        $stmt->expects($this->once())
            ->method('fetchAll')
            ->with(PDO::FETCH_ASSOC)
            ->willReturn($employees);
            
        $this->pdo->expects($this->once())
            ->method('prepare')
            ->with($this->stringContains('department_id = :department_id'))
            ->willReturn($stmt);
        
        // Act
        $result = $this->repository->findByDepartment($departmentId);
        
        // Assert
        $this->assertIsArray($result);
        $this->assertCount(1, $result);
        $this->assertInstanceOf(Employee::class, $result[0]);
    }
    
    public function testFindByManagerReturnsEmployees(): void
    {
        // Arrange
        $managerId = EmployeeId::generate();
        $stmt = $this->createMock(\PDOStatement::class);
        
        $employees = [
            [
                'id' => EmployeeId::generate()->toString(),
                'tab_number' => 'EMP002',
                'full_name' => 'Jane Doe',
                'email' => 'jane.doe@example.com',
                'phone' => '+7 123 456 78 91',
                'department_id' => null,
                'position_id' => null,
                'manager_id' => $managerId->toString(),
                'hire_date' => '2023-02-01',
                'is_active' => true,
                'ldap_dn' => null
            ]
        ];
        
        $stmt->expects($this->once())
            ->method('execute')
            ->willReturn(true);
            
        $stmt->expects($this->once())
            ->method('fetchAll')
            ->with(PDO::FETCH_ASSOC)
            ->willReturn($employees);
            
        $this->pdo->expects($this->once())
            ->method('prepare')
            ->with($this->stringContains('manager_id = :manager_id'))
            ->willReturn($stmt);
        
        // Act
        $result = $this->repository->findByManager($managerId);
        
        // Assert
        $this->assertIsArray($result);
        $this->assertCount(1, $result);
        $this->assertInstanceOf(Employee::class, $result[0]);
    }
    
    public function testDeleteRemovesEmployee(): void
    {
        // Arrange
        $id = EmployeeId::generate();
        $stmt = $this->createMock(\PDOStatement::class);
        
        $stmt->expects($this->once())
            ->method('execute')
            ->willReturn(true);
            
        $this->pdo->expects($this->once())
            ->method('prepare')
            ->with($this->stringContains('DELETE FROM employees'))
            ->willReturn($stmt);
        
        // Act
        $this->repository->delete($id);
        
        // Assert - no exception thrown
        $this->assertTrue(true);
    }
} 