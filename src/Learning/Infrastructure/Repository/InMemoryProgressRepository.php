<?php

declare(strict_types=1);

namespace Learning\Infrastructure\Repository;

use Learning\Domain\Repository\ProgressRepositoryInterface;
use Learning\Domain\Progress;
use Learning\Domain\ValueObjects\ProgressId;
use Learning\Domain\ValueObjects\EnrollmentId;
use Learning\Domain\ValueObjects\LessonId;
use Learning\Domain\ValueObjects\ModuleId;
use Learning\Domain\ValueObjects\ProgressStatus;

class InMemoryProgressRepository implements ProgressRepositoryInterface
{
    /** @var array<string, Progress> */
    private array $progresses = [];
    
    /** @var array<string, string> Map lesson to module */
    private array $lessonToModule = [];
    
    public function save(Progress $progress): void
    {
        $this->progresses[$progress->getId()->getValue()] = $progress;
    }
    
    public function findById(ProgressId $id): ?Progress
    {
        return $this->progresses[$id->getValue()] ?? null;
    }
    
    public function findByEnrollmentAndLesson(EnrollmentId $enrollmentId, LessonId $lessonId): ?Progress
    {
        foreach ($this->progresses as $progress) {
            if ($progress->getEnrollmentId()->getValue() === $enrollmentId->getValue() &&
                $progress->getLessonId()->getValue() === $lessonId->getValue()) {
                return $progress;
            }
        }
        
        return null;
    }
    
    public function findByEnrollment(EnrollmentId $enrollmentId): array
    {
        return array_values(array_filter(
            $this->progresses,
            fn(Progress $progress) => $progress->getEnrollmentId()->getValue() === $enrollmentId->getValue()
        ));
    }
    
    public function findByEnrollmentAndModule(EnrollmentId $enrollmentId, ModuleId $moduleId): array
    {
        return array_values(array_filter(
            $this->progresses,
            function (Progress $progress) use ($enrollmentId, $moduleId) {
                if ($progress->getEnrollmentId()->getValue() !== $enrollmentId->getValue()) {
                    return false;
                }
                
                $lessonId = $progress->getLessonId()->getValue();
                return isset($this->lessonToModule[$lessonId]) && 
                       $this->lessonToModule[$lessonId] === $moduleId->getValue();
            }
        ));
    }
    
    public function findByLesson(LessonId $lessonId): array
    {
        return array_values(array_filter(
            $this->progresses,
            fn(Progress $progress) => $progress->getLessonId()->getValue() === $lessonId->getValue()
        ));
    }
    
    public function findByStatus(ProgressStatus $status): array
    {
        return array_values(array_filter(
            $this->progresses,
            fn(Progress $progress) => $progress->getStatus()->value === $status->value
        ));
    }
    
    public function calculateEnrollmentProgress(EnrollmentId $enrollmentId): float
    {
        $progresses = $this->findByEnrollment($enrollmentId);
        
        if (empty($progresses)) {
            return 0.0;
        }
        
        $totalPercentage = array_reduce(
            $progresses,
            fn(float $sum, Progress $progress) => $sum + $progress->getPercentage(),
            0.0
        );
        
        return $totalPercentage / count($progresses);
    }
    
    public function calculateModuleProgress(EnrollmentId $enrollmentId, ModuleId $moduleId): float
    {
        $progresses = $this->findByEnrollmentAndModule($enrollmentId, $moduleId);
        
        if (empty($progresses)) {
            return 0.0;
        }
        
        $totalPercentage = array_reduce(
            $progresses,
            fn(float $sum, Progress $progress) => $sum + $progress->getPercentage(),
            0.0
        );
        
        return $totalPercentage / count($progresses);
    }
    
    public function getTotalTimeSpent(EnrollmentId $enrollmentId): int
    {
        $progresses = $this->findByEnrollment($enrollmentId);
        
        return array_reduce(
            $progresses,
            fn(int $sum, Progress $progress) => $sum + $progress->getTimeSpentMinutes(),
            0
        );
    }
    
    public function getHighestScores(EnrollmentId $enrollmentId): array
    {
        $progresses = $this->findByEnrollment($enrollmentId);
        $scores = [];
        
        foreach ($progresses as $progress) {
            $lessonId = $progress->getLessonId()->getValue();
            $score = $progress->getHighestScore();
            
            if ($score !== null) {
                $scores[$lessonId] = $score;
            }
        }
        
        return $scores;
    }
    
    public function countByEnrollment(EnrollmentId $enrollmentId): int
    {
        return count($this->findByEnrollment($enrollmentId));
    }
    
    public function delete(Progress $progress): void
    {
        unset($this->progresses[$progress->getId()->getValue()]);
    }
    
    public function deleteByEnrollment(EnrollmentId $enrollmentId): void
    {
        foreach ($this->progresses as $id => $progress) {
            if ($progress->getEnrollmentId()->getValue() === $enrollmentId->getValue()) {
                unset($this->progresses[$id]);
            }
        }
    }
    
    public function getNextId(): ProgressId
    {
        return ProgressId::generate();
    }
    
    // Helper method for testing
    public function setLessonModule(LessonId $lessonId, ModuleId $moduleId): void
    {
        $this->lessonToModule[$lessonId->getValue()] = $moduleId->getValue();
    }
} 