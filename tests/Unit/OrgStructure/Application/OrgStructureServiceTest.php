<?php

namespace Tests\Unit\OrgStructure\Application;

use Tests\TestCase;
use App\OrgStructure\Application\OrgStructureService;
use App\OrgStructure\Application\DTO\CreateDepartmentDTO;
use App\OrgStructure\Application\DTO\UpdateDepartmentDTO;
use App\OrgStructure\Application\DTO\CreateEmployeeDTO;
use App\OrgStructure\Application\DTO\UpdateEmployeeDTO;
use App\OrgStructure\Domain\Repository\DepartmentRepositoryInterface;
use App\OrgStructure\Domain\Repository\EmployeeRepositoryInterface;
use App\OrgStructure\Domain\Entity\Department;
use App\OrgStructure\Domain\Entity\Employee;
use App\OrgStructure\Domain\ValueObject\DepartmentCode;
use App\OrgStructure\Domain\ValueObject\TabNumber;
use App\OrgStructure\Application\Exception\DepartmentNotFoundException;
use App\OrgStructure\Application\Exception\EmployeeNotFoundException;
use App\OrgStructure\Application\Exception\DuplicateCodeException;
use App\OrgStructure\Application\Exception\DuplicateTabNumberException;
use App\OrgStructure\Application\Exception\DepartmentHasChildrenException;
use Mockery;

class OrgStructureServiceTest extends TestCase
{
    private OrgStructureService $service;
    private $departmentRepository;
    private $employeeRepository;
    
    protected function setUp(): void
    {
        parent::setUp();
        
        $this->departmentRepository = Mockery::mock(DepartmentRepositoryInterface::class);
        $this->employeeRepository = Mockery::mock(EmployeeRepositoryInterface::class);
        
        $this->service = new OrgStructureService(
            $this->departmentRepository,
            $this->employeeRepository
        );
    }
    
    protected function tearDown(): void
    {
        Mockery::close();
        parent::tearDown();
    }
    
    /** @test */
    public function it_creates_department(): void
    {
        // Arrange
        $dto = new CreateDepartmentDTO(
            name: 'Департамент ИТ',
            code: 'АП.3.2',
            parentId: 'parent-123'
        );
        
        $this->departmentRepository
            ->shouldReceive('codeExists')
            ->with(Mockery::type(DepartmentCode::class))
            ->once()
            ->andReturn(false);
            
        $this->departmentRepository
            ->shouldReceive('exists')
            ->with('parent-123')
            ->once()
            ->andReturn(true);
            
        $this->departmentRepository
            ->shouldReceive('save')
            ->with(Mockery::type(Department::class))
            ->once();
        
        // Act
        $department = $this->service->createDepartment($dto);
        
        // Assert
        $this->assertEquals('Департамент ИТ', $department->getName());
        $this->assertEquals('АП.3.2', $department->getCode()->getValue());
        $this->assertEquals('parent-123', $department->getParentId());
    }
    
    /** @test */
    public function it_throws_exception_when_code_already_exists(): void
    {
        // Arrange
        $dto = new CreateDepartmentDTO(
            name: 'Департамент ИТ',
            code: 'АП.3.2',
            parentId: null
        );
        
        $this->departmentRepository
            ->shouldReceive('codeExists')
            ->with(Mockery::type(DepartmentCode::class))
            ->once()
            ->andReturn(true);
        
        // Act & Assert
        $this->expectException(DuplicateCodeException::class);
        $this->service->createDepartment($dto);
    }
    
    /** @test */
    public function it_updates_department(): void
    {
        // Arrange
        $department = new Department(
            'dept-123',
            'Старое название',
            new DepartmentCode('АП.3.2'),
            null
        );
        
        $dto = new UpdateDepartmentDTO(
            name: 'Новое название'
        );
        
        $this->departmentRepository
            ->shouldReceive('findById')
            ->with('dept-123')
            ->once()
            ->andReturn($department);
            
        $this->departmentRepository
            ->shouldReceive('save')
            ->with(Mockery::type(Department::class))
            ->once();
        
        // Act
        $updated = $this->service->updateDepartment('dept-123', $dto);
        
        // Assert
        $this->assertEquals('Новое название', $updated->getName());
    }
    
    /** @test */
    public function it_deletes_department(): void
    {
        // Arrange
        $department = new Department(
            'dept-123',
            'Департамент',
            new DepartmentCode('АП.3.2'),
            null
        );
        
        $this->departmentRepository
            ->shouldReceive('findById')
            ->with('dept-123')
            ->once()
            ->andReturn($department);
            
        $this->departmentRepository
            ->shouldReceive('findChildren')
            ->with('dept-123')
            ->once()
            ->andReturn([]);
            
        $this->employeeRepository
            ->shouldReceive('countByDepartment')
            ->with('dept-123')
            ->once()
            ->andReturn(0);
            
        $this->departmentRepository
            ->shouldReceive('delete')
            ->with('dept-123')
            ->once();
        
        // Act
        $this->service->deleteDepartment('dept-123');
        
        // Assert - no exception thrown
        $this->assertTrue(true);
    }
    
    /** @test */
    public function it_throws_exception_when_department_has_children(): void
    {
        // Arrange
        $department = new Department(
            'dept-123',
            'Департамент',
            new DepartmentCode('АП.3'),
            null
        );
        
        $child = new Department(
            'dept-child',
            'Дочерний',
            new DepartmentCode('АП.3.1'),
            'dept-123'
        );
        
        $this->departmentRepository
            ->shouldReceive('findById')
            ->with('dept-123')
            ->once()
            ->andReturn($department);
            
        $this->departmentRepository
            ->shouldReceive('findChildren')
            ->with('dept-123')
            ->once()
            ->andReturn([$child]);
        
        // Act & Assert
        $this->expectException(DepartmentHasChildrenException::class);
        $this->service->deleteDepartment('dept-123');
    }
    
    /** @test */
    public function it_creates_employee(): void
    {
        // Arrange
        $dto = new CreateEmployeeDTO(
            tabNumber: 'АР21000612',
            name: 'Иванов Иван Иванович',
            position: 'Программист',
            departmentId: 'dept-123',
            email: 'ivanov@company.ru',
            phone: '+7 (495) 123-45-67'
        );
        
        $this->employeeRepository
            ->shouldReceive('tabNumberExists')
            ->with(Mockery::type(TabNumber::class))
            ->once()
            ->andReturn(false);
            
        $this->departmentRepository
            ->shouldReceive('exists')
            ->with('dept-123')
            ->once()
            ->andReturn(true);
            
        $this->employeeRepository
            ->shouldReceive('save')
            ->with(Mockery::type(Employee::class))
            ->once();
            
        $this->departmentRepository
            ->shouldReceive('findById')
            ->with('dept-123')
            ->once()
            ->andReturn(new Department(
                'dept-123',
                'IT',
                new DepartmentCode('АП.3.2'),
                null
            ));
            
        $this->employeeRepository
            ->shouldReceive('countByDepartment')
            ->with('dept-123')
            ->once()
            ->andReturn(1);
            
        $this->departmentRepository
            ->shouldReceive('save')
            ->with(Mockery::type(Department::class))
            ->once();
        
        // Act
        $employee = $this->service->createEmployee($dto);
        
        // Assert
        $this->assertEquals('АР21000612', $employee->getTabNumber()->getValue());
        $this->assertEquals('Иванов Иван Иванович', $employee->getName());
        $this->assertEquals('dept-123', $employee->getDepartmentId());
    }
    
    /** @test */
    public function it_throws_exception_when_tab_number_exists(): void
    {
        // Arrange
        $dto = new CreateEmployeeDTO(
            tabNumber: 'АР21000612',
            name: 'Иванов Иван',
            position: 'Программист',
            departmentId: 'dept-123'
        );
        
        $this->employeeRepository
            ->shouldReceive('tabNumberExists')
            ->with(Mockery::type(TabNumber::class))
            ->once()
            ->andReturn(true);
        
        // Act & Assert
        $this->expectException(DuplicateTabNumberException::class);
        $this->service->createEmployee($dto);
    }
    
    /** @test */
    public function it_moves_employee_to_another_department(): void
    {
        // Arrange
        $employee = new Employee(
            'emp-123',
            new TabNumber('АР21000612'),
            'Иванов Иван',
            'Программист',
            'dept-old'
        );
        
        $oldDept = new Department(
            'dept-old',
            'Old Dept',
            new DepartmentCode('АП.1'),
            null
        );
        $oldDept->setEmployeeCount(5);
        
        $newDept = new Department(
            'dept-new',
            'New Dept',
            new DepartmentCode('АП.2'),
            null
        );
        $newDept->setEmployeeCount(10);
        
        $this->employeeRepository
            ->shouldReceive('findById')
            ->with('emp-123')
            ->once()
            ->andReturn($employee);
            
        $this->departmentRepository
            ->shouldReceive('exists')
            ->with('dept-new')
            ->once()
            ->andReturn(true);
            
        $this->departmentRepository
            ->shouldReceive('findById')
            ->with('dept-old')
            ->once()
            ->andReturn($oldDept);
            
        $this->departmentRepository
            ->shouldReceive('findById')
            ->with('dept-new')
            ->once()
            ->andReturn($newDept);
            
        $this->employeeRepository
            ->shouldReceive('save')
            ->once();
            
        $this->employeeRepository
            ->shouldReceive('countByDepartment')
            ->with('dept-old')
            ->once()
            ->andReturn(4);
            
        $this->employeeRepository
            ->shouldReceive('countByDepartment')
            ->with('dept-new')
            ->once()
            ->andReturn(11);
            
        $this->departmentRepository
            ->shouldReceive('save')
            ->twice();
        
        // Act
        $moved = $this->service->moveEmployeeToDepartment('emp-123', 'dept-new');
        
        // Assert
        $this->assertEquals('dept-new', $moved->getDepartmentId());
    }
    
    /** @test */
    public function it_builds_department_tree(): void
    {
        // Arrange
        $root = new Department('1', 'Root', new DepartmentCode('АП'), null);
        $child1 = new Department('2', 'Child1', new DepartmentCode('АП.1'), '1');
        $child2 = new Department('3', 'Child2', new DepartmentCode('АП.2'), '1');
        $grandchild = new Department('4', 'Grandchild', new DepartmentCode('АП.1.1'), '2');
        
        $this->departmentRepository
            ->shouldReceive('findRoots')
            ->once()
            ->andReturn([$root]);
            
        $this->departmentRepository
            ->shouldReceive('findChildren')
            ->with('1')
            ->once()
            ->andReturn([$child1, $child2]);
            
        $this->departmentRepository
            ->shouldReceive('findChildren')
            ->with('2')
            ->once()
            ->andReturn([$grandchild]);
            
        $this->departmentRepository
            ->shouldReceive('findChildren')
            ->with('3')
            ->once()
            ->andReturn([]);
            
        $this->departmentRepository
            ->shouldReceive('findChildren')
            ->with('4')
            ->once()
            ->andReturn([]);
        
        // Act
        $tree = $this->service->getDepartmentTree();
        
        // Assert
        $this->assertCount(1, $tree);
        $this->assertEquals('Root', $tree[0]->getName());
        $this->assertCount(2, $tree[0]->getChildren());
    }
} 