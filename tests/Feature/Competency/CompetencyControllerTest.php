<?php

declare(strict_types=1);

namespace Tests\Feature\Competency;

use Competency\Domain\Competency;
use Competency\Domain\ValueObjects\CompetencyCategory;
use Competency\Infrastructure\Repositories\InMemoryCompetencyRepository;
use Competency\Infrastructure\Repositories\InMemoryCompetencyCategoryRepository;
use Tests\FeatureTestCase;
use Illuminate\Foundation\Testing\RefreshDatabase;

class CompetencyControllerTest extends FeatureTestCase
{
    use RefreshDatabase;

    private InMemoryCompetencyRepository $competencyRepository;
    private InMemoryCompetencyCategoryRepository $categoryRepository;

    protected function setUp(): void
    {
        parent::setUp();
        
        $this->competencyRepository = new InMemoryCompetencyRepository();
        $this->categoryRepository = new InMemoryCompetencyCategoryRepository();
        
        // Bind repositories to container
        $this->app->instance('Competency\Domain\Repositories\CompetencyRepositoryInterface', $this->competencyRepository);
        $this->app->instance('Competency\Domain\Repositories\CompetencyCategoryRepositoryInterface', $this->categoryRepository);
    }

    public function testListCompetencies(): void
    {
        // Arrange
        $category = $this->createCategory();
        $competency1 = $this->createCompetency('PHP Development', $category);
        $competency2 = $this->createCompetency('JavaScript Development', $category);
        
        // Act
        $response = $this->getJson('/api/v1/competencies');
        
        // Assert
        $response->assertOk()
            ->assertJsonStructure([
                'data' => [
                    '*' => ['id', 'name', 'description', 'category_id']
                ],
                'meta' => ['total']
            ])
            ->assertJsonCount(2, 'data');
    }

    public function testListCompetenciesByCategory(): void
    {
        // Arrange
        $category1 = $this->createCategory('Technical');
        $category2 = $this->createCategory('Soft Skills');
        
        $this->createCompetency('PHP', $category1);
        $this->createCompetency('JavaScript', $category1);
        $this->createCompetency('Communication', $category2);
        
        // Act
        $response = $this->getJson('/api/v1/competencies?category_id=' . $category1->getId()->getValue());
        
        // Assert
        $response->assertOk()
            ->assertJsonCount(2, 'data');
    }

    public function testCreateCompetency(): void
    {
        // Arrange
        $category = $this->createCategory();
        $this->actingAsAdmin();
        
        $data = [
            'name' => 'New Competency',
            'description' => 'Description of the new competency',
            'category_id' => $category->getId()->getValue()
        ];
        
        // Act
        $response = $this->postJson('/api/v1/competencies', $data);
        
        // Assert
        $response->assertCreated()
            ->assertJsonStructure([
                'data' => ['id', 'name', 'description'],
                'message'
            ])
            ->assertJson([
                'message' => 'Competency created successfully'
            ]);
            
        $this->assertCount(1, $this->competencyRepository->findAll());
    }

    public function testCreateCompetencyWithInvalidData(): void
    {
        // Arrange
        $this->actingAsAdmin();
        
        $data = [
            'name' => 'N', // Too short
            'description' => 'Short', // Too short
            'category_id' => 'invalid-uuid'
        ];
        
        // Act
        $response = $this->postJson('/api/v1/competencies', $data);
        
        // Assert
        $response->assertUnprocessable()
            ->assertJsonValidationErrors(['name', 'description', 'category_id']);
    }

    public function testShowCompetency(): void
    {
        // Arrange
        $category = $this->createCategory();
        $competency = $this->createCompetency('Test Competency', $category);
        
        // Act
        $response = $this->getJson('/api/v1/competencies/' . $competency->getId()->getValue());
        
        // Assert
        $response->assertOk()
            ->assertJsonStructure([
                'data' => ['id', 'name', 'description', 'category_id']
            ])
            ->assertJsonPath('data.name', 'Test Competency');
    }

    public function testShowNonExistentCompetency(): void
    {
        // Act
        $response = $this->getJson('/api/v1/competencies/non-existent-id');
        
        // Assert
        $response->assertNotFound()
            ->assertJson(['error' => 'Competency not found']);
    }

    public function testUpdateCompetency(): void
    {
        // Arrange
        $category = $this->createCategory();
        $competency = $this->createCompetency('Old Name', $category);
        $this->actingAsAdmin();
        
        $data = [
            'name' => 'Updated Name',
            'description' => 'Updated description'
        ];
        
        // Act
        $response = $this->putJson('/api/v1/competencies/' . $competency->getId()->getValue(), $data);
        
        // Assert
        $response->assertOk()
            ->assertJsonPath('data.name', 'Updated Name')
            ->assertJsonPath('message', 'Competency updated successfully');
    }

    public function testDeleteCompetency(): void
    {
        // Arrange
        $category = $this->createCategory();
        $competency = $this->createCompetency('To Delete', $category);
        $this->actingAsAdmin();
        
        // Act
        $response = $this->deleteJson('/api/v1/competencies/' . $competency->getId()->getValue());
        
        // Assert
        $response->assertOk()
            ->assertJson(['message' => 'Competency deleted successfully']);
            
        $this->assertNull($this->competencyRepository->findById($competency->getId()->getValue()));
    }

    private function createCategory(string $name = 'Test Category'): CompetencyCategory
    {
        $category = CompetencyCategory::create($name, 'Test Description');
        $this->categoryRepository->save($category);
        return $category;
    }

    private function createCompetency(string $name, CompetencyCategory $category): Competency
    {
        $competency = Competency::create($name, 'Test Description', $category);
        $this->competencyRepository->save($competency);
        return $competency;
    }

    private function actingAsAdmin(): void
    {
        // Mock admin user with permissions
        $user = new \stdClass();
        $user->id = 'admin-user-id';
        $user->can = fn($permission) => true;
        
        $this->actingAs($user);
    }
}
