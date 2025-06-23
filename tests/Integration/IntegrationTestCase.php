<?php

declare(strict_types=1);

namespace Tests\Integration;

use PHPUnit\Framework\TestCase;
use App\Common\Http\BaseController;
use Ramsey\Uuid\Uuid;

abstract class IntegrationTestCase extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();
        // Reset any static state
        $this->resetRepositories();
    }

    protected function tearDown(): void
    {
        parent::tearDown();
        // Clean up after tests
        $this->resetRepositories();
    }

    /**
     * Reset all in-memory repositories to empty state
     */
    private function resetRepositories(): void
    {
        // This would reset singleton instances if we had them
        // For now, repositories are created fresh in each controller
    }

    /**
     * Call controller action and return response array
     */
    protected function callControllerAction(
        BaseController $controller,
        string $method,
        array $params = [],
        ?array $body = null
    ): array {
        // Simulate request parameters
        $_GET = $params;
        $_POST = $body ?? [];
        $_SERVER['REQUEST_METHOD'] = match($method) {
            'index', 'show' => 'GET',
            'store' => 'POST',
            'update' => 'PUT',
            'destroy' => 'DELETE',
            default => 'GET'
        };

        // Capture output
        ob_start();
        
        try {
            $result = $controller->$method(...array_values($params));
            
            // If controller returns array, use it
            if (is_array($result)) {
                ob_end_clean();
                return $result;
            }
            
            // Otherwise parse JSON output
            $output = ob_get_clean();
            return json_decode($output, true) ?? [];
        } catch (\Exception $e) {
            ob_end_clean();
            return [
                'status' => 'error',
                'message' => $e->getMessage()
            ];
        }
    }

    /**
     * Assert successful response
     */
    protected function assertSuccessResponse(array $response, string $message = ''): void
    {
        $this->assertArrayHasKey('status', $response, $message);
        $this->assertEquals('success', $response['status'], $message);
        $this->assertArrayHasKey('data', $response, $message);
    }

    /**
     * Assert error response
     */
    protected function assertErrorResponse(array $response, string $expectedMessage = ''): void
    {
        $this->assertArrayHasKey('status', $response);
        $this->assertEquals('error', $response['status']);
        $this->assertArrayHasKey('message', $response);
        
        if ($expectedMessage) {
            $this->assertStringContainsString($expectedMessage, $response['message']);
        }
    }

    /**
     * Generate valid position code
     */
    private function generatePositionCode(): string
    {
        $prefixes = ['IT', 'HR', 'FIN', 'MGR', 'DEV'];
        $prefix = $prefixes[array_rand($prefixes)];
        $number = str_pad((string)rand(100, 999), 3, '0', STR_PAD_LEFT);
        return $prefix . '-' . $number;
    }

    /**
     * Create test data helpers
     */
    protected function createTestPosition(array $overrides = []): array
    {
        return array_merge([
            'code' => $overrides['code'] ?? $this->generatePositionCode(),
            'title' => 'Test Position',
            'department' => 'Testing',
            'level' => 2,
            'description' => 'Test position description',
            'parentId' => null
        ], $overrides);
    }

    protected function createTestProfile(string $positionId, array $overrides = []): array
    {
        return array_merge([
            'positionId' => $positionId,
            'responsibilities' => ['Test responsibility'],
            'requirements' => ['Test requirement']
        ], $overrides);
    }

    protected function createTestCareerPath(array $overrides = []): array
    {
        return array_merge([
            'fromPositionId' => Uuid::uuid4()->toString(),
            'toPositionId' => Uuid::uuid4()->toString(),
            'requirements' => ['Test requirement'],
            'estimatedDuration' => 24
        ], $overrides);
    }
}
