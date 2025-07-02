<?php

declare(strict_types=1);

namespace Competency\Http\Controllers;

use Competency\Application\Commands\CreateCompetencyCommand;
use Competency\Application\Commands\AssessCompetencyCommand;
use Competency\Application\Handlers\CreateCompetencyHandler;
use Competency\Application\Handlers\AssessCompetencyHandler;
use Competency\Application\DTO\CompetencyDTO;
use Competency\Domain\Repositories\CompetencyRepositoryInterface;
use Competency\Domain\Repositories\CompetencyCategoryRepositoryInterface;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Symfony\Component\HttpFoundation\Response;

use function response;

class CompetencyController
{
    public function __construct(
        private CompetencyRepositoryInterface $competencyRepository,
        private CompetencyCategoryRepositoryInterface $categoryRepository,
        private CreateCompetencyHandler $createHandler,
        private AssessCompetencyHandler $assessHandler
    ) {}

    /**
     * List all competencies with optional filtering
     */
    public function index(Request $request): JsonResponse
    {
        $categoryId = $request->query('category_id');
        $isActive = $request->query('is_active', true);
        
        if ($categoryId) {
            $competencies = $this->competencyRepository->findByCategory($categoryId);
        } else {
            $competencies = $this->competencyRepository->findAll();
        }

        // Filter by active status if needed
        if ($isActive !== null) {
            $competencies = array_filter(
                $competencies,
                fn($c) => $c->isActive() === (bool)$isActive
            );
        }

        $dtos = array_map(
            fn($competency) => CompetencyDTO::fromEntity($competency),
            array_values($competencies)
        );

        return response()->json([
            'data' => $dtos,
            'meta' => [
                'total' => count($dtos)
            ]
        ]);
    }

    /**
     * Get a specific competency by ID
     */
    public function show(string $id): JsonResponse
    {
        $competency = $this->competencyRepository->findById($id);

        if (!$competency) {
            return response()->json([
                'error' => 'Competency not found'
            ], Response::HTTP_NOT_FOUND);
        }

        return response()->json([
            'data' => CompetencyDTO::fromEntity($competency)
        ]);
    }

    /**
     * Create a new competency
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:200',
            'description' => 'required|string',
            'category_id' => 'required|string'
        ]);

        // Verify category exists
        $category = $this->categoryRepository->findById($validated['category_id']);
        if (!$category) {
            return response()->json([
                'error' => 'Category not found'
            ], Response::HTTP_BAD_REQUEST);
        }

        $command = new CreateCompetencyCommand(
            $validated['name'],
            $validated['description'],
            $validated['category_id']
        );

        try {
            $competencyId = $this->createHandler->handle($command);
            $competency = $this->competencyRepository->findById($competencyId);

            return response()->json([
                'data' => CompetencyDTO::fromEntity($competency),
                'message' => 'Competency created successfully'
            ], Response::HTTP_CREATED);
        } catch (\Exception $e) {
            return response()->json([
                'error' => $e->getMessage()
            ], Response::HTTP_BAD_REQUEST);
        }
    }

    /**
     * Update an existing competency
     */
    public function update(string $id, Request $request): JsonResponse
    {
        $competency = $this->competencyRepository->findById($id);
        
        if (!$competency) {
            return response()->json([
                'error' => 'Competency not found'
            ], Response::HTTP_NOT_FOUND);
        }

        $validated = $request->validate([
            'name' => 'sometimes|string|max:200',
            'description' => 'sometimes|string',
            'category_id' => 'sometimes|string',
            'is_active' => 'sometimes|boolean'
        ]);

        if (isset($validated['name']) || isset($validated['description'])) {
            $competency->updateDetails(
                $validated['name'] ?? $competency->getName(),
                $validated['description'] ?? $competency->getDescription()
            );
        }

        if (isset($validated['category_id'])) {
            $category = $this->categoryRepository->findById($validated['category_id']);
            if (!$category) {
                return response()->json([
                    'error' => 'Category not found'
                ], Response::HTTP_BAD_REQUEST);
            }
            $competency->changeCategory($category);
        }

        if (isset($validated['is_active'])) {
            $validated['is_active'] ? $competency->activate() : $competency->deactivate();
        }

        $this->competencyRepository->save($competency);

        return response()->json([
            'data' => CompetencyDTO::fromEntity($competency),
            'message' => 'Competency updated successfully'
        ]);
    }

    /**
     * Delete a competency
     */
    public function destroy(string $id): JsonResponse
    {
        $competency = $this->competencyRepository->findById($id);
        
        if (!$competency) {
            return response()->json([
                'error' => 'Competency not found'
            ], Response::HTTP_NOT_FOUND);
        }

        $this->competencyRepository->delete($id);

        return response()->json([
            'message' => 'Competency deleted successfully'
        ]);
    }

    /**
     * Assess a competency for a user
     */
    public function assess(string $id, Request $request): JsonResponse
    {
        $validated = $request->validate([
            'user_id' => 'required|string',
            'assessor_id' => 'required|string',
            'level' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string'
        ]);

        $command = new AssessCompetencyCommand(
            $validated['user_id'],
            $id,
            $validated['level'],
            $validated['assessor_id'],
            $validated['comment'] ?? null
        );

        try {
            $this->assessHandler->handle($command);

            return response()->json([
                'message' => 'Assessment recorded successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'error' => $e->getMessage()
            ], Response::HTTP_BAD_REQUEST);
        }
    }
}
