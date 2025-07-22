<?php

declare(strict_types=1);

namespace App\Course\Infrastructure\Cmi5;

class Cmi5CourseStructure
{
    /**
     * @param Cmi5AssignableUnit[] $assignableUnits
     */
    public function __construct(
        private string $courseId,
        private string $title,
        private string $description,
        private array $assignableUnits
    ) {
    }
    
    public function courseId(): string
    {
        return $this->courseId;
    }
    
    public function title(): string
    {
        return $this->title;
    }
    
    public function description(): string
    {
        return $this->description;
    }
    
    /**
     * @return Cmi5AssignableUnit[]
     */
    public function getAssignableUnits(): array
    {
        return $this->assignableUnits;
    }
    
    public function getAssignableUnitById(string $id): ?Cmi5AssignableUnit
    {
        foreach ($this->assignableUnits as $au) {
            if ($au->id() === $id) {
                return $au;
            }
        }
        
        return null;
    }
    
    public function toArray(): array
    {
        return [
            'courseId' => $this->courseId,
            'title' => $this->title,
            'description' => $this->description,
            'assignableUnits' => array_map(
                fn(Cmi5AssignableUnit $au) => $au->toArray(),
                $this->assignableUnits
            )
        ];
    }
} 