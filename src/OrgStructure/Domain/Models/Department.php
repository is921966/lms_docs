<?php

declare(strict_types=1);

namespace App\OrgStructure\Domain\Models;

use App\OrgStructure\Domain\Exceptions\InvalidDepartmentException;
use App\OrgStructure\Domain\ValueObjects\DepartmentCode;
use App\OrgStructure\Domain\ValueObjects\DepartmentId;

class Department
{
    private ?Department $parent = null;
    private ?DepartmentId $parentId = null;
    /** @var Department[] */
    private array $children = [];
    private int $level = 1;
    private string $path = '';
    private bool $isActive = true;

    public function __construct(
        private readonly DepartmentId $id,
        private readonly DepartmentCode $code,
        private string $name,
        ?Department $parent = null
    ) {
        if (empty($name)) {
            throw new InvalidDepartmentException('Department name cannot be empty');
        }
        
        $this->name = $name;
        
        if ($parent !== null) {
            $this->setParent($parent);
        }
    }

    public static function create(
        DepartmentCode $code,
        string $name,
        ?Department $parent = null
    ): self {
        return new self(
            DepartmentId::generate(),
            $code,
            $name,
            $parent
        );
    }
    
    public static function fromCSVData(array $data): self
    {
        if (!isset($data['code']) || !isset($data['name'])) {
            throw new InvalidDepartmentException('Missing required fields in CSV data');
        }
        
        $code = new DepartmentCode($data['code']);
        
        // Parent will be set later in a second pass
        return self::create($code, $data['name']);
    }

    public function getId(): DepartmentId
    {
        return $this->id;
    }

    public function getCode(): DepartmentCode
    {
        return $this->code;
    }

    public function getName(): string
    {
        return $this->name;
    }

    public function getParent(): ?Department
    {
        return $this->parent;
    }

    /**
     * @return Department[]
     */
    public function getChildren(): array
    {
        return $this->children;
    }

    public function getLevel(): int
    {
        return $this->level;
    }

    public function setParent(Department $parent): void
    {
        // Prevent circular reference
        if ($this->hasDescendant($parent)) {
            throw new InvalidDepartmentException('Cannot set parent: circular reference detected');
        }
        
        // Remove from current parent
        if ($this->parent !== null) {
            $this->parent->removeChild($this);
        }
        
        $this->parent = $parent;
        $this->level = $parent->getLevel() + 1;
        $parent->addChild($this);
        
        // Update levels of all descendants
        $this->updateDescendantLevels();
    }

    private function addChild(Department $child): void
    {
        if (!in_array($child, $this->children, true)) {
            $this->children[] = $child;
        }
    }

    private function removeChild(Department $child): void
    {
        $this->children = array_filter(
            $this->children,
            fn(Department $c) => $c !== $child
        );
        $this->children = array_values($this->children);
    }

    private function hasDescendant(Department $department): bool
    {
        foreach ($this->children as $child) {
            if ($child === $department || $child->hasDescendant($department)) {
                return true;
            }
        }
        
        return false;
    }

    private function updateDescendantLevels(): void
    {
        foreach ($this->children as $child) {
            $child->level = $this->level + 1;
            $child->updateDescendantLevels();
        }
    }

    public function updateName(string $name): void
    {
        if (empty($name)) {
            throw new InvalidDepartmentException('Department name cannot be empty');
        }
        
        $this->name = $name;
    }

    public function isRoot(): bool
    {
        return $this->parent === null;
    }

    public function hasChildren(): bool
    {
        return !empty($this->children);
    }

    public function getPath(): string
    {
        $path = [$this->name];
        $current = $this->parent;
        
        while ($current !== null) {
            array_unshift($path, $current->getName());
            $current = $current->getParent();
        }
        
        return implode(' / ', $path);
    }
    
    public function isActive(): bool
    {
        return $this->isActive;
    }
    
    public function deactivate(): void
    {
        $this->isActive = false;
    }
    
    public function setParentId(?DepartmentId $parentId): void
    {
        $this->parentId = $parentId;
    }
    
    public function getParentId(): ?DepartmentId
    {
        return $this->parentId;
    }
    
    public function rename(string $name): void
    {
        $this->updateName($name);
    }
    
    public function removeFromParent(): void
    {
        $this->setParentId(null);
    }
} 