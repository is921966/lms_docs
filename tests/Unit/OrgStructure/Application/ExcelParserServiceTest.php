<?php

namespace Tests\Unit\OrgStructure\Application;

use Tests\TestCase;
use App\OrgStructure\Application\ExcelParserService;
use App\OrgStructure\Application\DTO\ParsedDepartment;
use App\OrgStructure\Application\DTO\ParsedEmployee;
use App\OrgStructure\Application\Exception\InvalidFileFormatException;
use App\OrgStructure\Application\Exception\EmptyFileException;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;

class ExcelParserServiceTest extends TestCase
{
    private ExcelParserService $parser;
    private string $testFilePath;
    
    protected function setUp(): void
    {
        parent::setUp();
        $this->parser = new ExcelParserService();
        $this->testFilePath = sys_get_temp_dir() . '/test_org_structure.xlsx';
    }
    
    protected function tearDown(): void
    {
        if (file_exists($this->testFilePath)) {
            unlink($this->testFilePath);
        }
        parent::tearDown();
    }
    
    /** @test */
    public function it_parses_valid_excel_file(): void
    {
        // Arrange
        $this->createTestFile();
        
        // Act
        $result = $this->parser->parseFile($this->testFilePath);
        
        // Assert
        $this->assertCount(3, $result['departments']);
        $this->assertCount(4, $result['employees']);
        
        // Check first department
        $dept = $result['departments'][0];
        $this->assertInstanceOf(ParsedDepartment::class, $dept);
        $this->assertEquals('АП', $dept->code);
        $this->assertEquals('Аппарат Президента', $dept->name);
        $this->assertNull($dept->parentCode);
        
        // Check employee
        $employee = $result['employees'][0];
        $this->assertInstanceOf(ParsedEmployee::class, $employee);
        $this->assertEquals('АР21000612', $employee->tabNumber);
        $this->assertEquals('Иванов Иван Иванович', $employee->name);
        $this->assertEquals('Руководитель департамента ИТ', $employee->position);
        $this->assertEquals('АП.3.2', $employee->departmentCode);
    }
    
    /** @test */
    public function it_throws_exception_for_invalid_file_format(): void
    {
        // Arrange - create non-Excel file with .txt extension
        $invalidFile = sys_get_temp_dir() . '/test_invalid.txt';
        file_put_contents($invalidFile, 'Not an Excel file');
        
        try {
            // Act & Assert
            $this->expectException(InvalidFileFormatException::class);
            $this->parser->parseFile($invalidFile);
        } finally {
            if (file_exists($invalidFile)) {
                unlink($invalidFile);
            }
        }
    }
    
    /** @test */
    public function it_throws_exception_for_empty_file(): void
    {
        // Arrange
        $spreadsheet = new Spreadsheet();
        $writer = new Xlsx($spreadsheet);
        $writer->save($this->testFilePath);
        
        // Act & Assert
        $this->expectException(EmptyFileException::class);
        $this->parser->parseFile($this->testFilePath);
    }
    
    /** @test */
    public function it_validates_department_codes(): void
    {
        // Arrange
        $this->createFileWithInvalidData();
        
        // Act
        $result = $this->parser->parseFile($this->testFilePath);
        
        // Assert
        $this->assertNotEmpty($result['errors']);
        $this->assertStringContainsString('Invalid department code', $result['errors'][0]);
    }
    
    /** @test */
    public function it_validates_tab_numbers(): void
    {
        // Arrange
        $this->createFileWithInvalidTabNumbers();
        
        // Act
        $result = $this->parser->parseFile($this->testFilePath);
        
        // Assert
        $this->assertNotEmpty($result['errors']);
        $this->assertStringContainsString('Invalid tab number', $result['errors'][0]);
    }
    
    /** @test */
    public function it_builds_department_hierarchy(): void
    {
        // Arrange
        $this->createTestFile();
        
        // Act
        $result = $this->parser->parseFile($this->testFilePath);
        
        // Assert
        $dept = $result['departments'][1]; // АП.3
        $this->assertEquals('АП', $dept->parentCode);
        
        $dept = $result['departments'][2]; // АП.3.2
        $this->assertEquals('АП.3', $dept->parentCode);
    }
    
    /** @test */
    public function it_handles_merged_cells(): void
    {
        // Arrange
        $this->createFileWithMergedCells();
        
        // Act
        $result = $this->parser->parseFile($this->testFilePath);
        
        // Assert
        $this->assertCount(1, $result['departments']);
        $dept = $result['departments'][0];
        $this->assertEquals('Объединенный департамент', $dept->name);
    }
    
    /** @test */
    public function it_skips_header_rows(): void
    {
        // Arrange
        $this->createFileWithHeaders();
        
        // Act
        $result = $this->parser->parseFile($this->testFilePath);
        
        // Assert
        // Should not include header rows in results
        foreach ($result['departments'] as $dept) {
            $this->assertNotEquals('Код', $dept->code);
            $this->assertNotEquals('Наименование', $dept->name);
        }
    }
    
    /** @test */
    public function it_reports_duplicate_codes(): void
    {
        // Arrange
        $this->createFileWithDuplicates();
        
        // Act
        $result = $this->parser->parseFile($this->testFilePath);
        
        // Assert
        $this->assertNotEmpty($result['warnings']);
        $this->assertStringContainsString('Duplicate department code', $result['warnings'][0]);
    }
    
    private function createTestFile(): void
    {
        $spreadsheet = new Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();
        
        // Headers
        $sheet->setCellValue('A1', 'Код');
        $sheet->setCellValue('B1', 'Наименование');
        $sheet->setCellValue('C1', 'Таб. номер');
        $sheet->setCellValue('D1', 'ФИО');
        $sheet->setCellValue('E1', 'Должность');
        
        // Departments with employees
        $sheet->setCellValue('A2', 'АП');
        $sheet->setCellValue('B2', 'Аппарат Президента');
        
        $sheet->setCellValue('A3', 'АП.3');
        $sheet->setCellValue('B3', 'Департамент');
        
        $sheet->setCellValue('A4', 'АП.3.2');
        $sheet->setCellValue('B4', 'Департамент ИТ');
        $sheet->setCellValue('C4', 'АР21000612');
        $sheet->setCellValue('D4', 'Иванов Иван Иванович');
        $sheet->setCellValue('E4', 'Руководитель департамента ИТ');
        
        // More employees
        $sheet->setCellValue('C5', 'АР21000613');
        $sheet->setCellValue('D5', 'Петров Петр Петрович');
        $sheet->setCellValue('E5', 'Главный специалист');
        
        $sheet->setCellValue('C6', 'АР21000614');
        $sheet->setCellValue('D6', 'Сидоров Сидор Сидорович');
        $sheet->setCellValue('E6', 'Ведущий программист');
        
        // Employee in parent department
        $sheet->setCellValue('A7', 'АП.3');
        $sheet->setCellValue('C7', 'АР21000615');
        $sheet->setCellValue('D7', 'Козлов Козел Козлович');
        $sheet->setCellValue('E7', 'Руководитель департамента');
        
        $writer = new Xlsx($spreadsheet);
        $writer->save($this->testFilePath);
    }
    
    private function createFileWithInvalidData(): void
    {
        $spreadsheet = new Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();
        
        $sheet->setCellValue('A1', 'Код');
        $sheet->setCellValue('B1', 'Наименование');
        
        // Invalid code format
        $sheet->setCellValue('A2', 'INVALID_CODE');
        $sheet->setCellValue('B2', 'Некорректный департамент');
        
        $writer = new Xlsx($spreadsheet);
        $writer->save($this->testFilePath);
    }
    
    private function createFileWithInvalidTabNumbers(): void
    {
        $spreadsheet = new Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();
        
        $sheet->setCellValue('A1', 'Код');
        $sheet->setCellValue('B1', 'Наименование');
        $sheet->setCellValue('C1', 'Таб. номер');
        $sheet->setCellValue('D1', 'ФИО');
        
        $sheet->setCellValue('A2', 'АП.1');
        $sheet->setCellValue('B2', 'Департамент');
        $sheet->setCellValue('C2', 'INVALID123'); // Invalid format
        $sheet->setCellValue('D2', 'Тестовый сотрудник');
        
        $writer = new Xlsx($spreadsheet);
        $writer->save($this->testFilePath);
    }
    
    private function createFileWithMergedCells(): void
    {
        $spreadsheet = new Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();
        
        $sheet->setCellValue('A1', 'Код');
        $sheet->setCellValue('B1', 'Наименование');
        
        // Merge cells B2:B3
        $sheet->mergeCells('B2:B3');
        $sheet->setCellValue('A2', 'АП.1');
        $sheet->setCellValue('B2', 'Объединенный департамент');
        
        $writer = new Xlsx($spreadsheet);
        $writer->save($this->testFilePath);
    }
    
    private function createFileWithHeaders(): void
    {
        $spreadsheet = new Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();
        
        // Multiple header rows
        $sheet->setCellValue('A1', 'Организационная структура');
        $sheet->setCellValue('A2', 'Дата: ' . date('d.m.Y'));
        $sheet->setCellValue('A3', 'Код');
        $sheet->setCellValue('B3', 'Наименование');
        
        // Actual data
        $sheet->setCellValue('A4', 'АП');
        $sheet->setCellValue('B4', 'Аппарат Президента');
        
        $writer = new Xlsx($spreadsheet);
        $writer->save($this->testFilePath);
    }
    
    private function createFileWithDuplicates(): void
    {
        $spreadsheet = new Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();
        
        $sheet->setCellValue('A1', 'Код');
        $sheet->setCellValue('B1', 'Наименование');
        
        // Duplicate codes
        $sheet->setCellValue('A2', 'АП.1');
        $sheet->setCellValue('B2', 'Департамент 1');
        
        $sheet->setCellValue('A3', 'АП.1');
        $sheet->setCellValue('B3', 'Департамент 2');
        
        $writer = new Xlsx($spreadsheet);
        $writer->save($this->testFilePath);
    }
} 