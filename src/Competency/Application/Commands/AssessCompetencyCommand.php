<?php

namespace Competency\Application\Commands;

use InvalidArgumentException;

class AssessCompetencyCommand
{
    private string $userId;
    private string $competencyId;
    private int $level;
    private string $assessorId;
    private ?string $comment;

    public function __construct(
        string $userId,
        string $competencyId,
        int $level,
        string $assessorId,
        ?string $comment = null
    ) {
        if (empty($userId)) {
            throw new InvalidArgumentException('User ID cannot be empty');
        }

        if (empty($competencyId)) {
            throw new InvalidArgumentException('Competency ID cannot be empty');
        }

        if ($level < 1 || $level > 5) {
            throw new InvalidArgumentException('Assessment level must be between 1 and 5');
        }

        if (empty($assessorId)) {
            throw new InvalidArgumentException('Assessor ID cannot be empty');
        }

        $this->userId = $userId;
        $this->competencyId = $competencyId;
        $this->level = $level;
        $this->assessorId = $assessorId;
        $this->comment = $comment;
    }

    public function getUserId(): string
    {
        return $this->userId;
    }

    public function getCompetencyId(): string
    {
        return $this->competencyId;
    }

    public function getLevel(): int
    {
        return $this->level;
    }

    public function getAssessorId(): string
    {
        return $this->assessorId;
    }

    public function getComment(): ?string
    {
        return $this->comment;
    }

    public function isSelfAssessment(): bool
    {
        return $this->userId === $this->assessorId;
    }

    public function toArray(): array
    {
        return [
            'userId' => $this->userId,
            'competencyId' => $this->competencyId,
            'level' => $this->level,
            'assessorId' => $this->assessorId,
            'comment' => $this->comment,
            'isSelfAssessment' => $this->isSelfAssessment()
        ];
    }
} 