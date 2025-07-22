<?php

namespace CompetencyService\Domain\Repositories;

use CompetencyService\Domain\Entities\CompetencyMatrix;
use CompetencyService\Domain\ValueObjects\MatrixId;

interface MatrixRepositoryInterface
{
    public function findById(MatrixId $id): ?CompetencyMatrix;
    
    public function findByPosition(string $positionId): array;
    
    public function findAll(): array;
    
    public function save(CompetencyMatrix $matrix): void;
    
    public function delete(MatrixId $id): void;
} 