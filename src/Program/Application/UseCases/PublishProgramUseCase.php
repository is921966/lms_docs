<?php

declare(strict_types=1);

namespace Program\Application\UseCases;

use Program\Domain\Repository\ProgramRepositoryInterface;
use Program\Domain\Repository\TrackRepositoryInterface;
use Program\Domain\ValueObjects\ProgramId;

final class PublishProgramUseCase
{
    public function __construct(
        private readonly ProgramRepositoryInterface $programRepository,
        private readonly TrackRepositoryInterface $trackRepository
    ) {}
    
    public function execute(string $programId): bool
    {
        // Find program
        $id = ProgramId::fromString($programId);
        $program = $this->programRepository->findById($id);
        
        if ($program === null) {
            throw new \DomainException('Program not found');
        }
        
        // Check if already published
        if ($program->getStatus()->isActive()) {
            throw new \DomainException('Program is already published');
        }
        
        // Check if has tracks
        $tracks = $this->trackRepository->findByProgramId($id);
        
        if (count($tracks) === 0) {
            throw new \DomainException('Cannot publish program without tracks');
        }
        
        // Add tracks to program (to pass isEmpty check)
        foreach ($tracks as $track) {
            $program->addTrack($track->getId());
        }
        
        // Publish program
        $program->publish();
        
        // Save program
        $this->programRepository->save($program);
        
        return true;
    }
} 