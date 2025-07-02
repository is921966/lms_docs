<?php

declare(strict_types=1);

namespace Tests\Integration\Program\Http\Controllers;

use PHPUnit\Framework\TestCase;
use Program\Http\Controllers\ProgramController;
use Program\Infrastructure\Persistence\InMemoryProgramRepository;
use Program\Infrastructure\Persistence\InMemoryProgramEnrollmentRepository;
use Program\Infrastructure\Persistence\InMemoryTrackRepository;
use Program\Application\UseCases\CreateProgramUseCase;
use Program\Application\UseCases\UpdateProgramUseCase;
use Program\Application\UseCases\PublishProgramUseCase;
use Program\Application\UseCases\EnrollUserUseCase;
use Program\Domain\Program;
use Program\Domain\Track;
use Program\Domain\ValueObjects\ProgramId;
use Program\Domain\ValueObjects\ProgramCode;
use Program\Domain\ValueObjects\TrackId;
use Program\Domain\ValueObjects\TrackOrder;
use User\Domain\ValueObjects\UserId;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class ProgramControllerIntegrationTest extends TestCase
{
    private ProgramController $controller;
    private InMemoryProgramRepository $programRepository;
    private InMemoryProgramEnrollmentRepository $enrollmentRepository;
    private InMemoryTrackRepository $trackRepository;
    private MockUserRepository $userRepository;

    protected function setUp(): void
    {
        $this->programRepository = new InMemoryProgramRepository();
        $this->enrollmentRepository = new InMemoryProgramEnrollmentRepository();
        $this->trackRepository = new InMemoryTrackRepository();
        $this->userRepository = new MockUserRepository();

        $createProgramUseCase = new CreateProgramUseCase($this->programRepository);
        $updateProgramUseCase = new UpdateProgramUseCase($this->programRepository);
        $publishProgramUseCase = new PublishProgramUseCase(
            $this->programRepository,
            $this->trackRepository
        );
        $enrollUserUseCase = new EnrollUserUseCase(
            $this->programRepository,
            $this->enrollmentRepository,
            $this->userRepository
        );

        $this->controller = new ProgramController(
            $this->programRepository,
            $this->enrollmentRepository,
            $createProgramUseCase,
            $updateProgramUseCase,
            $publishProgramUseCase,
            $enrollUserUseCase
        );
    }

    public function testIndexReturnsEmptyArrayWhenNoPrograms(): void
    {
        $response = $this->controller->index();

        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
        $data = json_decode($response->getContent(), true);
        $this->assertCount(0, $data['data']);
    }

    public function testCreateAndRetrieveProgram(): void
    {
        // Create program
        $requestData = [
            'code' => 'PROG-001',
            'name' => 'Test Program',
            'description' => 'Test Description'
        ];
        
        $request = new Request([], [], [], [], [], [], json_encode($requestData));
        $createResponse = $this->controller->create($request);

        $this->assertEquals(Response::HTTP_CREATED, $createResponse->getStatusCode());
        $createdData = json_decode($createResponse->getContent(), true);
        $programId = $createdData['data']['id'];

        // Retrieve program
        $showResponse = $this->controller->show($programId);
        
        $this->assertEquals(Response::HTTP_OK, $showResponse->getStatusCode());
        $showData = json_decode($showResponse->getContent(), true);
        $this->assertEquals('PROG-001', $showData['data']['code']);
        $this->assertEquals('Test Program', $showData['data']['name']);
    }

    public function testUpdateProgram(): void
    {
        // Create program first
        $program = Program::create(
            ProgramId::generate(),
            ProgramCode::fromString('PROG-002'),
            'Original Name',
            'Original Description'
        );
        $this->programRepository->save($program);

        // Update program
        $updateData = [
            'name' => 'Updated Name',
            'description' => 'Updated Description'
        ];
        
        $request = new Request([], [], [], [], [], [], json_encode($updateData));
        $response = $this->controller->update($program->getId()->toString(), $request);

        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
        $data = json_decode($response->getContent(), true);
        $this->assertEquals('Updated Name', $data['data']['name']);
        $this->assertEquals('Updated Description', $data['data']['description']);
    }

    public function testPublishProgramFailsWithoutTracks(): void
    {
        // Create program without tracks
        $program = Program::create(
            ProgramId::generate(),
            ProgramCode::fromString('PROG-003'),
            'Empty Program',
            'No tracks'
        );
        $this->programRepository->save($program);

        // Try to publish
        $response = $this->controller->publish($program->getId()->toString());

        $this->assertEquals(Response::HTTP_BAD_REQUEST, $response->getStatusCode());
        $data = json_decode($response->getContent(), true);
        $this->assertArrayHasKey('error', $data);
    }

    public function testEnrollUserInProgram(): void
    {
        // Create and publish program
        $program = Program::create(
            ProgramId::generate(),
            ProgramCode::fromString('PROG-004'),
            'Active Program',
            'Ready for enrollment'
        );
        // Add a track to satisfy publish requirements
        $track = Track::create(
            TrackId::generate(),
            $program->getId(),
            'Test Track',
            'Test track description',
            TrackOrder::fromInt(1)
        );
        $this->trackRepository->save($track);
        $program->addTrack($track->getId());
        $program->publish();
        $this->programRepository->save($program);

        // Create user
        $userId = UserId::generate();
        $user = $this->createMockUser($userId);
        $this->userRepository->save($user);

        // Enroll user
        $enrollData = ['userId' => $userId->getValue()];
        $request = new Request([], [], [], [], [], [], json_encode($enrollData));
        $response = $this->controller->enroll($program->getId()->toString(), $request);

        $this->assertEquals(Response::HTTP_CREATED, $response->getStatusCode());
        $data = json_decode($response->getContent(), true);
        $this->assertEquals($userId->getValue(), $data['data']['userId']);
        $this->assertEquals('enrolled', $data['data']['status']);
    }

    public function testInvalidProgramCodeReturnsError(): void
    {
        $requestData = [
            'code' => 'INVALID_CODE', // Invalid format
            'name' => 'Test Program',
            'description' => 'Test Description'
        ];
        
        $request = new Request([], [], [], [], [], [], json_encode($requestData));
        $response = $this->controller->create($request);

        $this->assertEquals(Response::HTTP_BAD_REQUEST, $response->getStatusCode());
        $data = json_decode($response->getContent(), true);
        $this->assertArrayHasKey('errors', $data);
    }

    private function createMockUser(UserId $userId): object
    {
        return new class($userId) {
            private UserId $id;
            private bool $isActive = true;

            public function __construct(UserId $id)
            {
                $this->id = $id;
            }

            public function getId(): UserId
            {
                return $this->id;
            }

            public function isActive(): bool
            {
                return $this->isActive;
            }
        };
    }
}

// Simple mock user repository for testing
class MockUserRepository
{
    private array $users = [];

    public function save($user): void
    {
        $this->users[$user->getId()->getValue()] = $user;
    }

    public function findById(UserId $id)
    {
        return $this->users[$id->getValue()] ?? null;
    }
} 