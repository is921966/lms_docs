<?php

declare(strict_types=1);

namespace Program\Infrastructure\Persistence;

use Program\Domain\Repository\TrackRepositoryInterface;
use Program\Domain\Track;
use Program\Domain\ValueObjects\TrackId;
use Program\Domain\ValueObjects\ProgramId;

class InMemoryTrackRepository implements TrackRepositoryInterface
{
    private array $tracks = [];

    public function save(Track $track): void
    {
        $this->tracks[$track->getId()->toString()] = $track;
    }

    public function findById(TrackId $id): ?Track
    {
        return $this->tracks[$id->toString()] ?? null;
    }

    public function findByProgramId(ProgramId $programId): array
    {
        return array_filter(
            $this->tracks,
            fn(Track $track) => $track->getProgramId()->equals($programId)
        );
    }

    public function findAll(): array
    {
        return array_values($this->tracks);
    }

    public function delete(TrackId $id): void
    {
        unset($this->tracks[$id->toString()]);
    }

    public function nextIdentity(): TrackId
    {
        return TrackId::generate();
    }
} 