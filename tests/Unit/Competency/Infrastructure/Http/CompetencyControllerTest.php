<?php

declare(strict_types=1);

namespace Tests\Unit\Competency\Infrastructure\Http;

use App\Competency\Application\Service\CompetencyService;
use App\Competency\Infrastructure\Http\CompetencyController;
use App\Competency\Infrastructure\Repository\InMemoryCompetencyRepository;
use PHPUnit\Framework\TestCase;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class CompetencyControllerTest extends TestCase
{
    private CompetencyController $controller;
    private CompetencyService $service;
    
    protected function setUp(): void
    {
        $repository = new InMemoryCompetencyRepository();
        $this->service = new CompetencyService($repository);
        $this->controller = new CompetencyController($this->service);
    }
    
    public function testCreateCompetency(): void
    {
        $requestData = [
            'code' => 'TECH-001',
            'name' => 'PHP Development',
            'description' => 'PHP programming skills',
            'category' => 'technical'
        ];
        
        $request = new Request([], [], [], [], [], [], json_encode($requestData));
        $request->headers->set('Content-Type', 'application/json');
        
        $response = $this->controller->create($request);
        
        $this->assertEquals(Response::HTTP_CREATED, $response->getStatusCode());
        
        $responseData = json_decode($response->getContent(), true);
        $this->assertTrue($responseData['success']);
        $this->assertArrayHasKey('data', $responseData);
        $this->assertEquals('TECH-001', $responseData['data']['code']);
    }
    
    public function testCreateCompetencyWithInvalidData(): void
    {
        $requestData = [
            'code' => 'TECH-001',
            'name' => 'PHP Development',
            'description' => 'PHP programming skills',
            'category' => 'invalid_category'
        ];
        
        $request = new Request([], [], [], [], [], [], json_encode($requestData));
        $request->headers->set('Content-Type', 'application/json');
        
        $response = $this->controller->create($request);
        
        $this->assertEquals(Response::HTTP_BAD_REQUEST, $response->getStatusCode());
        
        $responseData = json_decode($response->getContent(), true);
        $this->assertFalse($responseData['success']);
        $this->assertArrayHasKey('error', $responseData);
    }
    
    public function testGetCompetency(): void
    {
        // First create a competency
        $createResult = $this->service->createCompetency(
            code: 'TECH-001',
            name: 'PHP Development',
            description: 'PHP programming skills',
            category: 'technical'
        );
        
        $competencyId = $createResult['competency_id'];
        
        // Now get it
        $response = $this->controller->get($competencyId);
        
        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
        
        $responseData = json_decode($response->getContent(), true);
        $this->assertTrue($responseData['success']);
        $this->assertEquals('TECH-001', $responseData['data']['code']);
    }
    
    public function testGetNonExistentCompetency(): void
    {
        $response = $this->controller->get('non-existent-id');
        
        $this->assertEquals(Response::HTTP_NOT_FOUND, $response->getStatusCode());
        
        $responseData = json_decode($response->getContent(), true);
        $this->assertFalse($responseData['success']);
    }
    
    public function testUpdateCompetency(): void
    {
        // First create a competency
        $createResult = $this->service->createCompetency(
            code: 'TECH-001',
            name: 'PHP Development',
            description: 'PHP programming skills',
            category: 'technical'
        );
        
        $competencyId = $createResult['competency_id'];
        
        // Update it
        $requestData = [
            'name' => 'Advanced PHP Development',
            'description' => 'Advanced PHP programming skills'
        ];
        
        $request = new Request([], [], [], [], [], [], json_encode($requestData));
        $request->headers->set('Content-Type', 'application/json');
        
        $response = $this->controller->update($competencyId, $request);
        
        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
        
        $responseData = json_decode($response->getContent(), true);
        $this->assertTrue($responseData['success']);
        $this->assertEquals('Advanced PHP Development', $responseData['data']['name']);
    }
    
    public function testListCompetencies(): void
    {
        // Create some competencies
        $this->service->createCompetency('TECH-001', 'PHP', 'PHP skills', 'technical');
        $this->service->createCompetency('TECH-002', 'JavaScript', 'JS skills', 'technical');
        $this->service->createCompetency('SOFT-001', 'Communication', 'Communication skills', 'soft');
        
        // List all
        $request = new Request();
        $response = $this->controller->list($request);
        
        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
        
        $responseData = json_decode($response->getContent(), true);
        $this->assertTrue($responseData['success']);
        $this->assertCount(3, $responseData['data']);
    }
    
    public function testListCompetenciesByCategory(): void
    {
        // Create some competencies
        $this->service->createCompetency('TECH-001', 'PHP', 'PHP skills', 'technical');
        $this->service->createCompetency('TECH-002', 'JavaScript', 'JS skills', 'technical');
        $this->service->createCompetency('SOFT-001', 'Communication', 'Communication skills', 'soft');
        
        // List by category
        $request = new Request(['category' => 'technical']);
        $response = $this->controller->list($request);
        
        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
        
        $responseData = json_decode($response->getContent(), true);
        $this->assertTrue($responseData['success']);
        $this->assertCount(2, $responseData['data']);
    }
    
    public function testDeleteCompetency(): void
    {
        // Create a competency
        $createResult = $this->service->createCompetency(
            code: 'TECH-001',
            name: 'PHP Development',
            description: 'PHP programming skills',
            category: 'technical'
        );
        
        $competencyId = $createResult['competency_id'];
        
        // Delete it (deactivate)
        $response = $this->controller->delete($competencyId);
        
        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
        
        $responseData = json_decode($response->getContent(), true);
        $this->assertTrue($responseData['success']);
        $this->assertFalse($responseData['data']['is_active']);
    }
} 