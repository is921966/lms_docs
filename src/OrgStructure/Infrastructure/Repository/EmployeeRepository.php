<?php

namespace App\OrgStructure\Infrastructure\Repository;

use App\OrgStructure\Domain\Entity\Employee;
use App\OrgStructure\Domain\Repository\EmployeeRepositoryInterface;
use App\OrgStructure\Domain\ValueObject\TabNumber;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;

class EmployeeRepository implements EmployeeRepositoryInterface
{
    public function save(Employee $employee): void
    {
        $data = [
            'id' => $employee->getId(),
            'tab_number' => $employee->getTabNumber()->getValue(),
            'name' => $employee->getName(),
            'position' => $employee->getPosition(),
            'department_id' => $employee->getDepartmentId(),
            'email' => $employee->getEmail(),
            'phone' => $employee->getPhone(),
            'user_id' => $employee->getUserId(),
            'updated_at' => now(),
        ];
        
        $exists = DB::table('org_employees')->where('id', $employee->getId())->exists();
        
        if ($exists) {
            DB::table('org_employees')
                ->where('id', $employee->getId())
                ->update($data);
        } else {
            $data['created_at'] = now();
            DB::table('org_employees')->insert($data);
        }
    }
    
    public function findById(string $id): ?Employee
    {
        $row = DB::table('org_employees')->where('id', $id)->first();
        
        if (!$row) {
            return null;
        }
        
        return $this->hydrate($row);
    }
    
    public function findByTabNumber(TabNumber $tabNumber): ?Employee
    {
        $row = DB::table('org_employees')
            ->where('tab_number', $tabNumber->getValue())
            ->first();
        
        if (!$row) {
            return null;
        }
        
        return $this->hydrate($row);
    }
    
    /**
     * @return Employee[]
     */
    public function findByDepartment(string $departmentId): array
    {
        $rows = DB::table('org_employees')
            ->where('department_id', $departmentId)
            ->orderBy('name')
            ->get();
        
        return $rows->map(fn($row) => $this->hydrate($row))->toArray();
    }
    
    /**
     * @return Employee[]
     */
    public function findAll(): array
    {
        $rows = DB::table('org_employees')
            ->orderBy('name')
            ->get();
        
        return $rows->map(fn($row) => $this->hydrate($row))->toArray();
    }
    
    /**
     * @return Employee[]
     */
    public function search(string $query): array
    {
        $searchTerm = '%' . strtolower($query) . '%';
        
        $rows = DB::table('org_employees')
            ->where(function ($q) use ($searchTerm) {
                $q->whereRaw('LOWER(name) LIKE ?', [$searchTerm])
                  ->orWhereRaw('LOWER(tab_number) LIKE ?', [$searchTerm])
                  ->orWhereRaw('LOWER(position) LIKE ?', [$searchTerm]);
            })
            ->orderBy('name')
            ->limit(50)
            ->get();
        
        return $rows->map(fn($row) => $this->hydrate($row))->toArray();
    }
    
    public function delete(string $id): void
    {
        DB::table('org_employees')->where('id', $id)->delete();
    }
    
    public function exists(string $id): bool
    {
        return DB::table('org_employees')->where('id', $id)->exists();
    }
    
    public function tabNumberExists(TabNumber $tabNumber): bool
    {
        return DB::table('org_employees')
            ->where('tab_number', $tabNumber->getValue())
            ->exists();
    }
    
    public function countByDepartment(string $departmentId): int
    {
        return DB::table('org_employees')
            ->where('department_id', $departmentId)
            ->count();
    }
    
    private function hydrate($row): Employee
    {
        return new Employee(
            $row->id,
            new TabNumber($row->tab_number),
            $row->name,
            $row->position,
            $row->department_id,
            $row->email,
            $row->phone,
            $row->user_id
        );
    }
} 