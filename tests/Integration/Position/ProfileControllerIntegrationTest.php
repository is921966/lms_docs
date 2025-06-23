<?php

declare(strict_types=1);

namespace Tests\Integration\Position;

use Tests\Integration\IntegrationTestCase;
use Tests\Integration\TestDataFactory;
use App\Position\Infrastructure\Http\ProfileController;
use App\Position\Infrastructure\Http\PositionController;
use App\Position\Application\Service\ProfileService;
use App\Position\Application\Service\PositionService;
use App\Position\Infrastructure\Repository\InMemoryPositionRepository;
use App\Position\Infrastructure\Repository\InMemoryPositionProfileRepository;

class ProfileControllerIntegrationTest extends IntegrationTestCase
{
    private ProfileController $profileController;
    private PositionController $positionController;
    private string $testPositionId;

    protected function setUp(): void
    {
        parent::setUp();
        
        // Setup repositories
        $positionRepo = new InMemoryPositionRepository();
        $profileRepo = new InMemoryPositionProfileRepository();
        
        // Setup services
        $positionService = new PositionService($positionRepo, $profileRepo);
        $profileService = new ProfileService($positionRepo, $profileRepo);
        
        // Setup controllers
        $this->positionController = new PositionController($positionService);
        $this->profileController = new ProfileController($profileService);
        
        // Create test position
        $this->createTestPositionSetup();
    }

    private function createTestPositionSetup(): void
    {
        $positionData = $this->createTestPosition();
        $response = $this->callControllerAction($this->positionController, 'store', [], $positionData);
        $this->testPositionId = $response['data']['id'];
    }

    public function testCompleteProfileLifecycle(): void
    {
        // 1. Create profile
        $profileData = $this->createTestProfile($this->testPositionId, [
            'responsibilities' => [
                'Lead development team',
                'Code reviews',
                'Architecture design'
            ],
            'requirements' => [
                '5+ years experience',
                'Strong leadership skills',
                'Excellent communication'
            ]
        ]);
        
        $response = $this->callControllerAction($this->profileController, 'createProfile', [], $profileData);
        
        $this->assertSuccessResponse($response);
        $profile = $response['data'];
        $this->assertEquals($this->testPositionId, $profile['positionId']);
        $this->assertCount(3, $profile['responsibilities']);
        $this->assertCount(3, $profile['requirements']);

        // 2. Get profile by position ID
        $response = $this->callControllerAction(
            $this->profileController, 
            'getProfile', 
            ['positionId' => $this->testPositionId]
        );
        
        $this->assertSuccessResponse($response);
        $this->assertEquals($this->testPositionId, $response['data']['positionId']);

        // 3. Update profile
        $updateData = [
            'responsibilities' => [
                'Lead development team',
                'Code reviews',
                'Architecture design',
                'Mentoring junior developers'
            ],
            'requirements' => [
                '7+ years experience',
                'Strong leadership skills',
                'Excellent communication',
                'Teaching skills'
            ]
        ];
        
        $response = $this->callControllerAction(
            $this->profileController,
            'updateProfile',
            ['positionId' => $this->testPositionId],
            $updateData
        );
        
        $this->assertSuccessResponse($response);
        $this->assertCount(4, $response['data']['responsibilities']);
        $this->assertCount(4, $response['data']['requirements']);
    }

    public function testAddAndRemoveCompetencyRequirements(): void
    {
        // Create profile first
        $profileData = $this->createTestProfile($this->testPositionId);
        $this->callControllerAction($this->profileController, 'createProfile', [], $profileData);

        // Add competency requirement
        $competencyId = TestDataFactory::validUuid();
        $competencyData = [
            'competencyId' => $competencyId,
            'minimumLevel' => 3,
            'isRequired' => true
        ];
        
        $response = $this->callControllerAction(
            $this->profileController,
            'addCompetencyRequirement',
            ['positionId' => $this->testPositionId],
            $competencyData
        );
        
        $this->assertArrayHasKey('status', $response);
        $this->assertEquals('success', $response['status']);
        $this->assertStringContainsString('added', $response['message']);

        // Verify competency was added
        $response = $this->callControllerAction(
            $this->profileController,
            'getProfile',
            ['positionId' => $this->testPositionId]
        );
        
        $this->assertCount(1, $response['data']['requiredCompetencies']);
        $this->assertEquals($competencyId, $response['data']['requiredCompetencies'][0]['competencyId']);

        // Remove competency requirement
        $response = $this->callControllerAction(
            $this->profileController,
            'removeCompetencyRequirement',
            ['positionId' => $this->testPositionId, 'competencyId' => $competencyId]
        );
        
        $this->assertArrayHasKey('status', $response);
        $this->assertEquals('success', $response['status']);
        $this->assertStringContainsString('removed', $response['message']);

        // Verify competency was removed
        $response = $this->callControllerAction(
            $this->profileController,
            'getProfile',
            ['positionId' => $this->testPositionId]
        );
        
        $this->assertCount(0, $response['data']['requiredCompetencies']);
    }

    public function testCreateProfileForNonExistentPosition(): void
    {
        $nonExistentPositionId = TestDataFactory::nonExistentUuid();
        $profileData = $this->createTestProfile($nonExistentPositionId);
        
        $response = $this->callControllerAction($this->profileController, 'createProfile', [], $profileData);
        
        $this->assertErrorResponse($response, 'Position not found');
    }

    public function testGetNonExistentProfile(): void
    {
        $nonExistentPositionId = TestDataFactory::nonExistentUuid();
        
        $response = $this->callControllerAction(
            $this->profileController,
            'getProfile',
            ['positionId' => $nonExistentPositionId]
        );
        
        $this->assertErrorResponse($response, 'Profile not found');
    }

    public function testUpdateNonExistentProfile(): void
    {
        $nonExistentPositionId = TestDataFactory::nonExistentUuid();
        
        $updateData = [
            'responsibilities' => ['Test'],
            'requirements' => ['Test']
        ];
        
        $response = $this->callControllerAction(
            $this->profileController,
            'updateProfile',
            ['positionId' => $nonExistentPositionId],
            $updateData
        );
        
        $this->assertErrorResponse($response, 'Profile not found');
    }

    public function testAddDuplicateCompetencyRequirement(): void
    {
        // Create profile
        $profileData = $this->createTestProfile($this->testPositionId);
        $this->callControllerAction($this->profileController, 'createProfile', [], $profileData);

        // Add competency requirement
        $competencyId = TestDataFactory::validUuid();
        $competencyData = [
            'competencyId' => $competencyId,
            'minimumLevel' => 3,
            'isRequired' => true
        ];
        
        $this->callControllerAction(
            $this->profileController,
            'addCompetencyRequirement',
            ['positionId' => $this->testPositionId],
            $competencyData
        );

        // Try to add same competency again
        $response = $this->callControllerAction(
            $this->profileController,
            'addCompetencyRequirement',
            ['positionId' => $this->testPositionId],
            $competencyData
        );
        
        $this->assertErrorResponse($response, 'already exists');
    }

    public function testAddCompetencyWithInvalidLevel(): void
    {
        // Create profile
        $profileData = $this->createTestProfile($this->testPositionId);
        $this->callControllerAction($this->profileController, 'createProfile', [], $profileData);

        // Add competency with invalid level
        $competencyData = [
            'competencyId' => TestDataFactory::validUuid(),
            'minimumLevel' => 10, // Max is 5
            'isRequired' => true
        ];
        
        $response = $this->callControllerAction(
            $this->profileController,
            'addCompetencyRequirement',
            ['positionId' => $this->testPositionId],
            $competencyData
        );
        
        $this->assertErrorResponse($response, 'Invalid competency level');
    }

    public function testRemoveNonExistentCompetency(): void
    {
        // Create profile
        $profileData = $this->createTestProfile($this->testPositionId);
        $this->callControllerAction($this->profileController, 'createProfile', [], $profileData);

        // Try to remove non-existent competency
        $nonExistentCompetencyId = TestDataFactory::nonExistentUuid();
        
        $response = $this->callControllerAction(
            $this->profileController,
            'removeCompetencyRequirement',
            ['positionId' => $this->testPositionId, 'competencyId' => $nonExistentCompetencyId]
        );
        
        $this->assertErrorResponse($response, 'Competency requirement not found');
    }
} 