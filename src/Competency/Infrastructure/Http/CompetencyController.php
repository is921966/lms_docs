<?php

declare(strict_types=1);

namespace App\Competency\Infrastructure\Http;

use App\Competency\Application\DTO\CompetencyDTO;
use App\Competency\Application\Service\CompetencyService;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class CompetencyController
{
    public function __construct(
        private readonly CompetencyService $competencyService
    ) {
    }
    
    public function create(Request $request): JsonResponse
    {
        try {
            $data = $this->getJsonData($request);
            
            $result = $this->competencyService->createCompetency(
                code: $data['code'] ?? '',
                name: $data['name'] ?? '',
                description: $data['description'] ?? '',
                category: $data['category'] ?? '',
                parentId: $data['parent_id'] ?? null
            );
            
            if (!$result['success']) {
                return $this->json($result, Response::HTTP_BAD_REQUEST);
            }
            
            // Convert to DTO for response
            $competency = $this->competencyService->getCompetencyById($result['competency_id']);
            $dto = CompetencyDTO::fromArray($competency['data']);
            
            return $this->json([
                'success' => true,
                'data' => $dto->toArray()
            ], Response::HTTP_CREATED);
            
        } catch (\Exception $e) {
            return $this->json([
                'success' => false,
                'error' => $e->getMessage()
            ], Response::HTTP_BAD_REQUEST);
        }
    }
    
    public function get(string $id): JsonResponse
    {
        $result = $this->competencyService->getCompetencyById($id);
        
        if (!$result['success']) {
            return $this->json($result, Response::HTTP_NOT_FOUND);
        }
        
        $dto = CompetencyDTO::fromArray($result['data']);
        
        return $this->json([
            'success' => true,
            'data' => $dto->toArray()
        ]);
    }
    
    public function update(string $id, Request $request): JsonResponse
    {
        try {
            $data = $this->getJsonData($request);
            
            $result = $this->competencyService->updateCompetency(
                id: $id,
                name: $data['name'] ?? '',
                description: $data['description'] ?? ''
            );
            
            if (!$result['success']) {
                return $this->json($result, Response::HTTP_BAD_REQUEST);
            }
            
            // Get updated competency
            $competency = $this->competencyService->getCompetencyById($id);
            $dto = CompetencyDTO::fromArray($competency['data']);
            
            return $this->json([
                'success' => true,
                'data' => $dto->toArray()
            ]);
            
        } catch (\Exception $e) {
            return $this->json([
                'success' => false,
                'error' => $e->getMessage()
            ], Response::HTTP_BAD_REQUEST);
        }
    }
    
    public function list(Request $request): JsonResponse
    {
        $category = $request->query->get('category');
        $active = $request->query->getBoolean('active', true);
        $search = $request->query->get('search');
        
        if ($search) {
            $result = $this->competencyService->searchCompetencies($search);
        } elseif ($category) {
            $result = $this->competencyService->getCompetenciesByCategory($category);
        } elseif ($active) {
            $result = $this->competencyService->getActiveCompetencies();
        } else {
            // For now, return active competencies
            $result = $this->competencyService->getActiveCompetencies();
        }
        
        if (!$result['success']) {
            return $this->json($result, Response::HTTP_BAD_REQUEST);
        }
        
        // Convert to DTOs
        $dtos = array_map(
            fn($competency) => CompetencyDTO::fromArray($competency)->toArray(),
            $result['data']
        );
        
        return $this->json([
            'success' => true,
            'data' => $dtos
        ]);
    }
    
    public function delete(string $id): JsonResponse
    {
        $result = $this->competencyService->deactivateCompetency($id);
        
        if (!$result['success']) {
            return $this->json($result, Response::HTTP_NOT_FOUND);
        }
        
        return $this->json([
            'success' => true,
            'data' => [
                'id' => $result['competency_id'],
                'is_active' => $result['is_active']
            ]
        ]);
    }
    
    private function getJsonData(Request $request): array
    {
        $content = $request->getContent();
        if (empty($content)) {
            return [];
        }
        
        return json_decode($content, true) ?? [];
    }
    
    private function json(array $data, int $status = Response::HTTP_OK): JsonResponse
    {
        return new JsonResponse($data, $status);
    }
} 