<?php

namespace App\OrgStructure\Http\Controllers;

use App\OrgStructure\Domain\Repositories\DepartmentRepositoryInterface;
use App\OrgStructure\Domain\Models\Department;
use App\OrgStructure\Domain\ValueObjects\DepartmentId;
use App\OrgStructure\Domain\ValueObjects\DepartmentCode;
use App\Common\Http\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class DepartmentController
{
    public function __construct(
        private DepartmentRepositoryInterface $departmentRepository
    ) {}

    public function index(): JsonResponse
    {
        $departments = $this->departmentRepository->findAll();
        
        $data = array_map(function (Department $department) {
            return $this->transformDepartment($department);
        }, $departments);
        
        return JsonResponse::success($data);
    }

    public function show(string $id): JsonResponse
    {
        $department = $this->departmentRepository->findById(DepartmentId::fromString($id));
        
        if (!$department) {
            return JsonResponse::notFound('Department not found');
        }
        
        return JsonResponse::success($this->transformDepartment($department));
    }

    public function store(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true);
        
        // Validate parent exists if provided
        $parentId = null;
        if (!empty($data['parentId'])) {
            $parent = $this->departmentRepository->findById(DepartmentId::fromString($data['parentId']));
            if (!$parent) {
                return JsonResponse::notFound('Parent department not found');
            }
            $parentId = DepartmentId::fromString($data['parentId']);
        }
        
        // Create department
        $department = new Department(
            DepartmentId::generate(),
            new DepartmentCode($data['code']),
            $data['name'],
            null  // Parent will be set via ID after creation
        );
        
        if ($parentId !== null) {
            $department->setParentId($parentId);
        }
        
        $this->departmentRepository->save($department);
        
        return JsonResponse::success($this->transformDepartment($department), Response::HTTP_CREATED);
    }

    public function update(Request $request, string $id): JsonResponse
    {
        $department = $this->departmentRepository->findById(DepartmentId::fromString($id));
        
        if (!$department) {
            return JsonResponse::notFound('Department not found');
        }
        
        $data = json_decode($request->getContent(), true);
        
        // Update name if provided
        if (isset($data['name'])) {
            $department->rename($data['name']);
        }
        
        // Update parent if provided
        if (isset($data['parentId'])) {
            if ($data['parentId'] === null) {
                $department->removeFromParent();
            } else {
                $parent = $this->departmentRepository->findById(DepartmentId::fromString($data['parentId']));
                if (!$parent) {
                    return JsonResponse::notFound('Parent department not found');
                }
                
                // Check for circular reference
                if ($this->wouldCreateCircularReference($department, DepartmentId::fromString($data['parentId']))) {
                    return JsonResponse::error('Cannot set parent: would create circular reference', 400);
                }
                
                $department->setParentId(DepartmentId::fromString($data['parentId']));
            }
        }
        
        $this->departmentRepository->save($department);
        
        return JsonResponse::success($this->transformDepartment($department));
    }

    public function destroy(string $id): JsonResponse
    {
        $department = $this->departmentRepository->findById(DepartmentId::fromString($id));
        
        if (!$department) {
            return JsonResponse::notFound('Department not found');
        }
        
        // Check if department has child departments
        $allDepartments = $this->departmentRepository->findAll();
        foreach ($allDepartments as $dept) {
            if ($dept->getParentId() && $dept->getParentId()->equals($department->getId())) {
                return JsonResponse::error('Cannot delete department with child departments', 400);
            }
        }
        
        $this->departmentRepository->delete(DepartmentId::fromString($id));
        
        return new JsonResponse(null, Response::HTTP_NO_CONTENT);
    }

    private function transformDepartment(Department $department): array
    {
        return [
            'id' => $department->getId()->toString(),
            'code' => $department->getCode()->toString(),
            'name' => $department->getName(),
            'parentId' => $department->getParentId()?->toString(),
            'isActive' => $department->isActive()
        ];
    }
    
    private function wouldCreateCircularReference(Department $department, DepartmentId $newParentId): bool
    {
        // Can't be your own parent
        if ($department->getId()->equals($newParentId)) {
            return true;
        }
        
        // Check if the new parent is a descendant of this department
        $current = $this->departmentRepository->findById($newParentId);
        while ($current && $current->getParentId()) {
            if ($current->getParentId()->equals($department->getId())) {
                return true;
            }
            $current = $this->departmentRepository->findById($current->getParentId());
        }
        
        return false;
    }
} 