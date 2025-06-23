<?php

declare(strict_types=1);

namespace App\Learning\Infrastructure\Repository;

use App\Learning\Domain\Repository\ProgressRepositoryInterface;
use App\Learning\Domain\Progress;
use App\Learning\Domain\ValueObjects\ProgressId;
use App\Learning\Domain\ValueObjects\EnrollmentId;
use App\Learning\Domain\ValueObjects\LessonId;
use App\Learning\Domain\ValueObjects\ModuleId;
use App\Learning\Domain\ValueObjects\ProgressStatus;

class InMemoryProgressRepository implements ProgressRepositoryInterface
{
    /** @var array<string, Progress> */
    private array $progresses = [];
    
    /** @var array<string, string> Map lesson to module */
    private array $lessonToModule = [];
    
    public function save(Progress $progress): void
    {
        $this->progresses[$progress->getId()->toString()] = $progress;
    }
    
    public function findById(ProgressId $id): ?Progress
    {
        return $this->progresses[$id->toString()] ?? null;
    }
    
    public function findByEnrollmentAndLesson(EnrollmentId $enrollmentId, LessonId $lessonId): ?Progress
    {
        foreach ($this->progresses as $progress) {
            if ($progress->getEnrollmentId()->toString() === $enrollmentId->toString() &&
                $progress->getLessonId()->toString() === $lessonId->toString()) {
                return $progress;
            }
        }
        
        return null;
    }
    
    public function findByEnrollment(EnrollmentId $enrollmentId): array
    {
        return array_values(array_filter(
            $this->progresses,
            fn(Progress $progress) => $progress->getEnrollmentId()->toString() === $enrollmentId->toString()
        ));
    }
    
    public function findByEnrollmentAndModule(EnrollmentId $enrollmentId, ModuleId $moduleId): array
    {
        return array_values(array_filter(
            $this->progresses,
            function (Progress $progress) use ($enrollmentId, $moduleId) {
                if ($progress->getEnrollmentId()->toString() !== $enrollmentId->toString()) {
                    return false;
                }
                
                $lessonId = $progress->getLessonId()->toString();
                return isset($this->lessonToModule[$lessonId]) && 
                       $this->lessonToModule[$lessonId] === $moduleId->toString();
            }
        ));
    }
    
    public function findByLesson(LessonId $lessonId): array
    {
        return array_values(array_filter(
            $this->progresses,
            fn(Progress $progress) => $progress->getLessonId()->toString() === $lessonId->toString()
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
            $lessonId = $progress->getLessonId()->toString();
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
        unset($this->progresses[$progress->getId()->toString()]);
    }
    
    public function deleteByEnrollment(EnrollmentId $enrollmentId): void
    {
        foreach ($this->progresses as $id => $progress) {
            if ($progress->getEnrollmentId()->toString() === $enrollmentId->toString()) {
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
        $this->lessonToModule[$lessonId->toString()] = $moduleId->toString();
    }
} 