<?php

declare(strict_types=1);

namespace Competency\Application\Handlers;

use Competency\Application\Commands\AssessCompetencyCommand;
use Competency\Domain\Repository\CompetencyRepositoryInterface;
use Competency\Domain\Repository\AssessmentRepositoryInterface;
use Competency\Domain\Repository\UserCompetencyRepositoryInterface;
use Competency\Domain\CompetencyAssessment;
use Competency\Domain\ValueObjects\CompetencyId;
use Competency\Domain\ValueObjects\CompetencyLevel;
use Competency\Domain\ValueObjects\AssessmentScore;
use User\Domain\ValueObjects\UserId;

class AssessCompetencyHandler
{
    public function __construct(
        private CompetencyRepositoryInterface $competencyRepository,
        private AssessmentRepositoryInterface $assessmentRepository,
        private UserCompetencyRepositoryInterface $userCompetencyRepository
    ) {}

    public function handle(AssessCompetencyCommand $command): string
    {
        // Validate competency exists
        $competency = $this->competencyRepository->findById($command->competencyId);
        if (!$competency) {
            throw new \DomainException('Competency not found');
        }

        // Create assessment
        $assessment = CompetencyAssessment::create(
            id: null, // Will be generated in factory method
            competencyId: CompetencyId::fromString($command->competencyId),
            userId: UserId::fromString($command->userId),
            assessorId: UserId::fromString($command->assessorId),
            level: CompetencyLevel::fromValue($command->level),
            score: AssessmentScore::fromValue($command->level * 20), // Convert 1-5 to 0-100
            comment: $command->comment
        );

        // Save assessment
        $this->assessmentRepository->save($assessment);

        // Update user competency level
        $userCompetency = $this->userCompetencyRepository->findByUserAndCompetency(
            UserId::fromString($command->userId),
            CompetencyId::fromString($command->competencyId)
        );

        if ($userCompetency) {
            $userCompetency->updateCurrentLevel(CompetencyLevel::fromValue($command->level));
            $this->userCompetencyRepository->save($userCompetency);
        }

        // Pull and dispatch domain events
        $events = $assessment->pullDomainEvents();
        // TODO: Dispatch events to event bus

        return $assessment->getId();
    }
} 