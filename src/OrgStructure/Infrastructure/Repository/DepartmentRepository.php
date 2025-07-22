<?php

namespace App\OrgStructure\Infrastructure\Repository;

use App\OrgStructure\Domain\Entity\Department;
use App\OrgStructure\Domain\ValueObject\DepartmentCode;
use App\OrgStructure\Domain\Repository\DepartmentRepositoryInterface;
use Illuminate\Support\Facades\DB;

class DepartmentRepository implements DepartmentRepositoryInterface
{
    public function save(Department $department): void
    {
        $exists = DB::table('departments')
            ->where('id', $department->getId())
            ->exists();
            
        $data = [
            'id' => $department->getId(),
            'name' => $department->getName(),
            'code' => $department->getCode()->getValue(),
            'parent_id' => $department->getParentId(),
            'level' => $department->getLevel(),
            'employee_count' => $department->getEmployeeCount(),
            'updated_at' => now(),
        ];
        
        if (!$exists) {
            $data['created_at'] = now();
            DB::table('departments')->insert($data);
        } else {
            DB::table('departments')
                ->where('id', $department->getId())
                ->update($data);
        }
    }
    
    public function findById(string $id): ?Department
    {
        $row = DB::table('departments')
            ->where('id', $id)
            ->first();
            
        return $row ? $this->mapToDomain($row) : null;
    }
    
    public function findByCode(DepartmentCode $code): ?Department
    {
        $row = DB::table('departments')
            ->where('code', $code->getValue())
            ->first();
            
        return $row ? $this->mapToDomain($row) : null;
    }
    
    public function findChildren(string $parentId): array
    {
        $rows = DB::table('departments')
            ->where('parent_id', $parentId)
            ->orderBy('code')
            ->get();
            
        return $rows->map(fn($row) => $this->mapToDomain($row))->toArray();
    }
    
    public function findRoots(): array
    {
        $rows = DB::table('departments')
            ->whereNull('parent_id')
            ->orderBy('code')
            ->get();
            
        return $rows->map(fn($row) => $this->mapToDomain($row))->toArray();
    }
    
    public function findAll(): array
    {
        $rows = DB::table('departments')
            ->orderBy('code')
            ->get();
            
        return $rows->map(fn($row) => $this->mapToDomain($row))->toArray();
    }
    
    public function delete(string $id): void
    {
        DB::table('departments')->where('id', $id)->delete();
    }
    
    public function getStatsByLevel(): array
    {
        $stats = DB::table('departments')
            ->select('level', DB::raw('COUNT(*) as count'))
            ->groupBy('level')
            ->orderBy('level')
            ->get();
            
        $result = [];
        foreach ($stats as $stat) {
            $result[$stat->level] = $stat->count;
        }
        
        return $result;
    }
    
    public function exists(string $id): bool
    {
        return DB::table('departments')
            ->where('id', $id)
            ->exists();
    }
    
    public function codeExists(DepartmentCode $code): bool
    {
        return DB::table('departments')
            ->where('code', $code->getValue())
            ->exists();
    }
    
    private function mapToDomain($row): Department
    {
        $department = new Department(
            $row->id,
            $row->name,
            new DepartmentCode($row->code),
            $row->parent_id
        );
        
        $department->setEmployeeCount($row->employee_count);
        
        return $department;
    }
} 