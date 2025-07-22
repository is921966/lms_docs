<?php

namespace CompetencyService\Domain\Repositories;

use CompetencyService\Domain\Entities\Competency;
use CompetencyService\Domain\ValueObjects\CompetencyId;
use CompetencyService\Domain\ValueObjects\CompetencyCode;

interface CompetencyRepositoryInterface
{
    public function findById(CompetencyId $id): ?Competency;
    
    public function findByCode(CompetencyCode $code): ?Competency;
    
    public function findAll(): array;
    
    public function findByCategory(string $category): array;
    
    public function save(Competency $competency): void;
    
    public function delete(CompetencyId $id): void;
} 