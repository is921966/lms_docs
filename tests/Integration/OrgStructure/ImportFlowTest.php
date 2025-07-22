<?php

declare(strict_types=1);

namespace Tests\Integration\OrgStructure;

use Tests\FeatureTestCase;
use App\OrgStructure\Domain\Repositories\EmployeeRepositoryInterface;
use App\OrgStructure\Domain\Repositories\DepartmentRepositoryInterface;
use App\OrgStructure\Domain\Repositories\PositionRepositoryInterface;
use App\OrgStructure\Infrastructure\Repositories\PostgresEmployeeRepository;
use App\OrgStructure\Infrastructure\Repositories\PostgresDepartmentRepository;
use App\OrgStructure\Infrastructure\Repositories\PostgresPositionRepository;
use App\OrgStructure\Application\Services\ImportOrchestrator;
use App\OrgStructure\Application\Services\CSVParser;
use App\OrgStructure\Application\Services\RelationshipValidator;
use Symfony\Component\HttpFoundation\File\UploadedFile;

class ImportFlowTest extends FeatureTestCase
{
    private ImportOrchestrator $orchestrator;
    private EmployeeRepositoryInterface $employeeRepo;
    private DepartmentRepositoryInterface $departmentRepo;
    private PositionRepositoryInterface $positionRepo;
    
    protected function setUp(): void
    {
        parent::setUp();
        
        // Initialize real repositories with database connection
        $connection = $this->getConnection();
        $this->employeeRepo = new PostgresEmployeeRepository($connection);
        $this->departmentRepo = new PostgresDepartmentRepository($connection);
        $this->positionRepo = new PostgresPositionRepository($connection);
        
        // Initialize orchestrator with real dependencies
        $csvParser = new CSVParser();
        $validator = new RelationshipValidator();
        
        $this->orchestrator = new ImportOrchestrator(
            $csvParser,
            $validator,
            $this->employeeRepo,
            $this->departmentRepo,
            $this->positionRepo
        );
        
        // Clean database
        $this->cleanDatabase();
    }
    
    protected function tearDown(): void
    {
        $this->cleanDatabase();
        parent::tearDown();
    }
    
    /**
     * @test
     */
    public function testFullImportCycleWithValidData(): void
    {
        // Arrange
        $csvContent = <<<CSV
ФИО,Таб.номер,Email,Телефон,Подразделение,Должность,Руководитель
"Иванов Иван Иванович",EMP001,ivanov@company.ru,+7-123-456-7890,"Отдел разработки","Старший разработчик",
"Петров Петр Петрович",EMP002,petrov@company.ru,+7-123-456-7891,"Отдел разработки","Разработчик",EMP001
"Сидорова Мария Ивановна",EMP003,sidorova@company.ru,+7-123-456-7892,"Отдел тестирования","Тестировщик",
CSV;
        
        $tempFile = tempnam(sys_get_temp_dir(), 'test_import');
        file_put_contents($tempFile, $csvContent);
        
        // Act
        $result = $this->orchestrator->importFromCsv($tempFile);
        
        // Assert
        $this->assertEquals(3, $result->getTotalProcessed());
        $this->assertEquals(3, $result->getSuccessful());
        $this->assertEquals(0, $result->getErrors());
        $this->assertEquals(3, $result->getEmployeesCreated());
        $this->assertEquals(2, $result->getDepartmentsCreated());
        $this->assertEquals(3, $result->getPositionsCreated());
        
        // Verify data in database
        $employees = $this->employeeRepo->findAll();
        $this->assertCount(3, $employees);
        
        $departments = $this->departmentRepo->findAll();
        $this->assertCount(2, $departments);
        
        $positions = $this->positionRepo->findAll();
        $this->assertCount(3, $positions);
        
        // Verify manager relationship
        $petrov = $this->employeeRepo->findByTabNumber('EMP002');
        $this->assertNotNull($petrov);
        $this->assertNotNull($petrov->getManager());
        $this->assertEquals('EMP001', $petrov->getManager()->getTabNumber()->getValue());
        
        // Cleanup
        unlink($tempFile);
    }
    
    /**
     * @test
     */
    public function testImportWithErrorsAndRollback(): void
    {
        // Arrange
        $csvContent = <<<CSV
ФИО,Таб.номер,Email,Телефон,Подразделение,Должность,Руководитель
"Иванов Иван Иванович",EMP001,ivanov@company.ru,+7-123-456-7890,"Отдел разработки","Старший разработчик",
"Петров Петр Петрович",EMP002,invalid-email,+7-123-456-7891,"Отдел разработки","Разработчик",EMP001
CSV;
        
        $tempFile = tempnam(sys_get_temp_dir(), 'test_import_error');
        file_put_contents($tempFile, $csvContent);
        
        // Act
        $result = $this->orchestrator->importFromCsv($tempFile, ['skipOnError' => false]);
        
        // Assert
        $this->assertGreaterThan(0, $result->getErrors());
        
        // Verify rollback - no data should be saved
        $employees = $this->employeeRepo->findAll();
        $this->assertCount(0, $employees);
        
        // Cleanup
        unlink($tempFile);
    }
    
    /**
     * @test
     */
    public function testImportWithSkipOnError(): void
    {
        // Arrange
        $csvContent = <<<CSV
ФИО,Таб.номер,Email,Телефон,Подразделение,Должность,Руководитель
"Иванов Иван Иванович",EMP001,ivanov@company.ru,+7-123-456-7890,"Отдел разработки","Старший разработчик",
"Петров Петр Петрович",EMP002,invalid-email,+7-123-456-7891,"Отдел разработки","Разработчик",EMP001
"Сидорова Мария Ивановна",EMP003,sidorova@company.ru,+7-123-456-7892,"Отдел тестирования","Тестировщик",
CSV;
        
        $tempFile = tempnam(sys_get_temp_dir(), 'test_import_skip');
        file_put_contents($tempFile, $csvContent);
        
        // Act
        $result = $this->orchestrator->importFromCsv($tempFile, ['skipOnError' => true]);
        
        // Assert
        $this->assertEquals(3, $result->getTotalProcessed());
        $this->assertEquals(2, $result->getSuccessful());
        $this->assertEquals(1, $result->getErrors());
        
        // Verify partial data saved
        $employees = $this->employeeRepo->findAll();
        $this->assertCount(2, $employees);
        
        // Cleanup
        unlink($tempFile);
    }
    
    /**
     * @test
     */
    public function testImportWithCircularManagerReference(): void
    {
        // Arrange
        $csvContent = <<<CSV
ФИО,Таб.номер,Email,Телефон,Подразделение,Должность,Руководитель
"Иванов Иван Иванович",EMP001,ivanov@company.ru,+7-123-456-7890,"Отдел разработки","Старший разработчик",EMP002
"Петров Петр Петрович",EMP002,petrov@company.ru,+7-123-456-7891,"Отдел разработки","Разработчик",EMP001
CSV;
        
        $tempFile = tempnam(sys_get_temp_dir(), 'test_import_circular');
        file_put_contents($tempFile, $csvContent);
        
        // Act
        $result = $this->orchestrator->importFromCsv($tempFile);
        
        // Assert
        $this->assertGreaterThan(0, $result->getErrors());
        $errorDetails = $result->getErrorList();
        $this->assertStringContainsString('circular', strtolower($errorDetails[0]->getMessage()));
        
        // Cleanup
        unlink($tempFile);
    }
    
    /**
     * @test
     */
    public function testImportEndToEndThroughController(): void
    {
        // Arrange
        $csvContent = <<<CSV
ФИО,Таб.номер,Email,Телефон,Подразделение,Должность,Руководитель
"Тестов Тест Тестович",TEST001,test@company.ru,+7-999-999-9999,"IT департамент","Архитектор",
CSV;
        
        $tempFile = tempnam(sys_get_temp_dir(), 'test_e2e');
        file_put_contents($tempFile, $csvContent);
        
        $uploadedFile = new UploadedFile(
            $tempFile,
            'employees.csv',
            'text/csv',
            null,
            true
        );
        
        // Act - make HTTP request
        $response = $this->postJson('/api/v1/org/import', [], ['file' => $uploadedFile]);
        
        // Assert
        $response->assertStatus(200);
        $response->assertJsonStructure([
            'data' => [
                'totalProcessed',
                'successful',
                'errors',
                'employeesCreated',
                'departmentsCreated',
                'positionsCreated'
            ]
        ]);
        
        $data = $response->json('data');
        $this->assertEquals(1, $data['totalProcessed']);
        $this->assertEquals(1, $data['successful']);
        $this->assertEquals(0, $data['errors']);
        
        // Cleanup
        unlink($tempFile);
    }
    
    private function cleanDatabase(): void
    {
        $connection = $this->getConnection();
        
        // Delete in correct order to avoid foreign key constraints
        $connection->executeStatement('DELETE FROM employees');
        $connection->executeStatement('DELETE FROM positions');
        $connection->executeStatement('DELETE FROM departments');
    }
    
    private function getConnection(): \PDO
    {
        // Get database connection from Laravel/Symfony container
        return app('db')->getPdo();
    }
} 