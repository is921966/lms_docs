<?php

namespace App\OrgStructure\Http\Controller;

use App\Common\Http\BaseController;
use App\OrgStructure\Application\OrgStructureService;
use App\OrgStructure\Application\ExcelParserService;
use App\OrgStructure\Application\DTO\CreateDepartmentDTO;
use App\OrgStructure\Application\DTO\CreateEmployeeDTO;
use App\OrgStructure\Application\Exception\InvalidFileFormatException;
use App\OrgStructure\Application\Exception\EmptyFileException;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class ImportController extends BaseController
{
    public function __construct(
        private OrgStructureService $service,
        private ExcelParserService $parser
    ) {
    }
    
    /**
     * Import organization structure from Excel
     * 
     * @param Request $request
     * @return JsonResponse
     */
    public function import(Request $request): JsonResponse
    {
        try {
            $request->validate([
                'file' => 'required|file|mimes:xlsx,xls|max:10240', // 10MB max
                'mode' => 'nullable|in:merge,replace',
                'dryRun' => 'nullable|boolean'
            ]);
            
            $file = $request->file('file');
            $mode = $request->input('mode', 'merge');
            $dryRun = (bool) $request->input('dryRun', false);
            
            // Parse Excel file
            $parseResult = $this->parser->parseFile($file->getPathname());
            
            // Check for parsing errors
            if (!empty($parseResult['errors'])) {
                return response()->json([
                    'success' => false,
                    'message' => 'File contains errors',
                    'errors' => $parseResult['errors'],
                    'warnings' => $parseResult['warnings'],
                    'summary' => $this->parser->generateImportSummary($parseResult)
                ], 422);
            }
            
            // Generate summary
            $summary = $this->parser->generateImportSummary($parseResult);
            
            // If dry run, return preview
            if ($dryRun) {
                return response()->json([
                    'success' => true,
                    'message' => 'Dry run completed',
                    'preview' => [
                        'departments' => array_slice($parseResult['departments'], 0, 10),
                        'employees' => array_slice($parseResult['employees'], 0, 10),
                        'summary' => $summary,
                        'warnings' => $parseResult['warnings']
                    ]
                ]);
            }
            
            // Perform actual import
            $importResult = $this->performImport($parseResult, $mode);
            
            return response()->json([
                'success' => true,
                'message' => 'Import completed successfully',
                'result' => $importResult,
                'warnings' => $parseResult['warnings']
            ]);
            
        } catch (InvalidFileFormatException $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 422);
        } catch (EmptyFileException $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 422);
        } catch (\Exception $e) {
            Log::error('Import failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Import failed',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Perform actual import
     */
    private function performImport(array $parseResult, string $mode): array
    {
        $created = ['departments' => 0, 'employees' => 0];
        $updated = ['departments' => 0, 'employees' => 0];
        $skipped = ['departments' => 0, 'employees' => 0];
        $errors = [];
        
        DB::beginTransaction();
        
        try {
            // If replace mode, delete existing data
            if ($mode === 'replace') {
                DB::table('org_employees')->delete();
                DB::table('departments')->delete();
            }
            
            // Import departments (sorted by hierarchy)
            $sortedDepartments = $this->sortDepartmentsByHierarchy($parseResult['departments']);
            
            foreach ($sortedDepartments as $parsedDept) {
                try {
                    // Check if department already exists
                    $existing = DB::table('departments')
                        ->where('code', $parsedDept->code)
                        ->first();
                    
                    if ($existing) {
                        if ($mode === 'merge') {
                            // Update existing department
                            DB::table('departments')
                                ->where('id', $existing->id)
                                ->update([
                                    'name' => $parsedDept->name,
                                    'updated_at' => now()
                                ]);
                            $updated['departments']++;
                        } else {
                            $skipped['departments']++;
                        }
                    } else {
                        // Find parent ID
                        $parentId = null;
                        if ($parsedDept->parentCode) {
                            $parent = DB::table('departments')
                                ->where('code', $parsedDept->parentCode)
                                ->first();
                            $parentId = $parent?->id;
                        }
                        
                        // Create new department
                        $dto = new CreateDepartmentDTO(
                            name: $parsedDept->name,
                            code: $parsedDept->code,
                            parentId: $parentId
                        );
                        
                        $this->service->createDepartment($dto);
                        $created['departments']++;
                    }
                } catch (\Exception $e) {
                    $errors[] = "Department '{$parsedDept->name}' (row {$parsedDept->rowNumber}): " . $e->getMessage();
                }
            }
            
            // Import employees
            foreach ($parseResult['employees'] as $parsedEmp) {
                try {
                    // Find department ID
                    $department = DB::table('departments')
                        ->where('code', $parsedEmp->departmentCode)
                        ->first();
                    
                    if (!$department) {
                        throw new \Exception("Department with code '{$parsedEmp->departmentCode}' not found");
                    }
                    
                    // Check if employee already exists
                    $existing = DB::table('org_employees')
                        ->where('tab_number', $parsedEmp->tabNumber)
                        ->first();
                    
                    if ($existing) {
                        if ($mode === 'merge') {
                            // Update existing employee
                            DB::table('org_employees')
                                ->where('id', $existing->id)
                                ->update([
                                    'name' => $parsedEmp->name,
                                    'position' => $parsedEmp->position,
                                    'department_id' => $department->id,
                                    'email' => $parsedEmp->email,
                                    'phone' => $parsedEmp->phone,
                                    'updated_at' => now()
                                ]);
                            $updated['employees']++;
                        } else {
                            $skipped['employees']++;
                        }
                    } else {
                        // Create new employee
                        $dto = new CreateEmployeeDTO(
                            tabNumber: $parsedEmp->tabNumber,
                            name: $parsedEmp->name,
                            position: $parsedEmp->position,
                            departmentId: $department->id,
                            email: $parsedEmp->email,
                            phone: $parsedEmp->phone
                        );
                        
                        $this->service->createEmployee($dto);
                        $created['employees']++;
                    }
                } catch (\Exception $e) {
                    $errors[] = "Employee '{$parsedEmp->name}' (row {$parsedEmp->rowNumber}): " . $e->getMessage();
                }
            }
            
            DB::commit();
            
            return [
                'created' => $created,
                'updated' => $updated,
                'skipped' => $skipped,
                'errors' => $errors,
                'total' => [
                    'departments' => $created['departments'] + $updated['departments'] + $skipped['departments'],
                    'employees' => $created['employees'] + $updated['employees'] + $skipped['employees']
                ]
            ];
            
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }
    
    /**
     * Sort departments by hierarchy level
     */
    private function sortDepartmentsByHierarchy(array $departments): array
    {
        usort($departments, function ($a, $b) {
            $levelA = substr_count($a->code, '.');
            $levelB = substr_count($b->code, '.');
            
            if ($levelA === $levelB) {
                return strcmp($a->code, $b->code);
            }
            
            return $levelA - $levelB;
        });
        
        return $departments;
    }
} 