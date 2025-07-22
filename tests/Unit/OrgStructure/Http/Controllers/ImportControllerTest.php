<?php

namespace Tests\Unit\OrgStructure\Http\Controllers;

use PHPUnit\Framework\TestCase;
use App\OrgStructure\Http\Controllers\ImportController;
use App\OrgStructure\Application\Services\ImportOrchestrator;
use App\OrgStructure\Application\DTO\ImportResult;
use App\OrgStructure\Application\DTO\ImportError;
use App\Common\Http\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\File\UploadedFile;

class ImportControllerTest extends TestCase
{
    private ImportController $controller;
    private ImportOrchestrator $importOrchestrator;
    
    protected function setUp(): void
    {
        $this->importOrchestrator = $this->createMock(ImportOrchestrator::class);
        $this->controller = new ImportController($this->importOrchestrator);
    }

    public function testImportEmployeesFromCsv(): void
    {
        // Arrange
        $csvContent = "ФИО,Таб.номер,Email,Телефон,Подразделение,Должность,Руководитель\n" .
                     "Иванов Иван Иванович,EMP001,ivan@company.ru,+7-123-456-7890,IT,Developer,\n" .
                     "Петров Петр Петрович,EMP002,petr@company.ru,+7-123-456-7891,IT,Senior Developer,EMP001";
        
        $tempFile = tempnam(sys_get_temp_dir(), 'test_csv');
        file_put_contents($tempFile, $csvContent);
        
        $uploadedFile = new UploadedFile(
            $tempFile,
            'employees.csv',
            'text/csv',
            null,
            true
        );
        
        $request = Request::create('/api/import/employees', 'POST', [], [], ['file' => $uploadedFile]);
        
        $importResult = new ImportResult(2, 0, 0, 2, 1, []);
        
        $this->importOrchestrator
            ->expects($this->once())
            ->method('importFromCsv')
            ->with($this->anything(), ['skipOnError' => false])
            ->willReturn($importResult);
        
        // Act
        $response = $this->controller->importEmployees($request);
        
        // Assert
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertEquals(2, $data['data']['totalProcessed']);
        $this->assertEquals(2, $data['data']['employeesCreated']);
        $this->assertEquals(1, $data['data']['positionsCreated']);
        
        // Cleanup
        unlink($tempFile);
    }

    public function testImportWithErrors(): void
    {
        // Arrange
        $csvContent = "ФИО,Таб.номер,Email,Телефон,Подразделение,Должность,Руководитель\n" .
                     "Иванов Иван Иванович,EMP001,invalid-email,+7-123-456-7890,IT,Developer,";
        
        $tempFile = tempnam(sys_get_temp_dir(), 'test_csv');
        file_put_contents($tempFile, $csvContent);
        
        $uploadedFile = new UploadedFile(
            $tempFile,
            'employees.csv',
            'text/csv',
            null,
            true
        );
        
        $request = Request::create('/api/import/employees', 'POST', [], [], ['file' => $uploadedFile]);
        
        $errors = [
            new ImportError('validation', 'Invalid email format', 2, ['email' => 'invalid-email'])
        ];
        
        $importResult = new ImportResult(1, 0, 1, 0, 0, $errors);
        
        $this->importOrchestrator
            ->expects($this->once())
            ->method('importFromCsv')
            ->with($this->anything(), ['skipOnError' => false])
            ->willReturn($importResult);
        
        // Act
        $response = $this->controller->importEmployees($request);
        
        // Assert
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertEquals(1, $data['data']['totalProcessed']);
        $this->assertEquals(1, $data['data']['errors']);
        $this->assertCount(1, $data['data']['errorDetails']);
        $this->assertEquals('Invalid email format', $data['data']['errorDetails'][0]['message']);
        
        // Cleanup
        unlink($tempFile);
    }

    public function testImportWithoutFile(): void
    {
        // Arrange
        $request = Request::create('/api/import/employees', 'POST');
        
        // Act
        $response = $this->controller->importEmployees($request);
        
        // Assert
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(Response::HTTP_BAD_REQUEST, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertEquals('No file uploaded', $data['error']);
    }

    public function testImportWithInvalidFileType(): void
    {
        // Arrange
        $tempFile = tempnam(sys_get_temp_dir(), 'test_txt');
        file_put_contents($tempFile, 'Not a CSV file');
        
        $uploadedFile = new UploadedFile(
            $tempFile,
            'employees.txt',
            'text/plain',
            null,
            true
        );
        
        $request = Request::create('/api/import/employees', 'POST', [], [], ['file' => $uploadedFile]);
        
        // Act
        $response = $this->controller->importEmployees($request);
        
        // Assert
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(Response::HTTP_BAD_REQUEST, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertEquals('Invalid file type. Please upload a CSV file', $data['error']);
        
        // Cleanup
        unlink($tempFile);
    }

    public function testGetImportTemplate(): void
    {
        // Act
        $response = $this->controller->getTemplate();
        
        // Assert
        $this->assertInstanceOf(Response::class, $response);
        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
        $this->assertEquals('text/csv; charset=UTF-8', $response->headers->get('Content-Type'));
        $this->assertStringContainsString('attachment; filename="org_structure_template.csv"', 
            $response->headers->get('Content-Disposition'));
        
        $content = $response->getContent();
        $this->assertStringContainsString('ФИО,Таб.номер,Email,Телефон,Подразделение,Должность,Руководитель', $content);
    }
} 