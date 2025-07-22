<?php

declare(strict_types=1);

namespace Tests\Unit\OrgStructure\Application\Services;

use App\OrgStructure\Application\DTO\ImportResult;
use App\OrgStructure\Application\Exceptions\ImportException;
use App\OrgStructure\Application\Services\CSVParser;
use App\OrgStructure\Application\Services\ImportOrchestrator;
use App\OrgStructure\Application\Services\RelationshipValidator;
use App\OrgStructure\Domain\Repository\DepartmentRepositoryInterface;
use App\OrgStructure\Domain\Repository\EmployeeRepositoryInterface;
use App\OrgStructure\Domain\Repository\PositionRepositoryInterface;
use PHPUnit\Framework\MockObject\MockObject;
use PHPUnit\Framework\TestCase;

final class ImportOrchestratorTest extends TestCase
{
    private ImportOrchestrator $orchestrator;
    
    /** @var CSVParser&MockObject */
    private CSVParser $csvParser;
    
    /** @var RelationshipValidator&MockObject */
    private RelationshipValidator $validator;
    
    /** @var EmployeeRepositoryInterface&MockObject */
    private EmployeeRepositoryInterface $employeeRepository;
    
    /** @var DepartmentRepositoryInterface&MockObject */
    private DepartmentRepositoryInterface $departmentRepository;
    
    /** @var PositionRepositoryInterface&MockObject */
    private PositionRepositoryInterface $positionRepository;

    protected function setUp(): void
    {
        $this->csvParser = $this->createMock(CSVParser::class);
        $this->validator = $this->createMock(RelationshipValidator::class);
        $this->employeeRepository = $this->createMock(EmployeeRepositoryInterface::class);
        $this->departmentRepository = $this->createMock(DepartmentRepositoryInterface::class);
        $this->positionRepository = $this->createMock(PositionRepositoryInterface::class);

        $this->orchestrator = new ImportOrchestrator(
            $this->csvParser,
            $this->validator,
            $this->employeeRepository,
            $this->departmentRepository,
            $this->positionRepository
        );
    }

    public function testImportDepartmentsSuccessfully(): void
    {
        $csvData = "code;name;parent_code\nCOMPANY;ООО Рога и Копыта;\nIT;IT департамент;COMPANY";
        
        $this->csvParser->expects($this->once())
            ->method('parse')
            ->with($csvData, ';')
            ->willReturn([
                ['code' => 'COMPANY', 'name' => 'ООО Рога и Копыта', 'parent_code' => ''],
                ['code' => 'IT', 'name' => 'IT департамент', 'parent_code' => 'COMPANY']
            ]);

        $this->validator->expects($this->once())
            ->method('validateDepartmentHierarchy')
            ->willReturn(true);

        $this->departmentRepository->expects($this->exactly(2))
            ->method('save');

        $result = $this->orchestrator->importDepartments($csvData, ';');

        $this->assertInstanceOf(ImportResult::class, $result);
        $this->assertTrue($result->isSuccess());
        $this->assertEquals(2, $result->getImportedCount());
        $this->assertEquals(0, $result->getFailedCount());
        $this->assertEmpty($result->getErrors());
    }

    public function testImportPositionsSuccessfully(): void
    {
        $csvData = "code\tname\tcategory\nCEO\tГенеральный директор\tРуководство";
        
        $this->csvParser->expects($this->once())
            ->method('parse')
            ->with($csvData, "\t")
            ->willReturn([
                ['code' => 'CEO', 'name' => 'Генеральный директор', 'category' => 'Руководство']
            ]);

        $this->positionRepository->expects($this->once())
            ->method('save');

        $result = $this->orchestrator->importPositions($csvData, "\t");

        $this->assertTrue($result->isSuccess());
        $this->assertEquals(1, $result->getImportedCount());
    }

    public function testImportEmployeesWithValidation(): void
    {
        $csvData = <<<CSV
tab_number,full_name,department_id,position_id,manager_id
00001,Иванов И.И.,IT,CEO,
00002,Петров П.П.,IT,DEV,00001
CSV;

        $this->csvParser->expects($this->once())
            ->method('parse')
            ->willReturn([
                [
                    'tab_number' => '00001',
                    'full_name' => 'Иванов И.И.',
                    'department_id' => 'IT',
                    'position_id' => 'CEO',
                    'manager_id' => ''
                ],
                [
                    'tab_number' => '00002',
                    'full_name' => 'Петров П.П.',
                    'department_id' => 'IT',
                    'position_id' => 'DEV',
                    'manager_id' => '00001'
                ]
            ]);

        $this->validator->expects($this->once())
            ->method('validateEmployeeRelationships')
            ->willReturn(true);

        $this->employeeRepository->expects($this->exactly(2))
            ->method('save');

        $result = $this->orchestrator->importEmployees($csvData);

        $this->assertTrue($result->isSuccess());
        $this->assertEquals(2, $result->getImportedCount());
    }

    public function testImportFailsOnInvalidData(): void
    {
        $csvData = "invalid csv data";
        
        $this->csvParser->expects($this->once())
            ->method('parse')
            ->willThrowException(new ImportException('Invalid CSV format'));

        $result = $this->orchestrator->importDepartments($csvData);

        $this->assertFalse($result->isSuccess());
        $this->assertEquals(0, $result->getImportedCount());
        $this->assertCount(1, $result->getErrors());
        $this->assertEquals('Invalid CSV format', $result->getErrors()[0]->getMessage());
    }

    public function testPartialImportWithErrors(): void
    {
        $csvData = <<<CSV
code,name,parent_code
VALID1,Valid Department,
INVALID,,
VALID2,Another Valid,
CSV;

        $this->csvParser->expects($this->once())
            ->method('parse')
            ->willReturn([
                ['code' => 'VALID1', 'name' => 'Valid Department', 'parent_code' => ''],
                ['code' => 'INVALID', 'name' => '', 'parent_code' => ''],
                ['code' => 'VALID2', 'name' => 'Another Valid', 'parent_code' => '']
            ]);

        $this->departmentRepository->expects($this->exactly(2))
            ->method('save');

        $this->validator->expects($this->once())
            ->method('validateDepartmentHierarchy')
            ->willReturn(true);

        $result = $this->orchestrator->importDepartments($csvData, ',', ['skipOnError' => true]);

        $this->assertTrue($result->isPartialSuccess());
        $this->assertEquals(2, $result->getImportedCount());
        $this->assertEquals(1, $result->getFailedCount());
        
        // Check error details
        $errors = $result->getErrors();
        $this->assertCount(1, $errors);
        $this->assertStringContainsString('Department name cannot be empty', $errors[0]->getMessage());
    }

    public function testRollbackOnCriticalError(): void
    {
        $csvData = "code,name\nTEST,Test Department";
        
        $this->csvParser->expects($this->once())
            ->method('parse')
            ->willReturn([
                ['code' => 'TEST', 'name' => 'Test Department']
            ]);

        $this->departmentRepository->expects($this->once())
            ->method('save')
            ->willThrowException(new \Exception('Database error'));

        $this->departmentRepository->expects($this->once())
            ->method('beginTransaction');
            
        $this->departmentRepository->expects($this->once())
            ->method('rollback');

        $result = $this->orchestrator->importDepartments($csvData, ',', ['useTransaction' => true]);

        $this->assertFalse($result->isSuccess());
        $this->assertEquals(0, $result->getImportedCount());
        $this->assertStringContainsString('Database error', $result->getErrors()[0]->getMessage());
    }

    public function testImportWithCircularDependency(): void
    {
        $csvData = <<<CSV
code,name,parent_code
DEPT1,Department 1,DEPT2
DEPT2,Department 2,DEPT1
CSV;

        $this->csvParser->expects($this->once())
            ->method('parse')
            ->willReturn([
                ['code' => 'DEPT1', 'name' => 'Department 1', 'parent_code' => 'DEPT2'],
                ['code' => 'DEPT2', 'name' => 'Department 2', 'parent_code' => 'DEPT1']
            ]);

        $this->validator->expects($this->once())
            ->method('validateDepartmentHierarchy')
            ->willReturn(false);

        $result = $this->orchestrator->importDepartments($csvData);

        $this->assertFalse($result->isSuccess());
        $this->assertStringContainsString('Circular dependency detected', $result->getErrors()[0]->getMessage());
    }

    public function testFullOrgStructureImport(): void
    {
        $departmentsCsv = "code,name\nIT,IT Department";
        $positionsCsv = "code,name,category\nDEV,Developer,Tech";
        $employeesCsv = "tab_number,full_name,department_id,position_id\n00001,Test User,IT,DEV";

        // Setup mocks for full import...
        $this->csvParser->expects($this->exactly(3))
            ->method('parse')
            ->willReturnOnConsecutiveCalls(
                [['code' => 'IT', 'name' => 'IT Department']],
                [['code' => 'DEV', 'name' => 'Developer', 'category' => 'Tech']],
                [['tab_number' => '00001', 'full_name' => 'Test User', 'department_id' => 'IT', 'position_id' => 'DEV']]
            );

        $this->validator->expects($this->once())
            ->method('validateDepartmentHierarchy')
            ->willReturn(true);
            
        $this->validator->expects($this->once())
            ->method('validateEmployeeRelationships')
            ->willReturn(true);
            
        $this->departmentRepository->expects($this->once())
            ->method('save');
            
        $this->positionRepository->expects($this->once())
            ->method('save');
            
        $this->employeeRepository->expects($this->once())
            ->method('save');

        $result = $this->orchestrator->importFullOrgStructure(
            $departmentsCsv,
            $positionsCsv,
            $employeesCsv
        );

        $this->assertTrue($result->isSuccess());
        $this->assertEquals(3, $result->getImportedCount());
        $this->assertArrayHasKey('departments', $result->getDetails());
        $this->assertArrayHasKey('positions', $result->getDetails());
        $this->assertArrayHasKey('employees', $result->getDetails());
    }
} 