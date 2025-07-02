<?php

namespace Competency\Domain\Repositories;

interface CompetencyCategoryRepositoryInterface
{
    /**
     * Save category data
     * @param array{id: string, name: string, description?: string, is_active?: bool} $category
     */
    public function save(array $category): void;
    
    /**
     * Find category by ID
     * @return object{id: string, name: string, description?: string, is_active?: bool}|null
     */
    public function findById(string $id): ?object;
    
    /**
     * Find category by name
     * @return object{id: string, name: string, description?: string, is_active?: bool}|null
     */
    public function findByName(string $name): ?object;
    
    /**
     * Get all categories
     * @return array<object{id: string, name: string, description?: string, is_active?: bool}>
     */
    public function findAll(): array;
    
    /**
     * Get active categories
     * @return array<object{id: string, name: string, description?: string, is_active?: bool}>
     */
    public function findActive(): array;
    
    /**
     * Delete category by ID
     */
    public function delete(string $id): void;
} 