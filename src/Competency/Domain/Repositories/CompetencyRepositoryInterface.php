<?php

namespace Competency\Domain\Repositories;

use Competency\Domain\Competency;

interface CompetencyRepositoryInterface
{
    public function save(Competency $competency): void;
    
    public function findById(string $id): ?Competency;
    
    public function findByName(string $name): ?Competency;
    
    public function findAll(): array;
    
    public function findByCategory(string $categoryId): array;
    
    public function delete(string $id): void;
} 