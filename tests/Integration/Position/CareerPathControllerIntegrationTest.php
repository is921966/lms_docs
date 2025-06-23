<?php

declare(strict_types=1);

namespace Tests\Integration\Position;

use Tests\Integration\IntegrationTestCase;
use Tests\Integration\TestDataFactory;
use App\Position\Infrastructure\Http\CareerPathController;
use App\Position\Infrastructure\Http\PositionController;
use App\Position\Application\Service\CareerPathService;
use App\Position\Application\Service\PositionService;
use App\Position\Infrastructure\Repository\InMemoryPositionRepository;
use App\Position\Infrastructure\Repository\InMemoryCareerPathRepository;
use App\Position\Infrastructure\Repository\InMemoryPositionProfileRepository;
use App\Position\Domain\Service\CareerProgressionService;

class CareerPathControllerIntegrationTest extends IntegrationTestCase
{
    private CareerPathController $careerPathController;
    private PositionController $positionController;
    private string $juniorPositionId;
    private string $middlePositionId;
    private string $seniorPositionId;

    protected function setUp(): void
    {
        parent::setUp();
        
        // Setup repositories
        $positionRepo = new InMemoryPositionRepository();
        $careerPathRepo = new InMemoryCareerPathRepository();
        $profileRepo = new InMemoryPositionProfileRepository();
        
        // Setup domain service
        $progressionService = new CareerProgressionService();
        
        // Setup services
        $positionService = new PositionService($positionRepo, $profileRepo);
        $careerPathService = new CareerPathService($positionRepo, $careerPathRepo, $progressionService);
        
        // Setup controllers
        $this->positionController = new PositionController($positionService);
        $this->careerPathController = new CareerPathController($careerPathService);
        
        // Create test positions
        $this->createTestPositions();
    }

    private function createTestPositions(): void
    {
        // Create Junior position
        $juniorData = $this->createTestPosition([
            "code" => "DEV-001",
            "title" => "Junior Developer",
            "level" => 1
        ]);
        $response = $this->callControllerAction($this->positionController, "store", [], $juniorData);
        $this->juniorPositionId = $response["data"]["id"];

        // Create Middle position
        $middleData = $this->createTestPosition([
            "code" => "DEV-002",
            "title" => "Middle Developer",
            "level" => 2
        ]);
        $response = $this->callControllerAction($this->positionController, "store", [], $middleData);
        $this->middlePositionId = $response["data"]["id"];

        // Create Senior position
        $seniorData = $this->createTestPosition([
            "code" => "DEV-003",
            "title" => "Senior Developer",
            "level" => 3
        ]);
        $response = $this->callControllerAction($this->positionController, "store", [], $seniorData);
        $this->seniorPositionId = $response["data"]["id"];
    }

    public function testCompleteCareerPathLifecycle(): void
    {
        // 1. Create career path from Junior to Middle
        $careerPathData = [
            'fromPositionId' => $this->juniorPositionId,
            'toPositionId' => $this->middlePositionId,
            'requirements' => [
                '2 years experience as Junior Developer',
                'Complete internal certification',
                'Lead at least 2 small projects'
            ],
            'estimatedDuration' => 24
        ];
        
        $response = $this->callControllerAction($this->careerPathController, 'createCareerPath', [], $careerPathData);
        
        $this->assertSuccessResponse($response);
        $careerPath = $response['data'];
        $this->assertEquals($this->juniorPositionId, $careerPath['fromPositionId']);
        $this->assertEquals($this->middlePositionId, $careerPath['toPositionId']);
        $this->assertCount(3, $careerPath['requirements']);
        $this->assertEquals(24, $careerPath['estimatedDuration']);

        // 2. Get career path
        $response = $this->callControllerAction(
            $this->careerPathController,
            'getCareerPath',
            [
                'fromPositionId' => $this->juniorPositionId,
                'toPositionId' => $this->middlePositionId
            ]
        );
        
        $this->assertSuccessResponse($response);
        $this->assertEquals($this->juniorPositionId, $response['data']['fromPositionId']);

        // 3. Add milestone
        $milestoneData = [
            'title' => 'Basic Certification',
            'description' => 'Complete company\'s basic development certification',
            'monthsFromStart' => 6
        ];
        
        $response = $this->callControllerAction(
            $this->careerPathController,
            'addMilestone',
            ['id' => $careerPath['id']],
            $milestoneData
        );
        
        $this->assertArrayHasKey('status', $response);
        $this->assertEquals('success', $response['status']);
        $this->assertStringContainsString('added', $response['message']);

        // 4. Get career progress
        $response = $this->callControllerAction(
            $this->careerPathController,
            'getCareerProgress',
            [
                'fromPositionId' => $this->juniorPositionId,
                'toPositionId' => $this->middlePositionId
            ],
            [
                'employeeId' => 'emp-001',
                'monthsCompleted' => 12
            ]
        );
        
        $this->assertSuccessResponse($response);
        $progress = $response['data'];
        $this->assertEquals('emp-001', $progress['employeeId']);
        $this->assertEquals(12, $progress['monthsCompleted']);
        $this->assertEquals(50, $progress['progressPercentage']);
        $this->assertEquals(12, $progress['remainingMonths']);
        $this->assertFalse($progress['isEligibleForPromotion']);
    }

    public function testGetCareerProgressWithMilestones(): void
    {
        // Create career path with milestones
        $careerPathData = [
            'fromPositionId' => $this->middlePositionId,
            'toPositionId' => $this->seniorPositionId,
            'requirements' => [
                '3 years experience as Middle Developer',
                'Advanced certification',
                'Lead major project'
            ],
            'estimatedDuration' => 36
        ];
        
        $response = $this->callControllerAction($this->careerPathController, 'createCareerPath', [], $careerPathData);
        $careerPathId = $response['data']['id'];

        // Add milestones
        $milestones = [
            ['title' => 'First Year Review', 'description' => 'Pass first year performance review', 'monthsFromStart' => 12],
            ['title' => 'Advanced Certification', 'description' => 'Complete advanced certification', 'monthsFromStart' => 24],
            ['title' => 'Project Leadership', 'description' => 'Successfully lead major project', 'monthsFromStart' => 30]
        ];

        foreach ($milestones as $milestone) {
            $this->callControllerAction(
                $this->careerPathController,
                'addMilestone',
                ['id' => $careerPathId],
                $milestone
            );
        }

        // Check progress at 25 months
        $response = $this->callControllerAction(
            $this->careerPathController,
            'getCareerProgress',
            [
                'fromPositionId' => $this->middlePositionId,
                'toPositionId' => $this->seniorPositionId
            ],
            [
                'employeeId' => 'emp-002',
                'monthsCompleted' => 25
            ]
        );
        
        $this->assertSuccessResponse($response);
        $progress = $response['data'];
        
        // Should have completed 2 milestones
        $this->assertCount(2, $progress['completedMilestones']);
        $this->assertEquals('First Year Review', $progress['completedMilestones'][0]['title']);
        $this->assertEquals('Advanced Certification', $progress['completedMilestones'][1]['title']);
        
        // Next milestone should be Project Leadership
        $this->assertNotNull($progress['nextMilestone']);
        $this->assertEquals('Project Leadership', $progress['nextMilestone']['title']);
        
        // Progress percentage (25/36 = ~69%)
        $this->assertEquals(69, $progress['progressPercentage']);
    }

    public function testCreateCareerPathForNonExistentPositions(): void
    {
        $nonExistentId1 = TestDataFactory::nonExistentUuid();
        $nonExistentId2 = TestDataFactory::nonExistentUuid();
        
        $careerPathData = [
            'fromPositionId' => $nonExistentId1,
            'toPositionId' => $nonExistentId2,
            'requirements' => ['Test requirement'],
            'estimatedDuration' => 24
        ];
        
        $response = $this->callControllerAction($this->careerPathController, 'createCareerPath', [], $careerPathData);
        
        $this->assertErrorResponse($response, 'Position not found');
    }

    public function testCreateDuplicateCareerPath(): void
    {
        // Create first career path
        $careerPathData = [
            'fromPositionId' => $this->juniorPositionId,
            'toPositionId' => $this->middlePositionId,
            'requirements' => ['Test requirement'],
            'estimatedDuration' => 24
        ];
        
        $this->callControllerAction($this->careerPathController, 'createCareerPath', [], $careerPathData);
        
        // Try to create duplicate
        $response = $this->callControllerAction($this->careerPathController, 'createCareerPath', [], $careerPathData);
        
        $this->assertErrorResponse($response, 'already exists');
    }

    public function testGetNonExistentCareerPath(): void
    {
        $nonExistentId1 = TestDataFactory::nonExistentUuid();
        $nonExistentId2 = TestDataFactory::nonExistentUuid();
        
        $response = $this->callControllerAction(
            $this->careerPathController,
            'getCareerPath',
            [
                'fromPositionId' => $nonExistentId1,
                'toPositionId' => $nonExistentId2
            ]
        );
        
        $this->assertErrorResponse($response, 'Career path not found');
    }

    public function testCareerProgressEligibility(): void
    {
        // Create career path
        $careerPathData = [
            'fromPositionId' => $this->juniorPositionId,
            'toPositionId' => $this->middlePositionId,
            'requirements' => ['2 years experience'],
            'estimatedDuration' => 24
        ];
        
        $this->callControllerAction($this->careerPathController, 'createCareerPath', [], $careerPathData);

        // Check progress at 24 months (should be eligible)
        $response = $this->callControllerAction(
            $this->careerPathController,
            'getCareerProgress',
            [
                'fromPositionId' => $this->juniorPositionId,
                'toPositionId' => $this->middlePositionId
            ],
            [
                'employeeId' => 'emp-003',
                'monthsCompleted' => 24
            ]
        );
        
        $this->assertSuccessResponse($response);
        $progress = $response['data'];
        $this->assertEquals(100, $progress['progressPercentage']);
        $this->assertEquals(0, $progress['remainingMonths']);
        $this->assertTrue($progress['isEligibleForPromotion']);
    }

    public function testInvalidCareerPathData(): void
    {
        // Test with invalid estimated duration
        $careerPathData = [
            'fromPositionId' => $this->juniorPositionId,
            'toPositionId' => $this->middlePositionId,
            'requirements' => [],
            'estimatedDuration' => -5 // Invalid
        ];
        
        $response = $this->callControllerAction($this->careerPathController, 'createCareerPath', [], $careerPathData);
        
        $this->assertErrorResponse($response, 'Estimated duration must be positive');
    }
}
