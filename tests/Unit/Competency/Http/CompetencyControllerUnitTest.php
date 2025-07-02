<?php

namespace Tests\Unit\Competency\Http;

use PHPUnit\Framework\TestCase;
use Competency\Http\Controllers\CompetencyController;
use Competency\Domain\Competency;
use Competency\Domain\ValueObjects\CompetencyCategory;
use Competency\Domain\ValueObjects\CompetencyCode;
use Competency\Domain\ValueObjects\CompetencyId;
use Competency\Domain\Repositories\CompetencyRepositoryInterface;
use Competency\Domain\Repositories\CompetencyCategoryRepositoryInterface;
use Competency\Application\Handlers\CreateCompetencyHandler;
use Competency\Application\Handlers\AssessCompetencyHandler;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\JsonResponse;

class CompetencyControllerUnitTest extends TestCase
{
    private CompetencyController $controller;
    private $competencyRepo;
    private $categoryRepo;
    private $createHandler;
    private $assessHandler;

    protected function setUp(): void
    {
        $this->competencyRepo = $this->createMock(CompetencyRepositoryInterface::class);
        $this->categoryRepo = $this->createMock(CompetencyCategoryRepositoryInterface::class);
        $this->createHandler = $this->createMock(CreateCompetencyHandler::class);
        $this->assessHandler = $this->createMock(AssessCompetencyHandler::class);

        $this->controller = new CompetencyController(
            $this->competencyRepo,
            $this->categoryRepo,
            $this->createHandler,
            $this->assessHandler
        );
    }

    public function testIndexReturnsAllCompetencies()
    {
        // Arrange
        $competency = Competency::create(
            CompetencyId::generate(),
            CompetencyCode::fromString('PHP-001'),
            'PHP Development',
            'PHP programming skills',
            CompetencyCategory::technical()
        );

        $this->competencyRepo
            ->expects($this->once())
            ->method('findAll')
            ->willReturn([$competency]);

        $request = new Request();

        // Act
        $response = $this->controller->index($request);

        // Assert
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(200, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertArrayHasKey('data', $data);
        $this->assertCount(1, $data['data']);
    }

    public function testIndexFiltersByCategory()
    {
        // Arrange
        $competency = Competency::create(
            CompetencyId::generate(),
            CompetencyCode::fromString('COMM-001'),
            'Communication',
            'Communication skills',
            CompetencyCategory::soft()
        );

        $this->competencyRepo
            ->expects($this->once())
            ->method('findByCategory')
            ->with('soft-skills-category-id')
            ->willReturn([$competency]);

        $request = new Request();
        $request->setQuery(['category_id' => 'soft-skills-category-id']);

        // Act
        $response = $this->controller->index($request);

        // Assert
        $this->assertInstanceOf(JsonResponse::class, $response);
        $data = json_decode($response->getContent(), true);
        $this->assertCount(1, $data['data']);
    }

    public function testShowReturnsCompetency()
    {
        // Arrange
        $competencyId = CompetencyId::generate();
        $competency = Competency::create(
            $competencyId,
            CompetencyCode::fromString('JS-001'),
            'JavaScript',
            'JavaScript programming',
            CompetencyCategory::technical()
        );

        $this->competencyRepo
            ->expects($this->once())
            ->method('findById')
            ->with($competencyId->getValue())
            ->willReturn($competency);

        // Act
        $response = $this->controller->show($competencyId->getValue());

        // Assert
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(200, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertArrayHasKey('data', $data);
        $this->assertEquals('JavaScript', $data['data']['name']);
    }

    public function testShowReturnsNotFoundForNonExistentCompetency()
    {
        // Arrange
        $this->competencyRepo
            ->expects($this->once())
            ->method('findById')
            ->with('non-existent-id')
            ->willReturn(null);

        // Act
        $response = $this->controller->show('non-existent-id');

        // Assert
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(404, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertArrayHasKey('error', $data);
    }

    public function testStoreCreatesCompetency()
    {
        // Arrange
        $request = new Request();
        $request->setAttribute('name', 'Python Development');
        $request->setAttribute('description', 'Python programming skills');
        $request->setAttribute('category_id', 'tech-category-id');

        // Mock category exists
        $this->categoryRepo
            ->expects($this->once())
            ->method('findById')
            ->with('tech-category-id')
            ->willReturn((object)['id' => 'tech-category-id']); // Simple mock object

        $newCompetencyId = CompetencyId::generate()->getValue();
        $this->createHandler
            ->expects($this->once())
            ->method('handle')
            ->willReturn($newCompetencyId);

        $createdCompetency = Competency::create(
            CompetencyId::fromString($newCompetencyId),
            CompetencyCode::fromString('PY-001'),
            'Python Development',
            'Python programming skills',
            CompetencyCategory::technical()
        );

        $this->competencyRepo
            ->expects($this->once())
            ->method('findById')
            ->with($newCompetencyId)
            ->willReturn($createdCompetency);

        // Act
        $response = $this->controller->store($request);

        // Assert
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(201, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertArrayHasKey('data', $data);
        $this->assertArrayHasKey('message', $data);
    }

    public function testAssessCompetency()
    {
        // Arrange
        $competencyId = CompetencyId::generate()->getValue();
        
        $request = new Request();
        $request->setAttribute('user_id', 'user-123');
        $request->setAttribute('assessor_id', 'assessor-456');
        $request->setAttribute('level', 3);
        $request->setAttribute('comment', 'Good progress');

        $this->assessHandler
            ->expects($this->once())
            ->method('handle');

        // Act
        $response = $this->controller->assess($competencyId, $request);

        // Assert
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(200, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertArrayHasKey('message', $data);
    }
} 