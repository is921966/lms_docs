<?php

declare(strict_types=1);

namespace Competency\Domain\Repository;

use Competency\Domain\Competency;
use Competency\Domain\ValueObjects\CompetencyCategory;
use Competency\Domain\ValueObjects\CompetencyCode;
use Competency\Domain\ValueObjects\CompetencyId;

interface CompetencyRepositoryInterface
{
    /**
     * Save a competency (create or update)
     */
    public function save(Competency $competency): void;
    
    /**
     * Find competency by ID
     */
    public function findById(CompetencyId $id): ?Competency;
    
    /**
     * Find competency by code
     */
    public function findByCode(CompetencyCode $code): ?Competency;
    
    /**
     * Find all competencies by category
     * @return Competency[]
     */
    public function findByCategory(CompetencyCategory $category): array;
    
    /**
     * Find all active competencies
     * @return Competency[]
     */
    public function findActive(): array;
    
    /**
     * Find child competencies
     * @return Competency[]
     */
    public function findChildren(CompetencyId $parentId): array;
    
    /**
     * Search competencies by name or description
     * @return Competency[]
     */
    public function search(string $query): array;
    
    /**
     * Check if competency with code exists
     */
    public function existsByCode(CompetencyCode $code): bool;
    
    /**
     * Get next available code in sequence
     */
    public function getNextCode(string $prefix): CompetencyCode;
    
    /**
     * Delete competency (soft delete by deactivating)
     */
    public function delete(CompetencyId $id): void;
} 