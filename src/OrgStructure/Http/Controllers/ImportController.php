<?php

namespace App\OrgStructure\Http\Controllers;

use App\OrgStructure\Application\Services\ImportOrchestrator;
use App\OrgStructure\Application\Services\CSVParser;
use App\Common\Http\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\BinaryFileResponse;
use Symfony\Component\HttpFoundation\ResponseHeaderBag;

class ImportController
{
    public function __construct(
        private ImportOrchestrator $importOrchestrator
    ) {}

    public function importEmployees(Request $request): JsonResponse
    {
        $uploadedFile = $request->files->get('file');
        
        if (!$uploadedFile) {
            return JsonResponse::error('No file uploaded', Response::HTTP_BAD_REQUEST);
        }
        
        // Validate file type
        $mimeType = $uploadedFile->getMimeType();
        $extension = $uploadedFile->getClientOriginalExtension();
        
        $validMimeTypes = ['text/csv', 'application/csv', 'application/vnd.ms-excel', 'text/plain'];
        $validExtensions = ['csv'];
        
        // Allow text/plain only with csv extension
        if ($mimeType === 'text/plain' && strtolower($extension) !== 'csv') {
            return JsonResponse::error('Invalid file type. Please upload a CSV file', Response::HTTP_BAD_REQUEST);
        }
        
        if (!in_array($mimeType, $validMimeTypes) || 
            !in_array(strtolower($extension), $validExtensions)) {
            return JsonResponse::error('Invalid file type. Please upload a CSV file', Response::HTTP_BAD_REQUEST);
        }
        
        try {
            // Import the CSV file
            $filePath = $uploadedFile->getPathname();
            $options = [
                'skipOnError' => $request->query->getBoolean('skipOnError', false)
            ];
            
            $result = $this->importOrchestrator->importFromCsv($filePath, $options);
            
            // Transform the result for response
            $responseData = [
                'totalProcessed' => $result->getTotalProcessed(),
                'successful' => $result->getSuccessful(),
                'errors' => $result->getErrors(),
                'departmentsCreated' => $result->getDepartmentsCreated(),
                'positionsCreated' => $result->getPositionsCreated(),
                'employeesCreated' => $result->getEmployeesCreated(),
                'employeesUpdated' => $result->getEmployeesUpdated()
            ];
            
            if ($result->hasErrors()) {
                $responseData['errorDetails'] = array_map(function ($error) {
                    return [
                        'type' => $error->getType(),
                        'message' => $error->getMessage(),
                        'row' => $error->getRow(),
                        'data' => $error->getData()
                    ];
                }, $result->getErrorList());
            }
            
            return JsonResponse::success($responseData);
            
        } catch (\Exception $e) {
            return JsonResponse::error('Import failed: ' . $e->getMessage(), Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    public function getTemplate(): Response
    {
        $headers = [
            'ФИО',
            'Таб.номер',
            'Email',
            'Телефон',
            'Подразделение',
            'Должность',
            'Руководитель'
        ];
        
        $exampleRows = [
            [
                'Иванов Иван Иванович',
                'EMP001',
                'ivanov@company.ru',
                '+7-123-456-7890',
                'Отдел разработки',
                'Старший разработчик',
                ''
            ],
            [
                'Петров Петр Петрович',
                'EMP002',
                'petrov@company.ru',
                '+7-123-456-7891',
                'Отдел разработки',
                'Разработчик',
                'EMP001'
            ],
            [
                'Сидорова Мария Ивановна',
                'EMP003',
                'sidorova@company.ru',
                '+7-123-456-7892',
                'Отдел тестирования',
                'Тестировщик',
                ''
            ]
        ];
        
        // Create CSV content
        $csvContent = implode(',', $headers) . "\n";
        foreach ($exampleRows as $row) {
            $csvContent .= implode(',', array_map(function ($value) {
                // Escape values containing commas or quotes
                if (strpos($value, ',') !== false || strpos($value, '"') !== false) {
                    return '"' . str_replace('"', '""', $value) . '"';
                }
                return $value;
            }, $row)) . "\n";
        }
        
        // Add UTF-8 BOM for Excel compatibility
        $csvContent = "\xEF\xBB\xBF" . $csvContent;
        
        $response = new Response($csvContent);
        $response->headers->set('Content-Type', 'text/csv; charset=UTF-8');
        $response->headers->set('Content-Disposition', 'attachment; filename="org_structure_template.csv"');
        
        return $response;
    }

    public function validateCsv(Request $request): JsonResponse
    {
        $uploadedFile = $request->files->get('file');
        
        if (!$uploadedFile) {
            return JsonResponse::error('No file uploaded', Response::HTTP_BAD_REQUEST);
        }
        
        try {
            $parser = new CSVParser();
            $filePath = $uploadedFile->getPathname();
            
            // Parse and validate
            $rows = $parser->parse($filePath);
            
            $stats = [
                'totalRows' => count($rows),
                'validRows' => 0,
                'invalidRows' => 0,
                'departments' => [],
                'positions' => [],
                'warnings' => []
            ];
            
            foreach ($rows as $index => $row) {
                $rowNumber = $index + 2; // +1 for 0-index, +1 for header row
                
                // Validate required fields
                $errors = [];
                if (empty($row['ФИО'] ?? $row['Full Name'] ?? null)) {
                    $errors[] = "ФИО is required";
                }
                if (empty($row['Таб.номер'] ?? $row['Tab Number'] ?? null)) {
                    $errors[] = "Таб.номер is required";
                }
                
                // Validate email format if provided
                $email = $row['Email'] ?? $row['Электронная почта'] ?? null;
                if ($email && !filter_var($email, FILTER_VALIDATE_EMAIL)) {
                    $errors[] = "Invalid email format";
                }
                
                if (empty($errors)) {
                    $stats['validRows']++;
                    
                    // Collect unique departments and positions
                    $dept = $row['Подразделение'] ?? $row['Department'] ?? null;
                    if ($dept && !in_array($dept, $stats['departments'])) {
                        $stats['departments'][] = $dept;
                    }
                    
                    $pos = $row['Должность'] ?? $row['Position'] ?? null;
                    if ($pos && !in_array($pos, $stats['positions'])) {
                        $stats['positions'][] = $pos;
                    }
                } else {
                    $stats['invalidRows']++;
                    $stats['warnings'][] = [
                        'row' => $rowNumber,
                        'errors' => $errors
                    ];
                }
            }
            
            $stats['departments'] = array_values($stats['departments']);
            $stats['positions'] = array_values($stats['positions']);
            $stats['departmentCount'] = count($stats['departments']);
            $stats['positionCount'] = count($stats['positions']);
            
            return JsonResponse::success($stats);
            
        } catch (\Exception $e) {
            return JsonResponse::error('Validation failed: ' . $e->getMessage(), Response::HTTP_BAD_REQUEST);
        }
    }
} 