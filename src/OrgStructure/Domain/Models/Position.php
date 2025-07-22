<?php
declare(strict_types=1);

namespace App\OrgStructure\Domain\Models;

use App\OrgStructure\Domain\Exceptions\InvalidPositionException;
use App\OrgStructure\Domain\ValueObjects\PositionId;
use App\OrgStructure\Domain\ValueObjects\DepartmentId;

class Position
{
    /** @var string[] */
    private array $competencies = [];
    private ?DepartmentId $departmentId = null;
    private bool $isActive = true;
    
    public function __construct(
        private readonly PositionId $id,
        private readonly string $code,
        private string $name,
        private readonly string $category = 'General'
    ) {
        if (empty($name)) {
            throw new InvalidPositionException('Position name cannot be empty');
        }
        
        if (empty($code)) {
            throw new InvalidPositionException('Position code cannot be empty');
        }
    }

    public static function create(
        string $code,
        string $name,
        string $category = 'General'
    ): self {
        return new self(
            PositionId::generate(),
            $code,
            $name,
            $category
        );
    }
    
    public static function fromCSVData(array $data): self
    {
        if (!isset($data['code']) || !isset($data['name'])) {
            throw new InvalidPositionException('Missing required fields in CSV data');
        }
        
        $position = self::create(
            $data['code'],
            $data['name'],
            $data['category'] ?? 'General'
        );
        
        // Parse competencies if provided
        if (isset($data['competencies']) && !empty($data['competencies'])) {
            $competencies = array_map('trim', explode(',', $data['competencies']));
            foreach ($competencies as $competency) {
                $position->addCompetency($competency);
            }
        }
        
        return $position;
    }

    public function getId(): PositionId
    {
        return $this->id;
    }

    public function getCode(): string
    {
        return $this->code;
    }

    public function getName(): string
    {
        return $this->name;
    }

    public function getCategory(): string
    {
        return $this->category;
    }

    public function updateName(string $name): void
    {
        if (empty($name)) {
            throw new InvalidPositionException('Position name cannot be empty');
        }
        
        $this->name = $name;
    }

    public function addCompetency(string $competency): void
    {
        if (!in_array($competency, $this->competencies)) {
            $this->competencies[] = $competency;
        }
    }

    public function removeCompetency(string $competency): void
    {
        $this->competencies = array_filter(
            $this->competencies,
            fn(string $c) => $c !== $competency
        );
        $this->competencies = array_values($this->competencies);
    }

    /**
     * @return string[]
     */
    public function getCompetencies(): array
    {
        return $this->competencies;
    }

    public function hasCompetency(string $competency): bool
    {
        return in_array($competency, $this->competencies);
    }
    
    public function getTitle(): string
    {
        return $this->name;
    }
    
    public function assignToDepartment(DepartmentId $departmentId): void
    {
        $this->departmentId = $departmentId;
    }
    
    public function getDepartmentId(): ?DepartmentId
    {
        return $this->departmentId;
    }
    
    public function isActive(): bool
    {
        return $this->isActive;
    }
    
    public function deactivate(): void
    {
        $this->isActive = false;
    }
} 