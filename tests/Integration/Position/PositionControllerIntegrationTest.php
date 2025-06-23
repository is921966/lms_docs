<?php

declare(strict_types=1);

namespace Tests\Integration\Position;

use Tests\Integration\IntegrationTestCase;
use Tests\Integration\TestDataFactory;
use App\Position\Infrastructure\Http\PositionController;
use App\Position\Application\Service\PositionService;
use App\Position\Infrastructure\Repository\InMemoryPositionRepository;
use App\Position\Infrastructure\Repository\InMemoryPositionProfileRepository;

class PositionControllerIntegrationTest extends IntegrationTestCase
{
    private PositionController $controller;
    private InMemoryPositionRepository $repository;
    private InMemoryPositionProfileRepository $profileRepository;

    protected function setUp(): void
    {
        parent::setUp();
        
        $this->repository = new InMemoryPositionRepository();
        $this->profileRepository = new InMemoryPositionProfileRepository();
        $service = new PositionService($this->repository, $this->profileRepository);
        $this->controller = new PositionController($service);
    }

    public function testCompletePositionLifecycle(): void
    {
        // 1. Create position
        $createData = $this->createTestPosition();
        $response = $this->callControllerAction($this->controller, 'store', [], $createData);
        
        $this->assertSuccessResponse($response);
        $position = $response['data'];
        $this->assertEquals($createData['code'], $position['code']);
        $this->assertEquals('Test Position', $position['title']);
        
        $positionId = $position['id'];

        // 2. Get position by ID
        $response = $this->callControllerAction($this->controller, 'show', ['id' => $positionId]);
        
        $this->assertSuccessResponse($response);
        $this->assertEquals($positionId, $response['data']['id']);

        // 3. Update position
        $updateData = [
            'title' => 'Updated Test Position',
            'description' => 'Updated description',
            'level' => 3
        ];
        $response = $this->callControllerAction($this->controller, 'update', ['id' => $positionId], $updateData);
        
        $this->assertSuccessResponse($response);
        $this->assertEquals('Updated Test Position', $response['data']['title']);
        $this->assertEquals(3, $response['data']['level']);

        // 4. List all positions
        $response = $this->callControllerAction($this->controller, 'index');
        
        $this->assertSuccessResponse($response);
        $this->assertCount(1, $response['data']);
        $this->assertEquals($positionId, $response['data'][0]['id']);

        // 5. Archive position
        $response = $this->callControllerAction($this->controller, 'archive', ['id' => $positionId]);
        
        $this->assertArrayHasKey('status', $response);
        $this->assertEquals('success', $response['status']);
        $this->assertArrayHasKey('message', $response);
        $this->assertStringContainsString('archived', $response['message']);

        // 6. Verify position is archived (not in active list)
        $response = $this->callControllerAction($this->controller, 'index');
        
        $this->assertSuccessResponse($response);
        $this->assertCount(0, $response['data']);
    }

    public function testCreatePositionWithInvalidData(): void
    {
        $invalidData = [
            'code' => 'invalid-code', // Should be uppercase with hyphen and numbers
            'title' => '', // Required
            'department' => 'IT',
            'level' => 10, // Max is 6
            'description' => 'Test'
        ];

        $response = $this->callControllerAction($this->controller, 'store', [], $invalidData);
        
        $this->assertErrorResponse($response);
        $this->assertStringContainsString('Validation failed', $response['message']);
    }

    public function testGetNonExistentPosition(): void
    {
        $nonExistentId = TestDataFactory::nonExistentUuid();
        $response = $this->callControllerAction($this->controller, 'show', ['id' => $nonExistentId]);
        
        $this->assertErrorResponse($response, 'Position not found');
    }

    public function testUpdateNonExistentPosition(): void
    {
        $nonExistentId = TestDataFactory::nonExistentUuid();
        $updateData = [
            'title' => 'Updated',
            'description' => 'Updated',
            'level' => 2
        ];

        $response = $this->callControllerAction($this->controller, 'update', ['id' => $nonExistentId], $updateData);
        
        $this->assertErrorResponse($response, 'Position not found');
    }

    public function testArchiveNonExistentPosition(): void
    {
        $nonExistentId = TestDataFactory::nonExistentUuid();
        $response = $this->callControllerAction($this->controller, 'archive', ['id' => $nonExistentId]);
        
        $this->assertErrorResponse($response, 'Position not found');
    }

    public function testGetPositionsByDepartment(): void
    {
        // Create positions in different departments
        $this->callControllerAction($this->controller, 'store', [], 
            $this->createTestPosition(['code' => 'IT-001', 'department' => 'IT']));
        $this->callControllerAction($this->controller, 'store', [], 
            $this->createTestPosition(['code' => 'IT-002', 'department' => 'IT']));
        $this->callControllerAction($this->controller, 'store', [], 
            $this->createTestPosition(['code' => 'HR-001', 'department' => 'HR']));

        // Get IT department positions
        $response = $this->callControllerAction($this->controller, 'getByDepartment', ['department' => 'IT']);
        
        $this->assertSuccessResponse($response);
        $this->assertCount(2, $response['data']);
        $this->assertEquals('IT', $response['data'][0]['department']);
        $this->assertEquals('IT', $response['data'][1]['department']);

        // Get HR department positions
        $response = $this->callControllerAction($this->controller, 'getByDepartment', ['department' => 'HR']);
        
        $this->assertSuccessResponse($response);
        $this->assertCount(1, $response['data']);
        $this->assertEquals('HR', $response['data'][0]['department']);
    }

    public function testCreatePositionWithParent(): void
    {
        // Create parent position
        $parentData = $this->createTestPosition(['code' => 'MGR-001', 'title' => 'Manager']);
        $parentResponse = $this->callControllerAction($this->controller, 'store', [], $parentData);
        $parentId = $parentResponse['data']['id'];

        // Create child position
        $childData = $this->createTestPosition([
            'code' => 'DEV-001',
            'title' => 'Developer',
            'parentId' => $parentId
        ]);
        $response = $this->callControllerAction($this->controller, 'store', [], $childData);
        
        $this->assertSuccessResponse($response);
        $this->assertEquals($parentId, $response['data']['parentId']);
    }

    public function testUpdatePositionLevel(): void
    {
        // Create position
        $createData = $this->createTestPosition(['level' => 1]);
        $createResponse = $this->callControllerAction($this->controller, 'store', [], $createData);
        $positionId = $createResponse['data']['id'];

        // Update level
        $updateData = [
            'title' => 'Test Position',
            'description' => 'Test position description',
            'level' => 4
        ];
        $response = $this->callControllerAction($this->controller, 'update', ['id' => $positionId], $updateData);
        
        $this->assertSuccessResponse($response);
        $this->assertEquals(4, $response['data']['level']);
        $this->assertEquals('Lead', $response['data']['levelName']);
    }
} 