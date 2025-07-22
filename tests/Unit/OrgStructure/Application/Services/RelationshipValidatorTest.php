<?php

declare(strict_types=1);

namespace Tests\Unit\OrgStructure\Application\Services;

use App\OrgStructure\Application\Services\RelationshipValidator;
use App\OrgStructure\Domain\Models\Department;
use App\OrgStructure\Domain\Models\Employee;
use App\OrgStructure\Domain\Repository\DepartmentRepositoryInterface;
use App\OrgStructure\Domain\Repository\EmployeeRepositoryInterface;
use App\OrgStructure\Domain\Repository\PositionRepositoryInterface;
use App\OrgStructure\Domain\ValueObjects\DepartmentCode;
use App\OrgStructure\Domain\ValueObjects\DepartmentId;
use App\OrgStructure\Domain\ValueObjects\TabNumber;
use PHPUnit\Framework\MockObject\MockObject;
use PHPUnit\Framework\TestCase;

final class RelationshipValidatorTest extends TestCase
{
    private RelationshipValidator $validator;
    
    /** @var EmployeeRepositoryInterface&MockObject */
    private EmployeeRepositoryInterface $employeeRepository;
    
    /** @var DepartmentRepositoryInterface&MockObject */
    private DepartmentRepositoryInterface $departmentRepository;
    
    /** @var PositionRepositoryInterface&MockObject */
    private PositionRepositoryInterface $positionRepository;

    protected function setUp(): void
    {
        $this->employeeRepository = $this->createMock(EmployeeRepositoryInterface::class);
        $this->departmentRepository = $this->createMock(DepartmentRepositoryInterface::class);
        $this->positionRepository = $this->createMock(PositionRepositoryInterface::class);

        $this->validator = new RelationshipValidator(
            $this->employeeRepository,
            $this->departmentRepository,
            $this->positionRepository
        );
    }

    public function testValidateDepartmentHierarchyWithValidData(): void
    {
        $departments = [
            ['code' => 'COMPANY', 'name' => 'Company', 'parent_code' => ''],
            ['code' => 'IT', 'name' => 'IT Dept', 'parent_code' => 'COMPANY'],
            ['code' => 'IT-DEV', 'name' => 'Development', 'parent_code' => 'IT']
        ];

        $result = $this->validator->validateDepartmentHierarchy($departments);

        $this->assertTrue($result);
        $this->assertEmpty($this->validator->getErrors());
    }

    public function testValidateDepartmentHierarchyWithCircularDependency(): void
    {
        $departments = [
            ['code' => 'DEPT1', 'name' => 'Department 1', 'parent_code' => 'DEPT2'],
            ['code' => 'DEPT2', 'name' => 'Department 2', 'parent_code' => 'DEPT3'],
            ['code' => 'DEPT3', 'name' => 'Department 3', 'parent_code' => 'DEPT1']
        ];

        $result = $this->validator->validateDepartmentHierarchy($departments);

        $this->assertFalse($result);
        $errors = $this->validator->getErrors();
        $this->assertCount(1, $errors);
        $this->assertStringContainsString('Circular dependency', $errors[0]);
    }

    public function testValidateDepartmentHierarchyWithMissingParent(): void
    {
        $departments = [
            ['code' => 'IT-DEV', 'name' => 'Development', 'parent_code' => 'IT']
        ];

        $result = $this->validator->validateDepartmentHierarchy($departments);

        $this->assertFalse($result);
        $errors = $this->validator->getErrors();
        $this->assertStringContainsString('Parent department IT not found', $errors[0]);
    }

    public function testValidateEmployeeRelationshipsWithValidData(): void
    {
        $employees = [
            [
                'tab_number' => '00001',
                'full_name' => 'CEO',
                'department_id' => 'COMPANY',
                'position_id' => 'CEO',
                'manager_id' => ''
            ],
            [
                'tab_number' => '00002',
                'full_name' => 'Manager',
                'department_id' => 'IT',
                'position_id' => 'MGR',
                'manager_id' => '00001'
            ]
        ];

        // Mock department exists
        $this->departmentRepository->expects($this->exactly(2))
            ->method('findByCode')
            ->willReturn($this->createMock(Department::class));

        // Mock position exists
        $this->positionRepository->expects($this->exactly(2))
            ->method('existsByCode')
            ->willReturn(true);

        $result = $this->validator->validateEmployeeRelationships($employees);

        $this->assertTrue($result);
        $this->assertEmpty($this->validator->getErrors());
    }

    public function testValidateEmployeeRelationshipsWithInvalidManager(): void
    {
        $employees = [
            [
                'tab_number' => '00002',
                'full_name' => 'Employee',
                'department_id' => 'IT',
                'position_id' => 'DEV',
                'manager_id' => '99999' // Non-existent manager
            ]
        ];

        $this->departmentRepository->expects($this->once())
            ->method('findByCode')
            ->willReturn($this->createMock(Department::class));

        $this->positionRepository->expects($this->once())
            ->method('existsByCode')
            ->willReturn(true);

        $result = $this->validator->validateEmployeeRelationships($employees);

        $this->assertFalse($result);
        $errors = $this->validator->getErrors();
        $this->assertStringContainsString('Manager with tab number 99999 not found', $errors[0]);
    }

    public function testValidateEmployeeRelationshipsWithSelfReference(): void
    {
        $employees = [
            [
                'tab_number' => '00001',
                'full_name' => 'Employee',
                'department_id' => 'IT',
                'position_id' => 'DEV',
                'manager_id' => '00001' // Self-reference
            ]
        ];

        $this->departmentRepository->expects($this->once())
            ->method('findByCode')
            ->willReturn($this->createMock(Department::class));

        $this->positionRepository->expects($this->once())
            ->method('existsByCode')
            ->willReturn(true);

        $result = $this->validator->validateEmployeeRelationships($employees);

        $this->assertFalse($result);
        $errors = $this->validator->getErrors();
        $this->assertStringContainsString('cannot be their own manager', $errors[0]);
    }

    public function testValidateEmployeeRelationshipsWithNonExistentDepartment(): void
    {
        $employees = [
            [
                'tab_number' => '00001',
                'full_name' => 'Employee',
                'department_id' => 'INVALID',
                'position_id' => 'DEV',
                'manager_id' => ''
            ]
        ];

        $this->departmentRepository->expects($this->once())
            ->method('findByCode')
            ->willReturn(null);

        $result = $this->validator->validateEmployeeRelationships($employees);

        $this->assertFalse($result);
        $errors = $this->validator->getErrors();
        $this->assertStringContainsString('Department INVALID not found', $errors[0]);
    }

    public function testValidateEmployeeRelationshipsWithNonExistentPosition(): void
    {
        $employees = [
            [
                'tab_number' => '00001',
                'full_name' => 'Employee',
                'department_id' => 'IT',
                'position_id' => 'INVALID',
                'manager_id' => ''
            ]
        ];

        $this->departmentRepository->expects($this->once())
            ->method('findByCode')
            ->willReturn($this->createMock(Department::class));

        $this->positionRepository->expects($this->once())
            ->method('existsByCode')
            ->with('INVALID')
            ->willReturn(false);

        $result = $this->validator->validateEmployeeRelationships($employees);

        $this->assertFalse($result);
        $errors = $this->validator->getErrors();
        $this->assertStringContainsString('Position INVALID not found', $errors[0]);
    }

    public function testValidateWithDuplicateEmployeeTabNumbers(): void
    {
        $employees = [
            [
                'tab_number' => '00001',
                'full_name' => 'Employee 1',
                'department_id' => 'IT',
                'position_id' => 'DEV',
                'manager_id' => ''
            ],
            [
                'tab_number' => '00001', // Duplicate
                'full_name' => 'Employee 2',
                'department_id' => 'IT',
                'position_id' => 'DEV',
                'manager_id' => ''
            ]
        ];

        $result = $this->validator->validateEmployeeRelationships($employees);

        $this->assertFalse($result);
        $errors = $this->validator->getErrors();
        $this->assertStringContainsString('Duplicate tab number: 00001', $errors[0]);
    }

    public function testClearErrors(): void
    {
        // First cause an error
        $departments = [
            ['code' => 'DEPT1', 'name' => 'Dept', 'parent_code' => 'MISSING']
        ];

        $this->validator->validateDepartmentHierarchy($departments);
        $this->assertNotEmpty($this->validator->getErrors());

        // Clear errors
        $this->validator->clearErrors();
        $this->assertEmpty($this->validator->getErrors());
    }
} 