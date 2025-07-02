<?php

declare(strict_types=1);

namespace Competency\Application\Service;

use Competency\Domain\Competency;
use Competency\Domain\Repository\CompetencyRepositoryInterface;
use Competency\Domain\ValueObjects\CompetencyCategory;
use Competency\Domain\ValueObjects\CompetencyCode;
use Competency\Domain\ValueObjects\CompetencyId;

class CompetencyService
{
    public function __construct(
        private readonly CompetencyRepositoryInterface $competencyRepository
    ) {
    }
    
    private function success(array $data = []): array
    {
        return array_merge(['success' => true], $data);
    }
    
    private function error(string $message): array
    {
        return ['success' => false, 'error' => $message];
    }
    
    public function createCompetency(
        string $code,
        string $name,
        string $description,
        string $category,
        ?string $parentId = null
    ): array {
        try {
            // Validate category
            try {
                $categoryObj = match ($category) {
                    'technical' => CompetencyCategory::technical(),
                    'soft' => CompetencyCategory::soft(),
                    'leadership' => CompetencyCategory::leadership(),
                    'business' => CompetencyCategory::business(),
                    'other' => CompetencyCategory::other(),
                    default => throw new \InvalidArgumentException("Invalid category: $category")
                };
            } catch (\InvalidArgumentException $e) {
                return $this->error($e->getMessage());
            }
            
            // Check if code already exists
            $codeObj = CompetencyCode::fromString($code);
            if ($this->competencyRepository->existsByCode($codeObj)) {
                return $this->error("Competency with code $code already exists");
            }
            
            // Create competency
            $competency = Competency::create(
                id: CompetencyId::generate(),
                code: $codeObj,
                name: $name,
                description: $description,
                category: $categoryObj,
                parentId: $parentId ? CompetencyId::fromString($parentId) : null
            );
            
            // Save to repository
            $this->competencyRepository->save($competency);
            
            return $this->success([
                'competency_id' => $competency->getId()->getValue(),
                'code' => $competency->getCode()->getValue(),
                'name' => $competency->getName(),
                'description' => $competency->getDescription(),
                'category' => $competency->getCategory()->getValue(),
                'parent_id' => $competency->getParentId()?->getValue(),
                'is_active' => $competency->isActive()
            ]);
            
        } catch (\Exception $e) {
            return $this->error($e->getMessage());
        }
    }
    
    public function updateCompetency(
        string $id,
        string $name,
        string $description
    ): array {
        try {
            $competency = $this->competencyRepository->findById(CompetencyId::fromString($id));
            
            if (!$competency) {
                return $this->error("Competency not found");
            }
            
            $competency->update($name, $description);
            $this->competencyRepository->save($competency);
            
            return $this->success([
                'competency_id' => $competency->getId()->getValue(),
                'code' => $competency->getCode()->getValue(),
                'name' => $competency->getName(),
                'description' => $competency->getDescription(),
                'category' => $competency->getCategory()->getValue(),
                'is_active' => $competency->isActive()
            ]);
            
        } catch (\Exception $e) {
            return $this->error($e->getMessage());
        }
    }
    
    public function deactivateCompetency(string $id): array
    {
        try {
            $competency = $this->competencyRepository->findById(CompetencyId::fromString($id));
            
            if (!$competency) {
                return $this->error("Competency not found");
            }
            
            $competency->deactivate();
            $this->competencyRepository->save($competency);
            
            return $this->success([
                'competency_id' => $competency->getId()->getValue(),
                'code' => $competency->getCode()->getValue(),
                'is_active' => $competency->isActive()
            ]);
            
        } catch (\Exception $e) {
            return $this->error($e->getMessage());
        }
    }
    
    public function getCompetencyById(string $id): array
    {
        try {
            $competency = $this->competencyRepository->findById(CompetencyId::fromString($id));
            
            if (!$competency) {
                return $this->error("Competency not found");
            }
            
            return $this->success([
                'data' => $this->mapCompetencyToArray($competency)
            ]);
            
        } catch (\Exception $e) {
            return $this->error($e->getMessage());
        }
    }
    
    public function getCompetenciesByCategory(string $category): array
    {
        try {
            $categoryObj = match ($category) {
                'technical' => CompetencyCategory::technical(),
                'soft' => CompetencyCategory::soft(),
                'leadership' => CompetencyCategory::leadership(),
                'business' => CompetencyCategory::business(),
                'other' => CompetencyCategory::other(),
                default => throw new \InvalidArgumentException("Invalid category: $category")
            };
            
            $competencies = $this->competencyRepository->findByCategory($categoryObj);
            
            return $this->success([
                'data' => array_map(
                    fn(Competency $c) => $this->mapCompetencyToArray($c),
                    $competencies
                )
            ]);
            
        } catch (\Exception $e) {
            return $this->error($e->getMessage());
        }
    }
    
    public function getActiveCompetencies(): array
    {
        try {
            $competencies = $this->competencyRepository->findActive();
            
            return $this->success([
                'data' => array_map(
                    fn(Competency $c) => $this->mapCompetencyToArray($c),
                    $competencies
                )
            ]);
            
        } catch (\Exception $e) {
            return $this->error($e->getMessage());
        }
    }
    
    public function searchCompetencies(string $query): array
    {
        try {
            $competencies = $this->competencyRepository->search($query);
            
            return $this->success([
                'data' => array_map(
                    fn(Competency $c) => $this->mapCompetencyToArray($c),
                    $competencies
                )
            ]);
            
        } catch (\Exception $e) {
            return $this->error($e->getMessage());
        }
    }
    
    public function getCompetencyTree(string $parentId): array
    {
        try {
            $parent = $this->competencyRepository->findById(CompetencyId::fromString($parentId));
            
            if (!$parent) {
                return $this->error("Parent competency not found");
            }
            
            $children = $this->competencyRepository->findChildren($parent->getId());
            
            $data = $this->mapCompetencyToArray($parent);
            $data['children'] = array_map(
                fn(Competency $c) => $this->mapCompetencyToArray($c),
                $children
            );
            
            return $this->success(['data' => $data]);
            
        } catch (\Exception $e) {
            return $this->error($e->getMessage());
        }
    }
    
    public function generateNextCode(string $prefix): array
    {
        try {
            $nextCode = $this->competencyRepository->getNextCode($prefix);
            
            return $this->success([
                'code' => $nextCode->getValue()
            ]);
            
        } catch (\Exception $e) {
            return $this->error($e->getMessage());
        }
    }
    
    public function bulkCreateCompetencies(array $competencies): array
    {
        $created = 0;
        $failed = 0;
        $errors = [];
        
        foreach ($competencies as $data) {
            $result = $this->createCompetency(
                code: $data['code'],
                name: $data['name'],
                description: $data['description'],
                category: $data['category'],
                parentId: $data['parent_id'] ?? null
            );
            
            if ($result['success']) {
                $created++;
            } else {
                $failed++;
                $errors[] = "Code {$data['code']}: {$result['error']}";
            }
        }
        
        return $this->success([
            'created' => $created,
            'failed' => $failed,
            'errors' => $errors
        ]);
    }
    
    private function mapCompetencyToArray(Competency $competency): array
    {
        return [
            'id' => $competency->getId()->getValue(),
            'code' => $competency->getCode()->getValue(),
            'name' => $competency->getName(),
            'description' => $competency->getDescription(),
            'category' => $competency->getCategory()->getValue(),
            'parent_id' => $competency->getParentId()?->getValue(),
            'is_active' => $competency->isActive()
        ];
    }

} 