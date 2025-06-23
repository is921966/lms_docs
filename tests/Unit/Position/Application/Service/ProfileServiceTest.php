<?php

declare(strict_types=1);

namespace Tests\Unit\Position\Application\Service;

use App\Position\Application\Service\ProfileService;
use App\Position\Application\DTO\ProfileDTO;
use App\Position\Application\DTO\CreateProfileDTO;
use App\Position\Application\DTO\UpdateProfileDTO;
use App\Position\Application\DTO\CompetencyRequirementDTO;
use App\Position\Domain\Repository\PositionRepositoryInterface;
use App\Position\Domain\Repository\PositionProfileRepositoryInterface;
use App\Position\Domain\Position;
use App\Position\Domain\PositionProfile;
use App\Position\Domain\ValueObjects\PositionId;
use App\Position\Domain\ValueObjects\PositionCode;
use App\Position\Domain\ValueObjects\PositionLevel;
use App\Position\Domain\ValueObjects\Department;
use App\Competency\Domain\ValueObjects\CompetencyId;
use App\Competency\Domain\ValueObjects\CompetencyLevel;
use App\Common\Exceptions\NotFoundException;
use PHPUnit\Framework\TestCase;
use PHPUnit\Framework\MockObject\MockObject;

class ProfileServiceTest extends TestCase
{
    private ProfileService $service;
    private MockObject $positionRepository;
    private MockObject $profileRepository;
    
    protected function setUp(): void
    {
        $this->positionRepository = $this->createMock(PositionRepositoryInterface::class);
        $this->profileRepository = $this->createMock(PositionProfileRepositoryInterface::class);
        
        $this->service = new ProfileService(
            $this->positionRepository,
            $this->profileRepository
        );
    }
    
    public function testCreateProfile(): void
    {
        $positionId = PositionId::generate();
        $position = $this->createPosition($positionId);
        
        $createDTO = new CreateProfileDTO(
            positionId: $positionId->getValue(),
            responsibilities: ['Lead development team', 'Code reviews'],
            requirements: ['5+ years experience', 'Strong leadership skills']
        );
        
        $this->positionRepository
            ->expects($this->once())
            ->method('findById')
            ->with($positionId)
            ->willReturn($position);
            
        $this->profileRepository
            ->expects($this->once())
            ->method('findByPositionId')
            ->willReturn(null);
            
        $this->profileRepository
            ->expects($this->once())
            ->method('save');
            
        $result = $this->service->createProfile($createDTO);
        
        $this->assertInstanceOf(ProfileDTO::class, $result);
        $this->assertEquals($positionId->getValue(), $result->positionId);
        $this->assertCount(2, $result->responsibilities);
        $this->assertCount(2, $result->requirements);
    }
    
    public function testCannotCreateDuplicateProfile(): void
    {
        $positionId = PositionId::generate();
        $position = $this->createPosition($positionId);
        $existingProfile = PositionProfile::create(
            positionId: $positionId,
            responsibilities: [],
            requirements: []
        );
        
        $createDTO = new CreateProfileDTO(
            positionId: $positionId->getValue(),
            responsibilities: [],
            requirements: []
        );
        
        $this->positionRepository
            ->expects($this->once())
            ->method('findById')
            ->willReturn($position);
            
        $this->profileRepository
            ->expects($this->once())
            ->method('findByPositionId')
            ->willReturn($existingProfile);
            
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Profile already exists for this position');
        
        $this->service->createProfile($createDTO);
    }
    
    public function testUpdateProfile(): void
    {
        $positionId = PositionId::generate();
        $profile = PositionProfile::create(
            positionId: $positionId,
            responsibilities: ['Old responsibility'],
            requirements: ['Old requirement']
        );
        
        $updateDTO = new UpdateProfileDTO(
            responsibilities: ['New responsibility 1', 'New responsibility 2'],
            requirements: ['New requirement 1', 'New requirement 2']
        );
        
        $this->profileRepository
            ->expects($this->once())
            ->method('findByPositionId')
            ->with($positionId)
            ->willReturn($profile);
            
        $this->profileRepository
            ->expects($this->once())
            ->method('save');
            
        $result = $this->service->updateProfile($positionId->getValue(), $updateDTO);
        
        $this->assertCount(2, $result->responsibilities);
        $this->assertCount(2, $result->requirements);
        $this->assertContains('New responsibility 1', $result->responsibilities);
    }
    
    public function testAddRequiredCompetency(): void
    {
        $positionId = PositionId::generate();
        $profile = PositionProfile::create(
            positionId: $positionId,
            responsibilities: [],
            requirements: []
        );
        
        $requirementDTO = new CompetencyRequirementDTO(
            competencyId: CompetencyId::generate()->getValue(),
            minimumLevel: 3,
            isRequired: true
        );
        
        $this->profileRepository
            ->expects($this->once())
            ->method('findByPositionId')
            ->willReturn($profile);
            
        $this->profileRepository
            ->expects($this->once())
            ->method('save');
            
        $this->service->addCompetencyRequirement($positionId->getValue(), $requirementDTO);
        
        $this->assertCount(1, $profile->getRequiredCompetencies());
    }
    
    public function testRemoveCompetencyRequirement(): void
    {
        $positionId = PositionId::generate();
        $competencyId = CompetencyId::generate();
        
        $profile = PositionProfile::create(
            positionId: $positionId,
            responsibilities: [],
            requirements: []
        );
        $profile->addRequiredCompetency($competencyId, CompetencyLevel::intermediate());
        
        $this->profileRepository
            ->expects($this->once())
            ->method('findByPositionId')
            ->willReturn($profile);
            
        $this->profileRepository
            ->expects($this->once())
            ->method('save');
            
        $this->service->removeCompetencyRequirement(
            $positionId->getValue(),
            $competencyId->getValue()
        );
        
        $this->assertCount(0, $profile->getRequiredCompetencies());
    }
    
    public function testGetProfileByPositionId(): void
    {
        $positionId = PositionId::generate();
        $profile = PositionProfile::create(
            positionId: $positionId,
            responsibilities: ['Test responsibility'],
            requirements: ['Test requirement']
        );
        
        $this->profileRepository
            ->expects($this->once())
            ->method('findByPositionId')
            ->willReturn($profile);
            
        $result = $this->service->getByPositionId($positionId->getValue());
        
        $this->assertInstanceOf(ProfileDTO::class, $result);
        $this->assertEquals($positionId->getValue(), $result->positionId);
    }
    
    public function testGetProfileNotFound(): void
    {
        $positionId = PositionId::generate();
        
        $this->profileRepository
            ->expects($this->once())
            ->method('findByPositionId')
            ->willReturn(null);
            
        $this->expectException(NotFoundException::class);
        
        $this->service->getByPositionId($positionId->getValue());
    }
    
    private function createPosition(PositionId $id): Position
    {
        return Position::create(
            id: $id,
            code: PositionCode::fromString('DEV-001'),
            title: 'Developer',
            department: Department::fromString('IT'),
            level: PositionLevel::fromValue(2),
            description: 'Developer position'
        );
    }
} 