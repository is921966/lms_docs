<?php

namespace App\OrgStructure\Http\Controllers;

use App\OrgStructure\Domain\Repositories\EmployeeRepositoryInterface;
use App\OrgStructure\Domain\Repositories\DepartmentRepositoryInterface;
use App\OrgStructure\Domain\Repositories\PositionRepositoryInterface;
use App\OrgStructure\Domain\Models\Employee;
use App\OrgStructure\Domain\ValueObjects\EmployeeId;
use App\OrgStructure\Domain\ValueObjects\DepartmentId;
use App\OrgStructure\Domain\ValueObjects\PositionId;
use App\OrgStructure\Domain\ValueObjects\TabNumber;
use App\OrgStructure\Domain\ValueObjects\PersonalInfo;
use App\Common\Http\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class EmployeeController
{
    public function __construct(
        private EmployeeRepositoryInterface $employeeRepository,
        private DepartmentRepositoryInterface $departmentRepository,
        private PositionRepositoryInterface $positionRepository
    ) {}

    public function index(): JsonResponse
    {
        $employees = $this->employeeRepository->findAll();
        
        $data = array_map(function (Employee $employee) {
            return $this->transformEmployee($employee);
        }, $employees);
        
        return JsonResponse::success($data);
    }

    public function show(string $id): JsonResponse
    {
        $employee = $this->employeeRepository->findById(EmployeeId::fromString($id));
        
        if (!$employee) {
            return JsonResponse::notFound('Employee not found');
        }
        
        return JsonResponse::success($this->transformEmployee($employee));
    }

    public function store(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true);
        
        // Validate department exists
        $department = $this->departmentRepository->findById(DepartmentId::fromString($data['departmentId']));
        if (!$department) {
            return JsonResponse::notFound('Department not found');
        }
        
        // Validate position exists
        $position = $this->positionRepository->findById(PositionId::fromString($data['positionId']));
        if (!$position) {
            return JsonResponse::notFound('Position not found');
        }
        
        // Validate manager exists if provided
        $managerId = null;
        if (!empty($data['managerId'])) {
            $manager = $this->employeeRepository->findById(EmployeeId::fromString($data['managerId']));
            if (!$manager) {
                return JsonResponse::notFound('Manager not found');
            }
            $managerId = EmployeeId::fromString($data['managerId']);
        }
        
        // Create employee
        $employee = new Employee(
            EmployeeId::generate(),
            new TabNumber($data['tabNumber']),
            new PersonalInfo($data['fullName'], $data['email'], $data['phone']),
            DepartmentId::fromString($data['departmentId']),
            PositionId::fromString($data['positionId']),
            $managerId,
            new \DateTimeImmutable()
        );
        
        $this->employeeRepository->save($employee);
        
        return JsonResponse::success($this->transformEmployee($employee), Response::HTTP_CREATED);
    }

    public function update(Request $request, string $id): JsonResponse
    {
        $employee = $this->employeeRepository->findById(EmployeeId::fromString($id));
        
        if (!$employee) {
            return JsonResponse::notFound('Employee not found');
        }
        
        $data = json_decode($request->getContent(), true);
        
        // Update personal info if provided
        if (isset($data['email']) || isset($data['phone'])) {
            $personalInfo = $employee->getPersonalInfo();
            $newPersonalInfo = new PersonalInfo(
                $personalInfo->getFullName(),
                $data['email'] ?? $personalInfo->getEmail(),
                $data['phone'] ?? $personalInfo->getPhone()
            );
            $employee->updatePersonalInfo($newPersonalInfo);
        }
        
        // Update department if provided
        if (isset($data['departmentId'])) {
            $department = $this->departmentRepository->findById(DepartmentId::fromString($data['departmentId']));
            if (!$department) {
                return JsonResponse::notFound('Department not found');
            }
            $employee->changeDepartment(DepartmentId::fromString($data['departmentId']));
        }
        
        // Update position if provided
        if (isset($data['positionId'])) {
            $position = $this->positionRepository->findById(PositionId::fromString($data['positionId']));
            if (!$position) {
                return JsonResponse::notFound('Position not found');
            }
            $employee->changePosition(PositionId::fromString($data['positionId']));
        }
        
        // Update manager if provided
        if (isset($data['managerId'])) {
            if ($data['managerId'] === null) {
                $employee->changeManager(null);
            } else {
                $manager = $this->employeeRepository->findById(EmployeeId::fromString($data['managerId']));
                if (!$manager) {
                    return JsonResponse::notFound('Manager not found');
                }
                $employee->changeManager(EmployeeId::fromString($data['managerId']));
            }
        }
        
        $this->employeeRepository->save($employee);
        
        return JsonResponse::success($this->transformEmployee($employee));
    }

    public function destroy(string $id): JsonResponse
    {
        $employee = $this->employeeRepository->findById(EmployeeId::fromString($id));
        
        if (!$employee) {
            return JsonResponse::notFound('Employee not found');
        }
        
        $this->employeeRepository->delete(EmployeeId::fromString($id));
        
        return new JsonResponse(null, Response::HTTP_NO_CONTENT);
    }

    private function transformEmployee(Employee $employee): array
    {
        return [
            'id' => $employee->getId()->toString(),
            'tabNumber' => $employee->getTabNumber()->toString(),
            'fullName' => $employee->getPersonalInfo()->getFullName(),
            'email' => $employee->getPersonalInfo()->getEmail(),
            'phone' => $employee->getPersonalInfo()->getPhone(),
            'departmentId' => $employee->getDepartmentId()->toString(),
            'positionId' => $employee->getPositionId()->toString(),
            'managerId' => $employee->getManagerId()?->toString(),
            'hireDate' => $employee->getHireDate()->format('Y-m-d'),
            'isActive' => $employee->isActive()
        ];
    }
} 