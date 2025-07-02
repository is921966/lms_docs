<?php

declare(strict_types=1);

namespace Program\Application\UseCases;

use Program\Application\Requests\EnrollUserRequest;
use Program\Application\DTO\ProgramEnrollmentDTO;
use Program\Domain\ProgramEnrollment;
use Program\Domain\Repository\ProgramRepositoryInterface;
use Program\Domain\Repository\ProgramEnrollmentRepositoryInterface;
use Program\Domain\ValueObjects\ProgramId;
use User\Domain\ValueObjects\UserId;

final class EnrollUserUseCase
{
    public function __construct(
        private readonly ProgramRepositoryInterface $programRepository,
        private readonly ProgramEnrollmentRepositoryInterface $enrollmentRepository
    ) {}
    
    public function execute(EnrollUserRequest $request): ProgramEnrollmentDTO
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
        
        // Check if program is active
        if (!$program->getStatus()->isActive()) {
            throw new \DomainException('Cannot enroll in program that is not active');
        }
        
        // Check if user already enrolled
        $userId = UserId::fromString($request->userId);
        $existingEnrollment = $this->enrollmentRepository->findByUserAndProgram(
            $userId,
            $programId
        );
        
        if ($existingEnrollment !== null) {
            throw new \DomainException('User already enrolled in this program');
        }
        
        // Create enrollment
        $enrollment = ProgramEnrollment::create($userId, $programId);
        
        // Save enrollment
        $this->enrollmentRepository->save($enrollment);
        
        // Return DTO
        return ProgramEnrollmentDTO::fromEntity($enrollment);
    }
} 