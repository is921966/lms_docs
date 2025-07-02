<?php

declare(strict_types=1);

namespace Program\Http\Controllers;

// Removed BaseController inheritance
use Program\Application\UseCases\CreateProgramUseCase;
use Program\Application\UseCases\UpdateProgramUseCase;
use Program\Application\UseCases\PublishProgramUseCase;
use Program\Application\UseCases\EnrollUserUseCase;
use Program\Application\Requests\CreateProgramRequest;
use Program\Application\Requests\UpdateProgramRequest;
use Program\Application\Requests\EnrollUserRequest;
use Program\Domain\Repository\ProgramRepositoryInterface;
use Program\Domain\Repository\ProgramEnrollmentRepositoryInterface;
use Program\Domain\ValueObjects\ProgramId;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class ProgramController
{
    public function __construct(
        private readonly ProgramRepositoryInterface $programRepository,
        private readonly ProgramEnrollmentRepositoryInterface $enrollmentRepository,
        private readonly CreateProgramUseCase $createProgramUseCase,
        private readonly UpdateProgramUseCase $updateProgramUseCase,
        private readonly PublishProgramUseCase $publishProgramUseCase,
        private readonly EnrollUserUseCase $enrollUserUseCase
    ) {}

    public function index(): JsonResponse
    {
        $programs = $this->programRepository->findAll();
        
        return new JsonResponse([
            'data' => array_map(
                fn($program) => $this->serializeProgram($program),
                $programs
            )
        ]);
    }

    public function show(string $id): JsonResponse
    {
        $program = $this->programRepository->findById(ProgramId::fromString($id));
        
        if (!$program) {
            return new JsonResponse(['error' => 'Program not found'], Response::HTTP_NOT_FOUND);
        }
        
        return new JsonResponse(['data' => $this->serializeProgram($program)]);
    }

    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true);
        
        $createRequest = new CreateProgramRequest(
            $data['code'] ?? '',
            $data['name'] ?? '',
            $data['description'] ?? ''
        );
        
        $errors = $createRequest->validate();
        if (!empty($errors)) {
            return new JsonResponse(['errors' => $errors], Response::HTTP_BAD_REQUEST);
        }
        
        $programDto = $this->createProgramUseCase->execute($createRequest);
        
        // Get the created program to serialize
        $program = $this->programRepository->findById(ProgramId::fromString($programDto->id));
        
        return new JsonResponse(
            ['data' => $this->serializeProgram($program)],
            Response::HTTP_CREATED
        );
    }

    public function update(string $id, Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true);
        
        $updateRequest = new UpdateProgramRequest(
            $id,
            $data['name'] ?? null,
            $data['description'] ?? null
        );
        
        $errors = $updateRequest->validate();
        if (!empty($errors)) {
            return new JsonResponse(['errors' => $errors], Response::HTTP_BAD_REQUEST);
        }
        
        try {
                    $programDto = $this->updateProgramUseCase->execute($updateRequest);
        $program = $this->programRepository->findById(ProgramId::fromString($programDto->id));
        return new JsonResponse(['data' => $this->serializeProgram($program)]);
        } catch (\DomainException $e) {
            return new JsonResponse(['error' => $e->getMessage()], Response::HTTP_BAD_REQUEST);
        }
    }

    public function publish(string $id): JsonResponse
    {
        try {
            $this->publishProgramUseCase->execute($id);
            $program = $this->programRepository->findById(ProgramId::fromString($id));
            return new JsonResponse(['data' => $this->serializeProgram($program)]);
        } catch (\DomainException $e) {
            return new JsonResponse(['error' => $e->getMessage()], Response::HTTP_BAD_REQUEST);
        }
    }

    public function enroll(string $programId, Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true);
        
        $enrollRequest = new EnrollUserRequest(
            $data['userId'] ?? '',
            $programId
        );
        
        $errors = $enrollRequest->validate();
        if (!empty($errors)) {
            return new JsonResponse(['errors' => $errors], Response::HTTP_BAD_REQUEST);
        }
        
        try {
            $enrollmentDto = $this->enrollUserUseCase->execute($enrollRequest);
            // EnrollmentDTO has full entity data
            return new JsonResponse(
                ['data' => [
                    'id' => $enrollmentDto->id,
                    'programId' => $enrollmentDto->programId,
                    'userId' => $enrollmentDto->userId,
                    'status' => $enrollmentDto->status,
                    'enrolledAt' => $enrollmentDto->enrolledAt
                ]],
                Response::HTTP_CREATED
            );
        } catch (\DomainException $e) {
            return new JsonResponse(['error' => $e->getMessage()], Response::HTTP_BAD_REQUEST);
        }
    }

    private function serializeProgram($program): array
    {
        return [
            'id' => $program->getId()->toString(),
            'code' => $program->getCode()->getValue(),
            'name' => $program->getTitle(),
            'description' => $program->getDescription(),
            'status' => $program->getStatus()->getValue(),
            'tracks' => array_map(
                fn($trackId) => $trackId->toString(),
                $program->getTrackIds()
            )
        ];
    }

    private function serializeEnrollment($enrollment): array
    {
        return [
            'id' => $enrollment->getId()->toString(),
            'programId' => $enrollment->getProgramId()->toString(),
            'userId' => $enrollment->getUserId()->toString(),
            'status' => $enrollment->getStatus(),
            'enrolledAt' => $enrollment->getEnrolledAt()->format('Y-m-d H:i:s')
        ];
    }
} 