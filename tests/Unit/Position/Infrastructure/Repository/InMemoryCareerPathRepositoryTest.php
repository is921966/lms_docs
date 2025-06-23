<?php

declare(strict_types=1);

namespace Tests\Unit\Position\Infrastructure\Repository;

use App\Position\Infrastructure\Repository\InMemoryCareerPathRepository;
use App\Position\Domain\CareerPath;
use App\Position\Domain\ValueObjects\PositionId;
use PHPUnit\Framework\TestCase;
use Ramsey\Uuid\Uuid;

class InMemoryCareerPathRepositoryTest extends TestCase
{
    private InMemoryCareerPathRepository $repository;
    
    protected function setUp(): void
    {
        $this->repository = new InMemoryCareerPathRepository();
    }
    
    public function testSaveAndFindById(): void
    {
        $careerPath = $this->createCareerPath();
        $id = Uuid::uuid4()->toString();
        
        $this->repository->save($careerPath, $id);
        
        $found = $this->repository->findById($id);
        
        $this->assertNotNull($found);
        $this->assertTrue($careerPath->getFromPositionId()->equals($found->getFromPositionId()));
        $this->assertTrue($careerPath->getToPositionId()->equals($found->getToPositionId()));
    }
    
    public function testFindByIdReturnsNullWhenNotFound(): void
    {
        $result = $this->repository->findById(Uuid::uuid4()->toString());
        
        $this->assertNull($result);
    }
    
    public function testFindPath(): void
    {
        $fromId = PositionId::generate();
        $toId = PositionId::generate();
        
        $careerPath = CareerPath::create(
            fromPositionId: $fromId,
            toPositionId: $toId,
            requirements: [],
            estimatedDuration: 12
        );
        
        $this->repository->save($careerPath, Uuid::uuid4()->toString());
        
        $found = $this->repository->findPath($fromId, $toId);
        
        $this->assertNotNull($found);
        $this->assertTrue($found->getFromPositionId()->equals($fromId));
        $this->assertTrue($found->getToPositionId()->equals($toId));
    }
    
    public function testFindByFromPosition(): void
    {
        $fromId = PositionId::generate();
        
        $path1 = CareerPath::create($fromId, PositionId::generate(), [], 12);
        $path2 = CareerPath::create($fromId, PositionId::generate(), [], 24);
        $path3 = CareerPath::create(PositionId::generate(), PositionId::generate(), [], 18);
        
        $this->repository->save($path1, Uuid::uuid4()->toString());
        $this->repository->save($path2, Uuid::uuid4()->toString());
        $this->repository->save($path3, Uuid::uuid4()->toString());
        
        $results = $this->repository->findByFromPosition($fromId);
        
        $this->assertCount(2, $results);
        $this->assertContains($path1, $results);
        $this->assertContains($path2, $results);
        $this->assertNotContains($path3, $results);
    }
    
    public function testFindByToPosition(): void
    {
        $toId = PositionId::generate();
        
        $path1 = CareerPath::create(PositionId::generate(), $toId, [], 12);
        $path2 = CareerPath::create(PositionId::generate(), $toId, [], 24);
        $path3 = CareerPath::create(PositionId::generate(), PositionId::generate(), [], 18);
        
        $this->repository->save($path1, Uuid::uuid4()->toString());
        $this->repository->save($path2, Uuid::uuid4()->toString());
        $this->repository->save($path3, Uuid::uuid4()->toString());
        
        $results = $this->repository->findByToPosition($toId);
        
        $this->assertCount(2, $results);
        $this->assertContains($path1, $results);
        $this->assertContains($path2, $results);
        $this->assertNotContains($path3, $results);
    }
    
    public function testFindActive(): void
    {
        $path1 = $this->createCareerPath();
        $path2 = $this->createCareerPath();
        $path3 = $this->createCareerPath();
        $path3->deactivate();
        
        $this->repository->save($path1, Uuid::uuid4()->toString());
        $this->repository->save($path2, Uuid::uuid4()->toString());
        $this->repository->save($path3, Uuid::uuid4()->toString());
        
        $results = $this->repository->findActive();
        
        $this->assertCount(2, $results);
        $this->assertContains($path1, $results);
        $this->assertContains($path2, $results);
        $this->assertNotContains($path3, $results);
    }
    
    public function testDelete(): void
    {
        $careerPath = $this->createCareerPath();
        $id = Uuid::uuid4()->toString();
        
        $this->repository->save($careerPath, $id);
        $this->assertNotNull($this->repository->findById($id));
        
        $this->repository->delete($id);
        $this->assertNull($this->repository->findById($id));
    }
    
    public function testExists(): void
    {
        $careerPath = $this->createCareerPath();
        $id = Uuid::uuid4()->toString();
        
        $this->repository->save($careerPath, $id);
        
        $this->assertTrue($this->repository->exists($id));
        $this->assertFalse($this->repository->exists(Uuid::uuid4()->toString()));
    }
    
    public function testExistsPath(): void
    {
        $fromId = PositionId::generate();
        $toId = PositionId::generate();
        
        $careerPath = CareerPath::create($fromId, $toId, [], 12);
        $this->repository->save($careerPath, Uuid::uuid4()->toString());
        
        $this->assertTrue($this->repository->existsPath($fromId, $toId));
        $this->assertFalse($this->repository->existsPath(PositionId::generate(), PositionId::generate()));
    }
    
    private function createCareerPath(): CareerPath
    {
        return CareerPath::create(
            fromPositionId: PositionId::generate(),
            toPositionId: PositionId::generate(),
            requirements: ['Test requirement 1', 'Test requirement 2'],
            estimatedDuration: 12
        );
    }
} 