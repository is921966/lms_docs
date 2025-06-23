<?php

declare(strict_types=1);

namespace App\Learning\Application\Service;

use App\Common\Exceptions\BusinessLogicException;
use App\Common\Exceptions\NotFoundException;
use App\Learning\Application\DTO\ProgressDTO;
use App\Learning\Domain\Progress;
use App\Learning\Domain\Repository\ProgressRepositoryInterface;
use App\Learning\Domain\Repository\EnrollmentRepositoryInterface;
use App\Learning\Domain\ValueObjects\EnrollmentId;
use App\Learning\Domain\ValueObjects\EnrollmentStatus;
use App\Learning\Domain\ValueObjects\LessonId;
use App\Learning\Domain\ValueObjects\CourseId;
use App\User\Domain\ValueObjects\UserId;

class ProgressService
{
    public function __construct(
        private readonly ProgressRepositoryInterface $progressRepository,
        private readonly EnrollmentRepositoryInterface $enrollmentRepository
    ) {}
    
    public function startLesson(string $userId, string $courseId, string $lessonId): ProgressDTO
    {
        $userIdVO = UserId::fromString($userId);
        $courseIdVO = CourseId::fromString($courseId);
        $lessonIdVO = LessonId::fromString($lessonId);
        
        // Find enrollment
        $enrollment = $this->enrollmentRepository->findByUserAndCourse($userIdVO, $courseIdVO);
        if (!$enrollment) {
            throw new NotFoundException("Enrollment not found for user {$userId} and course {$courseId}");
        }
        
        // Check if enrollment is active
        if ($enrollment->getStatus() !== EnrollmentStatus::ACTIVE) {
            throw new BusinessLogicException("Enrollment is not active");
        }
        
        $enrollmentId = $enrollment->getId();
        
        // Check if progress already exists
        $existingProgress = $this->progressRepository->findByEnrollmentAndLesson($enrollmentId, $lessonIdVO);
        if ($existingProgress) {
            // Return existing progress
            return ProgressDTO::fromEntity($existingProgress);
        }
        
        // Create new progress
        $progress = Progress::create($enrollmentId, $lessonIdVO);
        $progress->start();
        
        $this->progressRepository->save($progress);
        
        return ProgressDTO::fromEntity($progress);
    }
    
    public function updateProgress(string $enrollmentId, string $lessonId, float $percentage): bool
    {
        $progress = $this->findProgress($enrollmentId, $lessonId);
        
        $progress->updatePercentage($percentage);
        $this->progressRepository->save($progress);
        
        return true;
    }
    
    public function completeLesson(string $enrollmentId, string $lessonId, float $score): bool
    {
        $progress = $this->findProgress($enrollmentId, $lessonId);
        
        $progress->recordScore($score);
        $progress->updatePercentage(100.0);
        $this->progressRepository->save($progress);
        
        return true;
    }
    
    public function recordScore(string $enrollmentId, string $lessonId, float $score): bool
    {
        $progress = $this->findProgress($enrollmentId, $lessonId);
        
        $progress->recordScore($score);
        $this->progressRepository->save($progress);
        
        return true;
    }
    
    public function failLesson(string $enrollmentId, string $lessonId): bool
    {
        $progress = $this->findProgress($enrollmentId, $lessonId);
        
        $progress->markAsFailed();
        $this->progressRepository->save($progress);
        
        return true;
    }
    
    public function retryLesson(string $enrollmentId, string $lessonId): ProgressDTO
    {
        $progress = $this->findProgress($enrollmentId, $lessonId);
        
        $progress->restart();
        $this->progressRepository->save($progress);
        
        return ProgressDTO::fromEntity($progress);
    }
    
    public function getEnrollmentProgress(string $enrollmentId): array
    {
        $enrollmentIdVO = EnrollmentId::fromString($enrollmentId);
        $progresses = $this->progressRepository->findByEnrollment($enrollmentIdVO);
        
        return array_map(
            fn(Progress $progress) => ProgressDTO::fromEntity($progress),
            $progresses
        );
    }
    
    public function getLessonProgress(string $lessonId): array
    {
        $lessonIdVO = LessonId::fromString($lessonId);
        $progresses = $this->progressRepository->findByLesson($lessonIdVO);
        
        return array_map(
            fn(Progress $progress) => ProgressDTO::fromEntity($progress),
            $progresses
        );
    }
    
    private function findProgress(string $enrollmentId, string $lessonId): Progress
    {
        $enrollmentIdVO = EnrollmentId::fromString($enrollmentId);
        $lessonIdVO = LessonId::fromString($lessonId);
        
        $progress = $this->progressRepository->findByEnrollmentAndLesson($enrollmentIdVO, $lessonIdVO);
        
        if (!$progress) {
            throw new NotFoundException("Progress not found for enrollment {$enrollmentId} and lesson {$lessonId}");
        }
        
        return $progress;
    }
} 