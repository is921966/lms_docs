<?php

namespace Tests\Unit\OrgStructure\Http\Controllers;

use PHPUnit\Framework\TestCase;
use App\OrgStructure\Http\Controllers\DepartmentController;
use App\OrgStructure\Domain\Repositories\DepartmentRepositoryInterface;
use App\OrgStructure\Domain\Models\Department;
use App\OrgStructure\Domain\ValueObjects\DepartmentId;
use App\OrgStructure\Domain\ValueObjects\DepartmentCode;
use App\Common\Http\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class DepartmentControllerTest extends TestCase
{
    private DepartmentController $controller;
    private DepartmentRepositoryInterface $departmentRepository;
    
    protected function setUp(): void
    {
        $this->departmentRepository = $this->createMock(DepartmentRepositoryInterface::class);
        $this->controller = new DepartmentController($this->departmentRepository);
    }

    public function testGetAllDepartments(): void
    {
        // Arrange
        $department1 = new Department(
            DepartmentId::fromString('123e4567-e89b-12d3-a456-426614174000'),
            new DepartmentCode('IT'),
            'IT Department',
            null
        );
        
        $department2 = new Department(
            DepartmentId::fromString('223e4567-e89b-12d3-a456-426614174000'),
            new DepartmentCode('HR'),
            'HR Department',
            null  // Parent is set via object, not ID
        );
        $department2->setParentId(DepartmentId::fromString('123e4567-e89b-12d3-a456-426614174000'));
        
        $this->departmentRepository
            ->expects($this->once())
            ->method('findAll')
            ->willReturn([$department1, $department2]);
        
        // Act
        $response = $this->controller->index();
        
        // Assert
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertCount(2, $data['data']);
        $this->assertEquals('IT', $data['data'][0]['code']);
        $this->assertEquals('HR', $data['data'][1]['code']);
    }

    public function testGetDepartmentById(): void
    {
        // Arrange
        $departmentId = DepartmentId::fromString('123e4567-e89b-12d3-a456-426614174000');
        $department = new Department(
            $departmentId,
            new DepartmentCode('IT'),
            'IT Department',
            null
        );
        
        $this->departmentRepository
            ->expects($this->once())
            ->method('findById')
            ->with($departmentId)
            ->willReturn($department);
        
        // Act
        $response = $this->controller->show('123e4567-e89b-12d3-a456-426614174000');
        
        // Assert
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertEquals('IT', $data['data']['code']);
        $this->assertEquals('IT Department', $data['data']['name']);
    }

    public function testCreateDepartment(): void
    {
        // Arrange
        $request = Request::create('/api/departments', 'POST', [], [], [], [], json_encode([
            'code' => 'FIN',
            'name' => 'Finance Department',
            'parentId' => null
        ]));
        
        $this->departmentRepository
            ->expects($this->once())
            ->method('save')
            ->with($this->isInstanceOf(Department::class));
        
        // Act
        $response = $this->controller->store($request);
        
        // Assert
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(Response::HTTP_CREATED, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertEquals('FIN', $data['data']['code']);
        $this->assertEquals('Finance Department', $data['data']['name']);
    }

    public function testUpdateDepartment(): void
    {
        // Arrange
        $departmentId = DepartmentId::fromString('123e4567-e89b-12d3-a456-426614174000');
        $department = new Department(
            $departmentId,
            new DepartmentCode('IT'),
            'IT Department',
            null
        );
        
        $request = Request::create('/api/departments/123', 'PUT', [], [], [], [], json_encode([
            'name' => 'Information Technology'
        ]));
        
        $this->departmentRepository
            ->expects($this->once())
            ->method('findById')
            ->with($departmentId)
            ->willReturn($department);
        
        $this->departmentRepository
            ->expects($this->once())
            ->method('save')
            ->with($this->isInstanceOf(Department::class));
        
        // Act
        $response = $this->controller->update($request, '123e4567-e89b-12d3-a456-426614174000');
        
        // Assert
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertEquals('Information Technology', $data['data']['name']);
    }

    public function testDeleteDepartment(): void
    {
        // Arrange
        $departmentId = DepartmentId::fromString('123e4567-e89b-12d3-a456-426614174000');
        $department = new Department(
            $departmentId,
            new DepartmentCode('IT'),
            'IT Department',
            null
        );
        
        $this->departmentRepository
            ->expects($this->once())
            ->method('findById')
            ->with($departmentId)
            ->willReturn($department);
        
        $this->departmentRepository
            ->expects($this->once())
            ->method('delete')
            ->with($departmentId);
        
        // Act
        $response = $this->controller->destroy('123e4567-e89b-12d3-a456-426614174000');
        
        // Assert
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(Response::HTTP_NO_CONTENT, $response->getStatusCode());
    }
} 