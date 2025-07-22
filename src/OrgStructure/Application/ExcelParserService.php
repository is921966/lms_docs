<?php

namespace App\OrgStructure\Application;

use App\OrgStructure\Application\DTO\ParsedDepartment;
use App\OrgStructure\Application\DTO\ParsedEmployee;
use App\OrgStructure\Application\Exception\InvalidFileFormatException;
use App\OrgStructure\Application\Exception\EmptyFileException;
use App\OrgStructure\Domain\ValueObject\DepartmentCode;
use App\OrgStructure\Domain\ValueObject\TabNumber;
use PhpOffice\PhpSpreadsheet\IOFactory;
use PhpOffice\PhpSpreadsheet\Cell\Coordinate;

class ExcelParserService
{
    /**
     * Parse Excel file and return structured data
     * 
     * @return array{
     *   departments: ParsedDepartment[],
     *   employees: ParsedEmployee[],
     *   errors: string[],
     *   warnings: string[]
     * }
     */
    public function parseFile(string $filePath): array
    {
        if (!file_exists($filePath)) {
            throw new \InvalidArgumentException("File not found: $filePath");
        }
        
        // Check file extension
        $extension = strtolower(pathinfo($filePath, PATHINFO_EXTENSION));
        if (!in_array($extension, ['xlsx', 'xls', 'ods', 'csv'])) {
            throw new InvalidFileFormatException(basename($filePath));
        }
        
        try {
            $spreadsheet = IOFactory::load($filePath);
        } catch (\Exception $e) {
            throw new InvalidFileFormatException(basename($filePath));
        }
        
        $sheet = $spreadsheet->getActiveSheet();
        $highestRow = $sheet->getHighestDataRow();
        $highestColumn = $sheet->getHighestDataColumn();
        $highestColIndex = Coordinate::columnIndexFromString($highestColumn);
        
        // Check if file is truly empty
        $hasData = false;
        for ($row = 1; $row <= min(10, $highestRow); $row++) {
            for ($col = 1; $col <= min(10, $highestColIndex); $col++) {
                $columnLetter = Coordinate::stringFromColumnIndex($col);
                $cellValue = $sheet->getCell($columnLetter . $row)->getValue();
                if (!empty($cellValue)) {
                    $hasData = true;
                    break 2;
                }
            }
        }
        
        if (!$hasData) {
            throw new EmptyFileException();
        }
        
        $departments = [];
        $employees = [];
        $errors = [];
        $warnings = [];
        $seenCodes = [];
        $seenTabNumbers = [];
        
        // Find header row
        $headerRow = $this->findHeaderRow($sheet, $highestRow);
        if ($headerRow === null) {
            $errors[] = 'Cannot find header row with expected columns';
            return compact('departments', 'employees', 'errors', 'warnings');
        }
        
        // Process data rows
        for ($row = $headerRow + 1; $row <= $highestRow; $row++) {
            $code = $this->getCellValue($sheet, 'A', $row);
            $name = $this->getCellValue($sheet, 'B', $row);
            $tabNumber = $this->getCellValue($sheet, 'C', $row);
            $employeeName = $this->getCellValue($sheet, 'D', $row);
            $position = $this->getCellValue($sheet, 'E', $row);
            
            // Skip empty rows
            if (empty($code) && empty($name) && empty($tabNumber)) {
                continue;
            }
            
            // Process department
            if (!empty($code) && !empty($name)) {
                try {
                    // Validate code format
                    new DepartmentCode($code);
                    
                    // Check for duplicates
                    if (isset($seenCodes[$code])) {
                        $warnings[] = "Duplicate department code '$code' at row $row";
                    } else {
                        $seenCodes[$code] = true;
                        
                        $parentCode = $this->determineParentCode($code);
                        $departments[] = new ParsedDepartment(
                            code: $code,
                            name: $name,
                            parentCode: $parentCode,
                            rowNumber: $row
                        );
                    }
                } catch (\Exception $e) {
                    $errors[] = "Invalid department code '$code' at row $row: " . $e->getMessage();
                }
            }
            
            // Process employee
            if (!empty($tabNumber) && !empty($employeeName)) {
                try {
                    // Validate tab number
                    new TabNumber($tabNumber);
                    
                    // Check for duplicates
                    if (isset($seenTabNumbers[$tabNumber])) {
                        $warnings[] = "Duplicate tab number '$tabNumber' at row $row";
                    } else {
                        $seenTabNumbers[$tabNumber] = true;
                        
                        // Determine department code for employee
                        $employeeDeptCode = $this->determineEmployeeDepartmentCode(
                            $sheet, 
                            $row, 
                            $code, 
                            $departments
                        );
                        
                        if ($employeeDeptCode) {
                            $employees[] = new ParsedEmployee(
                                tabNumber: $tabNumber,
                                name: $employeeName,
                                position: $position ?: 'Не указана',
                                departmentCode: $employeeDeptCode,
                                rowNumber: $row
                            );
                        } else {
                            $errors[] = "Cannot determine department for employee '$employeeName' at row $row";
                        }
                    }
                } catch (\Exception $e) {
                    $errors[] = "Invalid tab number '$tabNumber' at row $row: " . $e->getMessage();
                }
            }
        }
        
        // Only throw EmptyFileException if we couldn't find any data at all
        // If we found data but it was invalid, we should return the errors
        if (empty($departments) && empty($employees) && empty($errors)) {
            throw new EmptyFileException();
        }
        
        return compact('departments', 'employees', 'errors', 'warnings');
    }
    
    private function getCellValue($sheet, string $column, int $row): ?string
    {
        $value = $sheet->getCell($column . $row)->getValue();
        if ($value === null) {
            return null;
        }
        
        // Handle merged cells
        $cell = $sheet->getCell($column . $row);
        if ($cell->isInMergeRange()) {
            $mergeRange = $cell->getMergeRange();
            if ($mergeRange) {
                [$startCell] = Coordinate::splitRange($mergeRange);
                $value = $sheet->getCell($startCell[0])->getValue();
            }
        }
        
        return trim((string)$value);
    }
    
    private function findHeaderRow($sheet, int $maxRow): ?int
    {
        for ($row = 1; $row <= min(10, $maxRow); $row++) {
            $a = strtolower($this->getCellValue($sheet, 'A', $row) ?? '');
            $b = strtolower($this->getCellValue($sheet, 'B', $row) ?? '');
            
            // More flexible header detection
            if ((str_contains($a, 'код') || $a === 'код') && 
                (str_contains($b, 'наимен') || $b === 'наименование')) {
                return $row;
            }
        }
        
        // If not found, assume first row is header
        return 1;
    }
    
    private function determineParentCode(string $code): ?string
    {
        $parts = explode('.', $code);
        if (count($parts) <= 1) {
            return null;
        }
        
        array_pop($parts);
        return implode('.', $parts);
    }
    
    private function determineEmployeeDepartmentCode(
        $sheet, 
        int $row, 
        ?string $currentRowCode,
        array $departments
    ): ?string {
        // If current row has a code, use it
        if ($currentRowCode) {
            return $currentRowCode;
        }
        
        // Look up for the nearest department code
        for ($r = $row - 1; $r >= 1; $r--) {
            $code = $this->getCellValue($sheet, 'A', $r);
            if ($code) {
                // Verify it's a valid department code
                foreach ($departments as $dept) {
                    if ($dept->code === $code) {
                        return $code;
                    }
                }
            }
        }
        
        return null;
    }
    
    /**
     * Generate import summary
     */
    public function generateImportSummary(array $parseResult): array
    {
        $departments = $parseResult['departments'];
        $employees = $parseResult['employees'];
        
        $levels = [];
        foreach ($departments as $dept) {
            $level = substr_count($dept->code, '.') + 1;
            $levels[$level] = ($levels[$level] ?? 0) + 1;
        }
        
        $positions = [];
        foreach ($employees as $emp) {
            $positions[$emp->position] = ($positions[$emp->position] ?? 0) + 1;
        }
        
        return [
            'totalDepartments' => count($departments),
            'totalEmployees' => count($employees),
            'departmentsByLevel' => $levels,
            'employeesByPosition' => $positions,
            'errors' => count($parseResult['errors']),
            'warnings' => count($parseResult['warnings']),
        ];
    }
} 