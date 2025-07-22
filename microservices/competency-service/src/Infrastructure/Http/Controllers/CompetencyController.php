<?php

namespace CompetencyService\Infrastructure\Http\Controllers;

use CompetencyService\Application\Services\CompetencyService;
use CompetencyService\Application\DTOs\CreateCompetencyDTO;
use CompetencyService\Application\DTOs\UpdateCompetencyDTO;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

#[Route('/api/v1/competencies')]
class CompetencyController
{
    public function __construct(
        private readonly CompetencyService $competencyService
    ) {}
    
    #[Route('', methods: ['GET'])]
    public function index(Request $request): JsonResponse
    {
        $category = $request->query->get('category');
        
        if ($category) {
            $competencies = $this->competencyService->getCompetenciesByCategory($category);
        } else {
            $competencies = $this->competencyService->getAllCompetencies();
        }
        
        return new JsonResponse([
            'data' => $competencies,
            'total' => count($competencies)
        ]);
    }
    
    #[Route('/{id}', methods: ['GET'])]
    public function show(string $id): JsonResponse
    {
        try {
            $competency = $this->competencyService->getCompetencyById($id);
            return new JsonResponse(['data' => $competency]);
        } catch (\DomainException $e) {
            return new JsonResponse(
                ['error' => $e->getMessage()],
                Response::HTTP_NOT_FOUND
            );
        }
    }
    
    #[Route('/code/{code}', methods: ['GET'])]
    public function showByCode(string $code): JsonResponse
    {
        try {
            $competency = $this->competencyService->getCompetencyByCode($code);
            return new JsonResponse(['data' => $competency]);
        } catch (\DomainException $e) {
            return new JsonResponse(
                ['error' => $e->getMessage()],
                Response::HTTP_NOT_FOUND
            );
        }
    }
    
    #[Route('', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        try {
            $data = json_decode($request->getContent(), true);
            
            $dto = new CreateCompetencyDTO(
                code: $data['code'] ?? '',
                name: $data['name'] ?? '',
                description: $data['description'] ?? '',
                category: $data['category'] ?? '',
                levels: $data['levels'] ?? []
            );
            
            $competency = $this->competencyService->createCompetency($dto);
            
            return new JsonResponse(
                ['data' => $competency],
                Response::HTTP_CREATED
            );
        } catch (\InvalidArgumentException $e) {
            return new JsonResponse(
                ['error' => $e->getMessage()],
                Response::HTTP_BAD_REQUEST
            );
        } catch (\DomainException $e) {
            return new JsonResponse(
                ['error' => $e->getMessage()],
                Response::HTTP_CONFLICT
            );
        }
    }
    
    #[Route('/{id}', methods: ['PUT'])]
    public function update(string $id, Request $request): JsonResponse
    {
        try {
            $data = json_decode($request->getContent(), true);
            
            $dto = new UpdateCompetencyDTO(
                id: $id,
                name: $data['name'] ?? '',
                description: $data['description'] ?? ''
            );
            
            $competency = $this->competencyService->updateCompetency($dto);
            
            return new JsonResponse(['data' => $competency]);
        } catch (\DomainException $e) {
            return new JsonResponse(
                ['error' => $e->getMessage()],
                Response::HTTP_NOT_FOUND
            );
        }
    }
    
    #[Route('/{id}/activate', methods: ['POST'])]
    public function activate(string $id): JsonResponse
    {
        try {
            $competency = $this->competencyService->activateCompetency($id);
            return new JsonResponse(['data' => $competency]);
        } catch (\DomainException $e) {
            return new JsonResponse(
                ['error' => $e->getMessage()],
                Response::HTTP_NOT_FOUND
            );
        }
    }
    
    #[Route('/{id}/deactivate', methods: ['POST'])]
    public function deactivate(string $id): JsonResponse
    {
        try {
            $competency = $this->competencyService->deactivateCompetency($id);
            return new JsonResponse(['data' => $competency]);
        } catch (\DomainException $e) {
            return new JsonResponse(
                ['error' => $e->getMessage()],
                Response::HTTP_NOT_FOUND
            );
        }
    }
} 