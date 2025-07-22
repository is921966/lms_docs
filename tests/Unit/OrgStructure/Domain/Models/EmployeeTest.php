<?php
declare(strict_types=1);

namespace Tests\Unit\OrgStructure\Domain\Models;

use PHPUnit\Framework\TestCase;
use App\OrgStructure\Domain\Models\Employee;
use App\OrgStructure\Domain\ValueObjects\EmployeeId;
use App\OrgStructure\Domain\ValueObjects\TabNumber;
use App\OrgStructure\Domain\ValueObjects\PersonalInfo;
use App\OrgStructure\Domain\Exceptions\InvalidEmployeeDataException;

class EmployeeTest extends TestCase
{
    public function test_create_employee_with_required_data(): void
    {
        // Arrange
        $employeeId = EmployeeId::generate();
        $tabNumber = new TabNumber('12345');
        $personalInfo = PersonalInfo::create(
            'Иванов Иван Иванович',
            'ivanov@company.ru',
            '+7 (999) 123-45-67'
        );

        // Act
        $employee = new Employee(
            $employeeId,
            $tabNumber,
            $personalInfo
        );

        // Assert
        $this->assertInstanceOf(Employee::class, $employee);
        $this->assertEquals($employeeId, $employee->getId());
        $this->assertEquals($tabNumber, $employee->getTabNumber());
        $this->assertEquals($personalInfo, $employee->getPersonalInfo());
        $this->assertNull($employee->getDepartment());
        $this->assertNull($employee->getPosition());
        $this->assertNull($employee->getManager());
        $this->assertInstanceOf(\DateTimeImmutable::class, $employee->getCreatedAt());
        $this->assertNull($employee->getUpdatedAt());
    }

    public function test_create_employee_from_csv_data(): void
    {
        // Arrange
        $csvData = [
            'tab_number' => '12345',
            'full_name' => 'Петров Петр Петрович',
            'email' => 'petrov@company.ru',
            'phone' => '+7 (999) 987-65-43',
            'department' => 'IT Department',
            'position' => 'Senior Developer'
        ];

        // Act
        $employee = Employee::createFromCsvData($csvData);

        // Assert
        $this->assertInstanceOf(Employee::class, $employee);
        $this->assertEquals('12345', $employee->getTabNumber()->getValue());
        $this->assertEquals('Петров Петр Петрович', $employee->getPersonalInfo()->getFullName());
        $this->assertEquals('petrov@company.ru', $employee->getPersonalInfo()->getEmail());
        $this->assertEquals('+7 (999) 987-65-43', $employee->getPersonalInfo()->getPhone());
        $this->assertArrayHasKey('department', $employee->getMetadata());
        $this->assertArrayHasKey('position', $employee->getMetadata());
    }

    public function test_create_employee_from_csv_throws_exception_without_tab_number(): void
    {
        // Arrange
        $csvData = [
            'full_name' => 'Сидоров Сидор Сидорович',
            'email' => 'sidorov@company.ru'
        ];

        // Assert
        $this->expectException(InvalidEmployeeDataException::class);
        $this->expectExceptionMessage('Tab number is required');

        // Act
        Employee::createFromCsvData($csvData);
    }

    public function test_employee_cannot_be_own_manager(): void
    {
        // Arrange
        $employee = new Employee(
            EmployeeId::generate(),
            new TabNumber('12345'),
            PersonalInfo::create('Test Employee', null, null)
        );

        // Assert
        $this->expectException(InvalidEmployeeDataException::class);
        $this->expectExceptionMessage('Employee cannot be their own manager');

        // Act
        $employee->assignManager($employee);
    }
} 