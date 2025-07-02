<?php

declare(strict_types=1);

namespace Program\Domain\Repository;

use Program\Domain\Program;
use Program\Domain\ValueObjects\ProgramId;
use Program\Domain\ValueObjects\ProgramCode;

interface ProgramRepositoryInterface
{
    public function save(Program $program): void;
    
    public function findById(ProgramId $id): ?Program;
    
    public function findByCode(ProgramCode $code): ?Program;
    
    /**
     * @return Program[]
     */
    public function findAll(): array;
    
    /**
     * @return Program[]
     */
    public function findActive(): array;
    
    public function delete(ProgramId $id): void;
    
    public function nextIdentity(): ProgramId;
} 