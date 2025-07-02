<?php

declare(strict_types=1);

namespace Program\Domain\Repository;

use Program\Domain\Track;
use Program\Domain\ValueObjects\TrackId;
use Program\Domain\ValueObjects\ProgramId;

interface TrackRepositoryInterface
{
    public function save(Track $track): void;
    
    public function findById(TrackId $id): ?Track;
    
    /**
     * @return Track[]
     */
    public function findByProgramId(ProgramId $programId): array;
    
    public function delete(TrackId $id): void;
    
    public function nextIdentity(): TrackId;
} 