<?php

declare(strict_types=1);

namespace Program\Application\UseCases;

use Program\Application\Requests\CreateProgramRequest;
use Program\Application\DTO\ProgramDTO;
use Program\Domain\Program;
use Program\Domain\Repository\ProgramRepositoryInterface;
use Program\Domain\ValueObjects\ProgramCode;
use Program\Domain\ValueObjects\CompletionCriteria;

final class CreateProgramUseCase
{
    public function __construct(
        private readonly ProgramRepositoryInterface $repository
    ) {}
    
    public function execute(CreateProgramRequest $request): ProgramDTO
    {
        // Validate request
        if (!$request->isValid()) {
            throw new \InvalidArgumentException(
                'Invalid request: ' . implode(', ', $request->validate())
            );
        }
        
        // Check for duplicate code
        $programCode = ProgramCode::fromString($request->code);
        $existingProgram = $this->repository->findByCode($programCode);
        
        if ($existingProgram !== null) {
            throw new \DomainException(
                "Program with code {$request->code} already exists"
            );
        }
        
        // Create program
        $program = Program::create(
            $this->repository->nextIdentity(),
            $programCode,
            $request->title,
            $request->description
        );
        
        // Set completion criteria
        if ($request->requireAllCourses) {
            $program->setCompletionCriteria(CompletionCriteria::requireAll());
        } else {
            $program->setCompletionCriteria(
                CompletionCriteria::fromPercentage($request->completionPercentage)
            );
        }
        
        // Set metadata if provided
        if (!empty($request->metadata)) {
            $program->setMetadata($request->metadata);
        }
        
        // Save program
        $this->repository->save($program);
        
        // Return DTO
        return ProgramDTO::fromEntity($program);
    }
} 