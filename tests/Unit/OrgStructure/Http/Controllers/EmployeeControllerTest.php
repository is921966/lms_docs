<?php

namespace Tests\Unit\OrgStructure\Http\Controllers;

use PHPUnit\Framework\TestCase;
use App\OrgStructure\Http\Controllers\EmployeeController;
use App\OrgStructure\Application\Services\ImportOrchestrator;
use App\OrgStructure\Domain\Repositories\EmployeeRepositoryInterface;
use App\OrgStructure\Domain\Repositories\DepartmentRepositoryInterface;
use App\OrgStructure\Domain\Repositories\PositionRepositoryInterface;
use App\OrgStructure\Domain\Models\Employee;
use App\OrgStructure\Domain\Models\Department;
use App\OrgStructure\Domain\Models\Position;
use App\OrgStructure\Domain\ValueObjects\EmployeeId;
use App\OrgStructure\Domain\ValueObjects\DepartmentId;
use App\OrgStructure\Domain\ValueObjects\PositionId;
use App\OrgStructure\Domain\ValueObjects\TabNumber;
use App\OrgStructure\Domain\ValueObjects\PersonalInfo;
use App\Common\Http\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class EmployeeControllerTest extends TestCase
{
    private EmployeeController $controller;
    private EmployeeRepositoryInterface $employeeRepository;
    private DepartmentRepositoryInterface $departmentRepository;
    private PositionRepositoryInterface $positionRepository;
    
    protected function setUp(): void
    {
        $this->employeeRepository = $this->createMock(EmployeeRepositoryInterface::class);
        $this->departmentRepository = $this->createMock(DepartmentRepositoryInterface::class);
        $this->positionRepository = $this->createMock(PositionRepositoryInterface::class);
        
        $this->controller = new EmployeeController(
            $this->employeeRepository,
            $this->departmentRepository,
            $this->positionRepository
        );
    }

    public function testGetAllEmployees(): void
    {
        // Arrange
        $employee1 = new Employee(
            EmployeeId::fromString('123e4567-e89b-12d3-a456-426614174000'),
            new TabNumber('EMP001'),
            new PersonalInfo('Иван Иванов', 'ivan@company.ru', '+7-123-456-7890'),
            DepartmentId::fromString('223e4567-e89b-12d3-a456-426614174001'),
            PositionId::fromString('323e4567-e89b-12d3-a456-426614174002'),
            null,
            new \DateTimeImmutable('2020-01-01')
        );
        
        $employee2 = new Employee(
            EmployeeId::fromString('223e4567-e89b-12d3-a456-426614174000'),
            new TabNumber('EMP002'),
            new PersonalInfo('Петр Петров', 'petr@company.ru', '+7-123-456-7891'),
            DepartmentId::fromString('223e4567-e89b-12d3-a456-426614174001'),
            PositionId::fromString('323e4567-e89b-12d3-a456-426614174003'),
            EmployeeId::fromString('123e4567-e89b-12d3-a456-426614174000'),
            new \DateTimeImmutable('2021-01-01')
        );
        
        $this->employeeRepository
            ->expects($this->once())
            ->method('findAll')
            ->willReturn([$employee1, $employee2]);
        
        // Act
        $response = $this->controller->index();
        
        // Assert
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertCount(2, $data['data']);
        $this->assertEquals('EMP001', $data['data'][0]['tabNumber']);
        $this->assertEquals('EMP002', $data['data'][1]['tabNumber']);
    }

    public function testGetEmployeeById(): void
    {
        // Arrange
        $employeeId = EmployeeId::fromString('123e4567-e89b-12d3-a456-426614174000');
        $employee = new Employee(
            $employeeId,
            new TabNumber('EMP001'),
            new PersonalInfo('Иван Иванов', 'ivan@company.ru', '+7-123-456-7890'),
            DepartmentId::fromString('223e4567-e89b-12d3-a456-426614174001'),
            PositionId::fromString('323e4567-e89b-12d3-a456-426614174002'),
            null,
            new \DateTimeImmutable('2020-01-01')
        );
        
        $this->employeeRepository
            ->expects($this->once())
            ->method('findById')
            ->with($employeeId)
            ->willReturn($employee);
        
        // Act
        $response = $this->controller->show('123e4567-e89b-12d3-a456-426614174000');
        
        // Assert
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertEquals('EMP001', $data['data']['tabNumber']);
        $this->assertEquals('Иван Иванов', $data['data']['fullName']);
    }

    public function testGetEmployeeByIdNotFound(): void
    {
        // Arrange
        $employeeId = EmployeeId::fromString('123e4567-e89b-12d3-a456-426614174000');
        
        $this->employeeRepository
            ->expects($this->once())
            ->method('findById')
            ->with($employeeId)
            ->willReturn(null);
        
        // Act
        $response = $this->controller->show('123e4567-e89b-12d3-a456-426614174000');
        
        // Assert
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(Response::HTTP_NOT_FOUND, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertEquals('Employee not found', $data['error']);
    }

    public function testCreateEmployee(): void
    {
        // Arrange
        $request = Request::create('/api/employees', 'POST', [], [], [], [], json_encode([
            'tabNumber' => 'EMP003',
            'fullName' => 'Сергей Сергеев',
            'email' => 'sergey@company.ru',
            'phone' => '+7-123-456-7892',
            'departmentId' => '223e4567-e89b-12d3-a456-426614174001',
            'positionId' => '323e4567-e89b-12d3-a456-426614174002',
            'managerId' => null
        ]));
        
        $department = new Department(
            DepartmentId::fromString('223e4567-e89b-12d3-a456-426614174001'),
            new \App\OrgStructure\Domain\ValueObjects\DepartmentCode('IT'),
            'IT Department',
            null
        );
        
        $position = new Position(
            PositionId::fromString('323e4567-e89b-12d3-a456-426614174002'),
            'DEV001',
            'Developer',
            'IT'
        );
        $position->assignToDepartment(DepartmentId::fromString('223e4567-e89b-12d3-a456-426614174001'));
        
        $this->departmentRepository
            ->expects($this->once())
            ->method('findById')
            ->willReturn($department);
        
        $this->positionRepository
            ->expects($this->once())
            ->method('findById')
            ->willReturn($position);
        
        $this->employeeRepository
            ->expects($this->once())
            ->method('save')
            ->with($this->isInstanceOf(Employee::class));
        
        // Act
        $response = $this->controller->store($request);
        
        // Assert
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(Response::HTTP_CREATED, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertEquals('EMP003', $data['data']['tabNumber']);
        $this->assertEquals('Сергей Сергеев', $data['data']['fullName']);
    }

    public function testUpdateEmployee(): void
    {
        // Arrange
        $employeeId = EmployeeId::fromString('123e4567-e89b-12d3-a456-426614174000');
        $employee = new Employee(
            $employeeId,
            new TabNumber('EMP001'),
            new PersonalInfo('Иван Иванов', 'ivan@company.ru', '+7-123-456-7890'),
            DepartmentId::fromString('223e4567-e89b-12d3-a456-426614174001'),
            PositionId::fromString('323e4567-e89b-12d3-a456-426614174002'),
            null,
            new \DateTimeImmutable('2020-01-01')
        );
        
        $request = Request::create('/api/employees/123', 'PUT', [], [], [], [], json_encode([
            'email' => 'ivan.ivanov@company.ru',
            'phone' => '+7-999-888-7777'
        ]));
        
        $this->employeeRepository
            ->expects($this->once())
            ->method('findById')
            ->with($employeeId)
            ->willReturn($employee);
        
        $this->employeeRepository
            ->expects($this->once())
            ->method('save')
            ->with($this->isInstanceOf(Employee::class));
        
        // Act
        $response = $this->controller->update($request, '123e4567-e89b-12d3-a456-426614174000');
        
        // Assert
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertEquals('ivan.ivanov@company.ru', $data['data']['email']);
        $this->assertEquals('+7-999-888-7777', $data['data']['phone']);
    }

    public function testDeleteEmployee(): void
    {
        // Arrange
        $employeeId = EmployeeId::fromString('123e4567-e89b-12d3-a456-426614174000');
        $employee = new Employee(
            $employeeId,
            new TabNumber('EMP001'),
            new PersonalInfo('Иван Иванов', 'ivan@company.ru', '+7-123-456-7890'),
            DepartmentId::fromString('223e4567-e89b-12d3-a456-426614174001'),
            PositionId::fromString('323e4567-e89b-12d3-a456-426614174002'),
            null,
            new \DateTimeImmutable('2020-01-01')
        );
        
        $this->employeeRepository
            ->expects($this->once())
            ->method('findById')
            ->with($employeeId)
            ->willReturn($employee);
        
        $this->employeeRepository
            ->expects($this->once())
            ->method('delete')
            ->with($employeeId);
        
        // Act
        $response = $this->controller->destroy('123e4567-e89b-12d3-a456-426614174000');
        
        // Assert
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(Response::HTTP_NO_CONTENT, $response->getStatusCode());
    }
} 