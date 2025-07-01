<?php

namespace Competency\Domain\Repositories;

use Competency\Domain\Entities\CompetencyCategory;

interface CompetencyCategoryRepositoryInterface
{
    public function save(CompetencyCategory $category): void;
    
    public function findById(string $id): ?CompetencyCategory;
    
    public function findByName(string $name): ?CompetencyCategory;
    
    public function findAll(): array;
    
    public function findActive(): array;
    
    public function delete(string $id): void;
} 