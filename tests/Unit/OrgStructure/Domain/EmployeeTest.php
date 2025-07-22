<?php

namespace Tests\Unit\OrgStructure\Domain;

use PHPUnit\Framework\TestCase;
use App\OrgStructure\Domain\Entity\Employee;
use App\OrgStructure\Domain\ValueObject\TabNumber;
use App\OrgStructure\Domain\Exception\InvalidEmployeeDataException;

class EmployeeTest extends TestCase
{
    /** @test */
    public function it_creates_employee_with_valid_data(): void
    {
        // Arrange
        $id = 'emp-123';
        $tabNumber = new TabNumber('АР21000612');
        $name = 'Клейменов Евгений Борисович';
        $position = 'Генеральный директор';
        $departmentId = 'dept-123';
        $email = 'kleimenov@company.ru';
        $phone = '+7 (495) 123-45-67';
        
        // Act
        $employee = new Employee(
            $id,
            $tabNumber,
            $name,
            $position,
            $departmentId,
            $email,
            $phone
        );
        
        // Assert
        $this->assertEquals($id, $employee->getId());
        $this->assertEquals($tabNumber, $employee->getTabNumber());
        $this->assertEquals($name, $employee->getName());
        $this->assertEquals($position, $employee->getPosition());
        $this->assertEquals($departmentId, $employee->getDepartmentId());
        $this->assertEquals($email, $employee->getEmail());
        $this->assertEquals($phone, $employee->getPhone());
    }
    
    /** @test */
    public function it_creates_employee_with_minimal_data(): void
    {
        // Arrange & Act
        $employee = new Employee(
            'emp-123',
            new TabNumber('АР21000612'),
            'Иванов Иван Иванович',
            'Программист',
            'dept-123'
        );
        
        // Assert
        $this->assertNull($employee->getEmail());
        $this->assertNull($employee->getPhone());
    }
    
    /** @test */
    public function it_throws_exception_for_empty_name(): void
    {
        // Arrange & Act & Assert
        $this->expectException(InvalidEmployeeDataException::class);
        $this->expectExceptionMessage('Employee name cannot be empty');
        
        new Employee(
            'emp-123',
            new TabNumber('АР21000612'),
            '',
            'Программист',
            'dept-123'
        );
    }
    
    /** @test */
    public function it_throws_exception_for_empty_position(): void
    {
        // Arrange & Act & Assert
        $this->expectException(InvalidEmployeeDataException::class);
        $this->expectExceptionMessage('Employee position cannot be empty');
        
        new Employee(
            'emp-123',
            new TabNumber('АР21000612'),
            'Иванов Иван',
            '',
            'dept-123'
        );
    }
    
    /** @test */
    public function it_validates_email_format(): void
    {
        // Arrange & Act & Assert
        $this->expectException(InvalidEmployeeDataException::class);
        $this->expectExceptionMessage('Invalid email format');
        
        new Employee(
            'emp-123',
            new TabNumber('АР21000612'),
            'Иванов Иван',
            'Программист',
            'dept-123',
            'invalid-email'
        );
    }
    
    /** @test */
    public function it_can_update_employee_data(): void
    {
        // Arrange
        $employee = new Employee(
            'emp-123',
            new TabNumber('АР21000612'),
            'Иванов Иван',
            'Программист',
            'dept-123'
        );
        
        // Act
        $employee->updatePosition('Старший программист');
        $employee->updateEmail('ivanov@company.ru');
        $employee->updatePhone('+7 (495) 999-88-77');
        
        // Assert
        $this->assertEquals('Старший программист', $employee->getPosition());
        $this->assertEquals('ivanov@company.ru', $employee->getEmail());
        $this->assertEquals('+7 (495) 999-88-77', $employee->getPhone());
    }
    
    /** @test */
    public function it_can_change_department(): void
    {
        // Arrange
        $employee = new Employee(
            'emp-123',
            new TabNumber('АР21000612'),
            'Иванов Иван',
            'Программист',
            'dept-123'
        );
        
        // Act
        $employee->changeDepartment('dept-456');
        
        // Assert
        $this->assertEquals('dept-456', $employee->getDepartmentId());
    }
    
    /** @test */
    public function it_can_get_full_name_parts(): void
    {
        // Arrange
        $employee = new Employee(
            'emp-123',
            new TabNumber('АР21000612'),
            'Клейменов Евгений Борисович',
            'Генеральный директор',
            'dept-123'
        );
        
        // Act
        $parts = $employee->getNameParts();
        
        // Assert
        $this->assertEquals('Клейменов', $parts['lastName']);
        $this->assertEquals('Евгений', $parts['firstName']);
        $this->assertEquals('Борисович', $parts['middleName']);
    }
    
    /** @test */
    public function it_can_get_initials(): void
    {
        // Arrange
        $employee = new Employee(
            'emp-123',
            new TabNumber('АР21000612'),
            'Клейменов Евгений Борисович',
            'Генеральный директор',
            'dept-123'
        );
        
        // Act
        $initials = $employee->getInitials();
        
        // Assert
        $this->assertEquals('Клейменов Е.Б.', $initials);
    }
    
    /** @test */
    public function it_normalizes_phone_number(): void
    {
        // Arrange
        $testCases = [
            ['+7 (495) 123-45-67', '+7 (495) 123-45-67'],
            ['84951234567', '+7 (495) 123-45-67'],
            ['74951234567', '+7 (495) 123-45-67'],
            ['+74951234567', '+7 (495) 123-45-67'],
        ];
        
        // Act & Assert
        foreach ($testCases as [$input, $expected]) {
            $employee = new Employee(
                'emp-test',
                new TabNumber('АР21000612'),
                'Test User',
                'Test Position',
                'dept-123',
                null,
                $input
            );
            
            $this->assertEquals($expected, $employee->getPhone());
        }
    }
} 