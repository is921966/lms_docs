<?php

declare(strict_types=1);

namespace Competency\Http\Controllers;

use Competency\Domain\Entities\CompetencyCategory;
use Competency\Domain\Repositories\CompetencyCategoryRepositoryInterface;
use Competency\Http\Resources\CompetencyCategoryResource;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Symfony\Component\HttpFoundation\Response;

class CompetencyCategoryController
{
    public function __construct(
        private CompetencyCategoryRepositoryInterface $repository
    ) {}

    /**
     * List all categories
     */
    public function index(Request $request): JsonResponse
    {
        $parentId = $request->query('parent_id');
        $isActive = $request->query('is_active', true);
        
        if ($parentId !== null) {
            // Get categories by parent (including root if parent_id is empty string)
            $categories = $this->repository->findByParentId($parentId ?: null);
        } else {
            $categories = $this->repository->findAll();
        }

        // Filter by active status
        if ($isActive !== null) {
            $categories = array_filter(
                $categories,
                fn($c) => $c->isActive() === (bool)$isActive
            );
        }

        return response()->json([
            'data' => CompetencyCategoryResource::collection($categories),
            'meta' => [
                'total' => count($categories)
            ]
        ]);
    }

    /**
     * Get a specific category
     */
    public function show(string $id): JsonResponse
    {
        $category = $this->repository->findById($id);

        if (!$category) {
            return response()->json([
                'error' => 'Category not found'
            ], Response::HTTP_NOT_FOUND);
        }

        return response()->json([
            'data' => new CompetencyCategoryResource($category)
        ]);
    }

    /**
     * Create a new category
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:100',
            'description' => 'required|string',
            'parent_id' => 'nullable|string|exists:competency_categories,id'
        ]);

        $category = CompetencyCategory::create(
            $validated['name'],
            $validated['description']
        );

        // Set parent if provided
        if (!empty($validated['parent_id'])) {
            $parent = $this->repository->findById($validated['parent_id']);
            if ($parent) {
                $category->setParent($parent);
            }
        }

        $this->repository->save($category);

        return response()->json([
            'data' => new CompetencyCategoryResource($category),
            'message' => 'Category created successfully'
        ], Response::HTTP_CREATED);
    }

    /**
     * Update a category
     */
    public function update(string $id, Request $request): JsonResponse
    {
        $category = $this->repository->findById($id);
        
        if (!$category) {
            return response()->json([
                'error' => 'Category not found'
            ], Response::HTTP_NOT_FOUND);
        }

        $validated = $request->validate([
            'name' => 'sometimes|string|max:100',
            'description' => 'sometimes|string',
            'parent_id' => 'sometimes|nullable|string|exists:competency_categories,id',
            'is_active' => 'sometimes|boolean'
        ]);

        if (isset($validated['name']) || isset($validated['description'])) {
            $category->updateDetails(
                $validated['name'] ?? $category->getName(),
                $validated['description'] ?? $category->getDescription()
            );
        }

        if (array_key_exists('parent_id', $validated)) {
            if ($validated['parent_id']) {
                $parent = $this->repository->findById($validated['parent_id']);
                if ($parent) {
                    $category->setParent($parent);
                }
            } else {
                $category->removeParent();
            }
        }

        if (isset($validated['is_active'])) {
            $validated['is_active'] ? $category->activate() : $category->deactivate();
        }

        $this->repository->save($category);

        return response()->json([
            'data' => new CompetencyCategoryResource($category),
            'message' => 'Category updated successfully'
        ]);
    }

    /**
     * Delete a category
     */
    public function destroy(string $id): JsonResponse
    {
        $category = $this->repository->findById($id);
        
        if (!$category) {
            return response()->json([
                'error' => 'Category not found'
            ], Response::HTTP_NOT_FOUND);
        }

        // Check if category has children
        $children = $this->repository->findByParentId($id);
        if (count($children) > 0) {
            return response()->json([
                'error' => 'Cannot delete category with children'
            ], Response::HTTP_CONFLICT);
        }

        $this->repository->delete($id);

        return response()->json([
            'message' => 'Category deleted successfully'
        ]);
    }
}
