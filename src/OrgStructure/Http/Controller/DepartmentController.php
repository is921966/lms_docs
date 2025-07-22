<?php

namespace App\OrgStructure\Http\Controller;

use App\Common\Http\BaseController;
use App\OrgStructure\Application\OrgStructureService;
use App\OrgStructure\Application\DTO\CreateDepartmentDTO;
use App\OrgStructure\Application\DTO\UpdateDepartmentDTO;
use App\OrgStructure\Application\Exception\DepartmentNotFoundException;
use App\OrgStructure\Application\Exception\DuplicateCodeException;
use App\OrgStructure\Application\Exception\DepartmentHasChildrenException;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\ValidationException;

class DepartmentController extends BaseController
{
    public function __construct(
        private OrgStructureService $service
    ) {
    }
    
    /**
     * Get department tree
     * 
     * @return JsonResponse
     */
    public function tree(Request $request): JsonResponse
    {
        try {
            $tree = $this->service->getDepartmentTree();
            
            return response()->json([
                'success' => true,
                'data' => $this->serializeDepartments($tree)
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to load department tree',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Create department
     * 
     * @param Request $request
     * @return JsonResponse
     */
    public function create(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'name' => 'required|string|max:255',
                'code' => 'required|string|max:50',
                'parentId' => 'nullable|string|uuid'
            ]);
            
            $dto = new CreateDepartmentDTO(
                name: $validated['name'],
                code: $validated['code'],
                parentId: $validated['parentId'] ?? null
            );
            
            $department = $this->service->createDepartment($dto);
            
            return response()->json([
                'success' => true,
                'message' => 'Department created successfully',
                'data' => $this->serializeDepartment($department)
            ], 201);
            
        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $e->errors()
            ], 422);
        } catch (DuplicateCodeException $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 409);
        } catch (DepartmentNotFoundException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Parent department not found'
            ], 404);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to create department',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Update department
     * 
     * @param Request $request
     * @param string $id
     * @return JsonResponse
     */
    public function update(Request $request, string $id): JsonResponse
    {
        try {
            $validated = $request->validate([
                'name' => 'nullable|string|max:255'
            ]);
            
            $dto = new UpdateDepartmentDTO(
                name: $validated['name'] ?? null
            );
            
            $department = $this->service->updateDepartment($id, $dto);
            
            return response()->json([
                'success' => true,
                'message' => 'Department updated successfully',
                'data' => $this->serializeDepartment($department)
            ]);
            
        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $e->errors()
            ], 422);
        } catch (DepartmentNotFoundException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Department not found'
            ], 404);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update department',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Delete department
     * 
     * @param string $id
     * @return JsonResponse
     */
    public function delete(string $id): JsonResponse
    {
        try {
            $this->service->deleteDepartment($id);
            
            return response()->json([
                'success' => true,
                'message' => 'Department deleted successfully'
            ]);
            
        } catch (DepartmentNotFoundException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Department not found'
            ], 404);
        } catch (DepartmentHasChildrenException $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 409);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete department',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Serialize department tree
     */
    private function serializeDepartments(array $departments): array
    {
        return array_map(fn($dept) => $this->serializeDepartment($dept), $departments);
    }
    
    /**
     * Serialize single department
     */
    private function serializeDepartment($department): array
    {
        $data = [
            'id' => $department->getId(),
            'name' => $department->getName(),
            'code' => $department->getCode()->getValue(),
            'parentId' => $department->getParentId(),
            'employeeCount' => $department->getEmployeeCount(),
        ];
        
        $children = $department->getChildren();
        if (!empty($children)) {
            $data['children'] = $this->serializeDepartments($children);
        }
        
        return $data;
    }
} 