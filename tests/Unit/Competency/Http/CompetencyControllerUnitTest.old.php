<?php

declare(strict_types=1);

namespace Tests\Unit\Competency\Http;

use Competency\Http\Controllers\CompetencyController;
use Competency\Domain\Competency;
use Competency\Domain\ValueObjects\CompetencyCategory;
use Competency\Domain\ValueObjects\CompetencyId;
use Competency\Domain\Repositories\CompetencyRepositoryInterface;
use Competency\Domain\Repositories\CompetencyCategoryRepositoryInterface;
use Competency\Application\Handlers\CreateCompetencyHandler;
use Competency\Application\Handlers\AssessCompetencyHandler;
use Competency\Application\Commands\CreateCompetencyCommand;
use Competency\Application\Commands\AssessCompetencyCommand;
use Illuminate\Http\Request;
use Mockery;
use PHPUnit\Framework\TestCase;

class CompetencyControllerUnitTest extends TestCase
{
    private CompetencyController $controller;
    private $competencyRepository;
    private $categoryRepository;
    private $createHandler;
    private $assessHandler;

    protected function setUp(): void
    {
        parent::setUp();
        
        $this->competencyRepository = Mockery::mock(CompetencyRepositoryInterface::class);
        $this->categoryRepository = Mockery::mock(CompetencyCategoryRepositoryInterface::class);
        $this->createHandler = Mockery::mock(CreateCompetencyHandler::class);
        $this->assessHandler = Mockery::mock(AssessCompetencyHandler::class);
        
        $this->controller = new CompetencyController(
            $this->competencyRepository,
            $this->categoryRepository,
            $this->createHandler,
            $this->assessHandler
        );
    }

    protected function tearDown(): void
    {
        Mockery::close();
        parent::tearDown();
    }

    public function testIndexReturnsAllCompetencies(): void
    {
        // Arrange
        $category = CompetencyCategory::create('Tech', 'Technical skills');
        $competency1 = Competency::create('PHP', 'PHP programming', $category);
        $competency2 = Competency::create('JS', 'JavaScript', $category);
        
        $this->competencyRepository
            ->shouldReceive('findAll')
            ->once()
            ->andReturn([$competency1, $competency2]);
        
        $request = new Request();
        
        // Act
        $response = $this->controller->index($request);
        
        // Assert
        $this->assertEquals(200, $response->getStatusCode());
        $data = json_decode($response->getContent(), true);
        $this->assertCount(2, $data['data']);
        $this->assertEquals(2, $data['meta']['total']);
    }

    public function testIndexFiltersByCategory(): void
    {
        // Arrange
        $categoryId = 'cat-123';
        $category = CompetencyCategory::create('Tech', 'Technical skills');
        $competency = Competency::create('PHP', 'PHP programming', $category);
        
        $this->competencyRepository
            ->shouldReceive('findByCategory')
            ->with($categoryId)
            ->once()
            ->andReturn([$competency]);
        
        $request = new Request(['category_id' => $categoryId]);
        
        // Act
        $response = $this->controller->index($request);
        
        // Assert
        $this->assertEquals(200, $response->getStatusCode());
        $data = json_decode($response->getContent(), true);
        $this->assertCount(1, $data['data']);
    }

    public function testShowReturnsCompetency(): void
    {
        // Arrange
        $competencyId = 'comp-123';
        $category = CompetencyCategory::create('Tech', 'Technical skills');
        $competency = Competency::create('PHP', 'PHP programming', $category);
        
        $this->competencyRepository
            ->shouldReceive('findById')
            ->with($competencyId)
            ->once()
            ->andReturn($competency);
        
        // Act
        $response = $this->controller->show($competencyId);
        
        // Assert
        $this->assertEquals(200, $response->getStatusCode());
        $data = json_decode($response->getContent(), true);
        $this->assertEquals('PHP', $data['data']['name']);
    }

    public function testShowReturnsNotFoundForNonExistentCompetency(): void
    {
        // Arrange
        $competencyId = 'non-existent';
        
        $this->competencyRepository
            ->shouldReceive('findById')
            ->with($competencyId)
            ->once()
            ->andReturn(null);
        
        // Act
        $response = $this->controller->show($competencyId);
        
        // Assert
        $this->assertEquals(404, $response->getStatusCode());
        $data = json_decode($response->getContent(), true);
        $this->assertEquals('Competency not found', $data['error']);
    }

    public function testStoreCreatesCompetency(): void
    {
        // Arrange
        $categoryId = 'cat-123';
        $category = CompetencyCategory::create('Tech', 'Technical skills');
        $competencyId = 'comp-456';
        $competency = Competency::createWithId(
            CompetencyId::fromString($competencyId),
            'New Competency',
            'Description',
            $category
        );
        
        $this->categoryRepository
            ->shouldReceive('findById')
            ->with($categoryId)
            ->once()
            ->andReturn($category);
        
        $this->createHandler
            ->shouldReceive('handle')
            ->withArgs(function ($command) {
                return $command instanceof CreateCompetencyCommand
                    && $command->name === 'New Competency'
                    && $command->description === 'Description';
            })
            ->once()
            ->andReturn($competencyId);
        
        $this->competencyRepository
            ->shouldReceive('findById')
            ->with($competencyId)
            ->once()
            ->andReturn($competency);
        
        $request = new Request([
            'name' => 'New Competency',
            'description' => 'Description',
            'category_id' => $categoryId
        ]);
        
        // Act
        $response = $this->controller->store($request);
        
        // Assert
        $this->assertEquals(201, $response->getStatusCode());
        $data = json_decode($response->getContent(), true);
        $this->assertEquals('Competency created successfully', $data['message']);
    }

    public function testAssessCompetency(): void
    {
        // Arrange
        $competencyId = 'comp-123';
        
        $this->assessHandler
            ->shouldReceive('handle')
            ->withArgs(function ($command) use ($competencyId) {
                return $command instanceof AssessCompetencyCommand
                    && $command->competencyId === $competencyId
                    && $command->level === 3;
            })
            ->once();
        
        $request = new Request([
            'user_id' => 'user-123',
            'assessor_id' => 'assessor-123',
            'level' => 3,
            'comment' => 'Good progress'
        ]);
        
        // Act
        $response = $this->controller->assess($competencyId, $request);
        
        // Assert
        $this->assertEquals(200, $response->getStatusCode());
        $data = json_decode($response->getContent(), true);
        $this->assertEquals('Assessment recorded successfully', $data['message']);
    }
}
