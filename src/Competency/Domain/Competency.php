<?php

declare(strict_types=1);

namespace App\Competency\Domain;

use App\Common\Traits\HasDomainEvents;
use App\Competency\Domain\Events\CompetencyCreated;
use App\Competency\Domain\Events\CompetencyDeactivated;
use App\Competency\Domain\Events\CompetencyUpdated;
use App\Competency\Domain\ValueObjects\CompetencyCategory;
use App\Competency\Domain\ValueObjects\CompetencyCode;
use App\Competency\Domain\ValueObjects\CompetencyId;
use App\Competency\Domain\ValueObjects\CompetencyLevel;

class Competency
{
    use HasDomainEvents;
    
    private CompetencyId $id;
    private CompetencyCode $code;
    private string $name;
    private string $description;
    private CompetencyCategory $category;
    private ?CompetencyId $parentId;
    private array $levels;
    private bool $isActive;
    private array $metadata;
    
    private function __construct(
        CompetencyId $id,
        CompetencyCode $code,
        string $name,
        string $description,
        CompetencyCategory $category,
        ?CompetencyId $parentId = null,
        array $levels = [],
        bool $isActive = true,
        array $metadata = []
    ) {
        $this->id = $id;
        $this->code = $code;
        $this->name = $name;
        $this->description = $description;
        $this->category = $category;
        $this->parentId = $parentId;
        $this->levels = empty($levels) ? self::getDefaultLevels() : $levels;
        $this->isActive = $isActive;
        $this->metadata = $metadata;
    }
    
    public static function create(
        CompetencyId $id,
        CompetencyCode $code,
        string $name,
        string $description,
        CompetencyCategory $category,
        ?CompetencyId $parentId = null,
        array $levels = []
    ): self {
        $competency = new self(
            $id,
            $code,
            $name,
            $description,
            $category,
            $parentId,
            $levels
        );
        
        $competency->recordDomainEvent(new CompetencyCreated(
            $id,
            $code,
            $name,
            $description,
            $category,
            $parentId
        ));
        
        return $competency;
    }
    
    public function update(string $name, string $description): void
    {
        $changes = [];
        
        if ($this->name !== $name) {
            $changes['name'] = ['old' => $this->name, 'new' => $name];
            $this->name = $name;
        }
        
        if ($this->description !== $description) {
            $changes['description'] = ['old' => $this->description, 'new' => $description];
            $this->description = $description;
        }
        
        if (!empty($changes)) {
            $this->recordDomainEvent(new CompetencyUpdated($this->id, $changes));
        }
    }
    
    public function changeCategory(CompetencyCategory $category): void
    {
        if (!$this->category->equals($category)) {
            $changes = ['category' => ['old' => $this->category->getValue(), 'new' => $category->getValue()]];
            $this->category = $category;
            $this->recordDomainEvent(new CompetencyUpdated($this->id, $changes));
        }
    }
    
    public function deactivate(): void
    {
        if ($this->isActive) {
            $this->isActive = false;
            $this->recordDomainEvent(new CompetencyDeactivated($this->id));
        }
    }
    
    public function activate(): void
    {
        if (!$this->isActive) {
            $this->isActive = true;
            $this->recordDomainEvent(new CompetencyUpdated(
                $this->id,
                ['isActive' => ['old' => false, 'new' => true]]
            ));
        }
    }
    
    public function setParent(CompetencyId $parentId): void
    {
        $this->parentId = $parentId;
        $this->recordDomainEvent(new CompetencyUpdated(
            $this->id,
            ['parentId' => ['old' => null, 'new' => $parentId->toString()]]
        ));
    }
    
    public function removeParent(): void
    {
        if ($this->parentId !== null) {
            $oldParentId = $this->parentId->toString();
            $this->parentId = null;
            $this->recordDomainEvent(new CompetencyUpdated(
                $this->id,
                ['parentId' => ['old' => $oldParentId, 'new' => null]]
            ));
        }
    }
    
    public function updateLevels(array $levels): void
    {
        if (empty($levels)) {
            throw new \InvalidArgumentException('Competency must have at least one level');
        }
        
        $this->levels = $levels;
        $this->recordDomainEvent(new CompetencyUpdated(
            $this->id,
            ['levels' => ['count' => count($levels)]]
        ));
    }
    
    public function addMetadata(string $key, mixed $value): void
    {
        $this->metadata[$key] = $value;
    }
    
    public function removeMetadata(string $key): void
    {
        unset($this->metadata[$key]);
    }
    
    public function isSubcompetencyOf(CompetencyId $parentId): bool
    {
        return $this->parentId !== null && $this->parentId->equals($parentId);
    }
    
    public function getId(): CompetencyId
    {
        return $this->id;
    }
    
    public function getCode(): CompetencyCode
    {
        return $this->code;
    }
    
    public function getName(): string
    {
        return $this->name;
    }
    
    public function getDescription(): string
    {
        return $this->description;
    }
    
    public function getCategory(): CompetencyCategory
    {
        return $this->category;
    }
    
    public function getParentId(): ?CompetencyId
    {
        return $this->parentId;
    }
    
    public function getLevels(): array
    {
        return $this->levels;
    }
    
    public function isActive(): bool
    {
        return $this->isActive;
    }
    
    public function getMetadata(): array
    {
        return $this->metadata;
    }
    
    private static function getDefaultLevels(): array
    {
        return [
            CompetencyLevel::beginner(),
            CompetencyLevel::elementary(),
            CompetencyLevel::intermediate(),
            CompetencyLevel::advanced(),
            CompetencyLevel::expert()
        ];
    }
}
