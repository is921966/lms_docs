<?php

declare(strict_types=1);

namespace App\Competency\Infrastructure\Repository;

use App\Competency\Domain\Competency;
use App\Competency\Domain\Repository\CompetencyRepositoryInterface;
use App\Competency\Domain\ValueObjects\CompetencyCategory;
use App\Competency\Domain\ValueObjects\CompetencyCode;
use App\Competency\Domain\ValueObjects\CompetencyId;

class InMemoryCompetencyRepository implements CompetencyRepositoryInterface
{
    /**
     * @var array<string, Competency>
     */
    private array $competencies = [];
    
    public function save(Competency $competency): void
    {
        $this->competencies[$competency->getId()->getValue()] = $competency;
    }
    
    public function findById(CompetencyId $id): ?Competency
    {
        return $this->competencies[$id->getValue()] ?? null;
    }
    
    public function findByCode(CompetencyCode $code): ?Competency
    {
        foreach ($this->competencies as $competency) {
            if ($competency->getCode()->equals($code)) {
                return $competency;
            }
        }
        
        return null;
    }
    
    public function findByCategory(CompetencyCategory $category): array
    {
        return array_values(
            array_filter(
                $this->competencies,
                fn(Competency $c) => $c->getCategory()->equals($category)
            )
        );
    }
    
    public function findActive(): array
    {
        return array_values(
            array_filter(
                $this->competencies,
                fn(Competency $c) => $c->isActive()
            )
        );
    }
    
    public function findChildren(CompetencyId $parentId): array
    {
        return array_values(
            array_filter(
                $this->competencies,
                fn(Competency $c) => $c->getParentId()?->equals($parentId) ?? false
            )
        );
    }
    
    public function search(string $query): array
    {
        $lowerQuery = strtolower($query);
        
        return array_values(
            array_filter(
                $this->competencies,
                function (Competency $c) use ($lowerQuery) {
                    return str_contains(strtolower($c->getName()), $lowerQuery) ||
                           str_contains(strtolower($c->getDescription()), $lowerQuery);
                }
            )
        );
    }
    
    public function existsByCode(CompetencyCode $code): bool
    {
        return $this->findByCode($code) !== null;
    }
    
    public function getNextCode(string $prefix): CompetencyCode
    {
        $maxNumber = 0;
        $pattern = '/^' . preg_quote($prefix, '/') . '-(\d+)$/';
        
        foreach ($this->competencies as $competency) {
            $codeValue = $competency->getCode()->getValue();
            
            if (preg_match($pattern, $codeValue, $matches)) {
                $number = (int) $matches[1];
                if ($number > $maxNumber) {
                    $maxNumber = $number;
                }
            }
        }
        
        $nextNumber = str_pad((string) ($maxNumber + 1), 3, '0', STR_PAD_LEFT);
        
        return CompetencyCode::fromString($prefix . '-' . $nextNumber);
    }
    
    public function delete(CompetencyId $id): void
    {
        if (isset($this->competencies[$id->getValue()])) {
            $this->competencies[$id->getValue()]->deactivate();
        }
    }
} 