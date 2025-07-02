<?php

declare(strict_types=1);

namespace Program\Application\UseCases;

use Program\Application\Requests\UpdateProgramRequest;
use Program\Application\DTO\ProgramDTO;
use Program\Domain\Repository\ProgramRepositoryInterface;
use Program\Domain\ValueObjects\ProgramId;

final class UpdateProgramUseCase
{
    public function __construct(
        private readonly ProgramRepositoryInterface $programRepository
    ) {}
    
    public function execute(UpdateProgramRequest $request): ProgramDTO
    {
        // Validate request
        if (!$request->isValid()) {
            throw new \InvalidArgumentException(
                'Invalid request: ' . implode(', ', $request->validate())
            );
        }
        
        // Find program
        $programId = ProgramId::fromString($request->programId);
        $program = $this->programRepository->findById($programId);
        
        if ($program === null) {
            throw new \DomainException('Program not found');
        }
        
        // Check if program is draft
        if (!$program->getStatus()->isDraft()) {
            throw new \DomainException('Only draft programs can be updated');
        }
        
        // Update program
        $program->updateBasicInfo($request->title, $request->description);
        
        // Update metadata if provided
        if ($request->metadata !== null) {
            $program->setMetadata($request->metadata);
        }
        
        // Save program
        $this->programRepository->save($program);
        
        // Return DTO
        return ProgramDTO::fromEntity($program);
    }
} 