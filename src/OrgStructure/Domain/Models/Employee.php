<?php

declare(strict_types=1);

namespace App\OrgStructure\Domain\Models;

use App\OrgStructure\Domain\Exceptions\InvalidEmployeeDataException;
use App\OrgStructure\Domain\ValueObjects\DepartmentId;
use App\OrgStructure\Domain\ValueObjects\EmployeeId;
use App\OrgStructure\Domain\ValueObjects\PersonalInfo;
use App\OrgStructure\Domain\ValueObjects\PositionId;
use App\OrgStructure\Domain\ValueObjects\TabNumber;

class Employee
{
    private DepartmentId $departmentId;
    private PositionId $positionId;
    private ?EmployeeId $managerId = null;
    private bool $isActive = true;
    private \DateTimeImmutable $hireDate;

    public function __construct(
        private readonly EmployeeId $id,
        private readonly TabNumber $tabNumber,
        private PersonalInfo $personalInfo,
        DepartmentId $departmentId,
        PositionId $positionId,
        ?EmployeeId $managerId = null
    ) {
        $this->departmentId = $departmentId;
        $this->positionId = $positionId;
        $this->managerId = $managerId;
        $this->hireDate = new \DateTimeImmutable();
    }

    public static function create(
        TabNumber $tabNumber,
        PersonalInfo $personalInfo,
        DepartmentId $departmentId,
        PositionId $positionId,
        ?EmployeeId $managerId = null
    ): self {
        return new self(
            EmployeeId::generate(),
            $tabNumber,
            $personalInfo,
            $departmentId,
            $positionId,
            $managerId
        );
    }
    
    public static function fromCSVData(array $data): self
    {
        if (!isset($data['tab_number'], $data['full_name'], $data['department_id'], $data['position_id'])) {
            throw new InvalidEmployeeDataException('Missing required fields in CSV data');
        }
        
        // Create PersonalInfo from name or full data
        if (isset($data['email']) && isset($data['phone'])) {
            $personalInfo = PersonalInfo::create(
                $data['full_name'],
                $data['email'],
                $data['phone']
            );
        } else {
            $personalInfo = PersonalInfo::fromName($data['full_name']);
        }
        
        // Create value objects
        $tabNumber = new TabNumber($data['tab_number']);
        $departmentId = DepartmentId::generate(); // Will be resolved later
        $positionId = PositionId::generate(); // Will be resolved later
        $managerId = !empty($data['manager_id']) ? EmployeeId::generate() : null;
        
        return self::create(
            $tabNumber,
            $personalInfo,
            $departmentId,
            $positionId,
            $managerId
        );
    }

    public function getId(): EmployeeId
    {
        return $this->id;
    }

    public function getTabNumber(): TabNumber
    {
        return $this->tabNumber;
    }

    public function getPersonalInfo(): PersonalInfo
    {
        return $this->personalInfo;
    }

    public function getDepartmentId(): DepartmentId
    {
        return $this->departmentId;
    }

    public function getPositionId(): PositionId
    {
        return $this->positionId;
    }

    public function getManagerId(): ?EmployeeId
    {
        return $this->managerId;
    }

    public function isActive(): bool
    {
        return $this->isActive;
    }

    public function changeDepartment(DepartmentId $newDepartmentId): void
    {
        $this->departmentId = $newDepartmentId;
    }

    public function changePosition(PositionId $newPositionId): void
    {
        $this->positionId = $newPositionId;
    }

    public function changeManager(?EmployeeId $newManagerId): void
    {
        if ($newManagerId !== null && $newManagerId->equals($this->id)) {
            throw new InvalidEmployeeDataException('Employee cannot be their own manager');
        }
        
        $this->managerId = $newManagerId;
    }

    public function updatePersonalInfo(PersonalInfo $personalInfo): void
    {
        $this->personalInfo = $personalInfo;
    }

    public function activate(): void
    {
        $this->isActive = true;
    }

    public function deactivate(): void
    {
        $this->isActive = false;
    }
    
    public function assignToDepartment(DepartmentId $departmentId): void
    {
        $this->departmentId = $departmentId;
    }
    
    public function assignToPosition(PositionId $positionId): void
    {
        $this->positionId = $positionId;
    }
    
    public function setManager(EmployeeId $managerId): void
    {
        if ($managerId->equals($this->id)) {
            throw new InvalidEmployeeDataException('Employee cannot be their own manager');
        }
        
        $this->managerId = $managerId;
    }
    
    public function getHireDate(): \DateTimeImmutable
    {
        return $this->hireDate;
    }

    public function hasManager(): bool
    {
        return $this->managerId !== null;
    }
} 