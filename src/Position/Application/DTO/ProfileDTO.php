<?php

declare(strict_types=1);

namespace App\Position\Application\DTO;

use App\Position\Domain\PositionProfile;
use App\Position\Domain\ValueObjects\RequiredCompetency;

final class ProfileDTO
{
    public function __construct(
        public readonly string $positionId,
        public readonly array $responsibilities,
        public readonly array $requirements,
        public readonly array $requiredCompetencies,
        public readonly array $desiredCompetencies,
        public readonly \DateTimeImmutable $createdAt,
        public readonly \DateTimeImmutable $updatedAt
    ) {
    }
    
    public static function fromDomain(PositionProfile $profile): self
    {
        return new self(
            positionId: $profile->getPositionId()->getValue(),
            responsibilities: $profile->getResponsibilities(),
            requirements: $profile->getRequirements(),
            requiredCompetencies: array_map(
                fn(RequiredCompetency $req) => [
                    'competencyId' => $req->getCompetencyId()->getValue(),
                    'minimumLevel' => $req->getMinimumLevel()->getValue(),
                    'isRequired' => $req->isRequired()
                ],
                $profile->getRequiredCompetencies()
            ),
            desiredCompetencies: array_map(
                fn(RequiredCompetency $req) => [
                    'competencyId' => $req->getCompetencyId()->getValue(),
                    'minimumLevel' => $req->getMinimumLevel()->getValue(),
                    'isRequired' => $req->isRequired()
                ],
                $profile->getDesiredCompetencies()
            ),
            createdAt: $profile->getCreatedAt(),
            updatedAt: $profile->getUpdatedAt()
        );
    }
    
    public function toArray(): array
    {
        return [
            'positionId' => $this->positionId,
            'responsibilities' => $this->responsibilities,
            'requirements' => $this->requirements,
            'requiredCompetencies' => $this->requiredCompetencies,
            'desiredCompetencies' => $this->desiredCompetencies,
            'createdAt' => $this->createdAt->format('c'),
            'updatedAt' => $this->updatedAt->format('c')
        ];
    }
}
