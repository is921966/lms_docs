<?php

declare(strict_types=1);

namespace App\Learning\Application\Service;

use App\Common\Exceptions\BusinessLogicException;
use App\Common\Exceptions\NotFoundException;
use App\Learning\Application\DTO\CertificateDTO;
use App\Learning\Domain\Certificate;
use App\Learning\Domain\Repository\CertificateRepositoryInterface;
use App\Learning\Domain\Repository\EnrollmentRepositoryInterface;
use App\Learning\Domain\Repository\CourseRepositoryInterface;
use App\Learning\Domain\ValueObjects\CertificateId;
use App\Learning\Domain\ValueObjects\CertificateNumber;
use App\Learning\Domain\ValueObjects\CourseId;
use App\Learning\Domain\ValueObjects\EnrollmentStatus;
use App\User\Domain\ValueObjects\UserId;

class CertificateService
{
    public function __construct(
        private readonly CertificateRepositoryInterface $certificateRepository,
        private readonly EnrollmentRepositoryInterface $enrollmentRepository,
        private readonly CourseRepositoryInterface $courseRepository
    ) {}
    
    public function issue(string $userId, string $courseId, string $templateCode = 'default'): CertificateDTO
    {
        $userIdVO = UserId::fromString($userId);
        $courseIdVO = CourseId::fromString($courseId);
        
        // Find enrollment
        $enrollment = $this->enrollmentRepository->findByUserAndCourse($userIdVO, $courseIdVO);
        if (!$enrollment) {
            throw new NotFoundException("Enrollment not found for user {$userId} and course {$courseId}");
        }
        
        // Check if enrollment is completed
        if ($enrollment->getStatus() !== EnrollmentStatus::COMPLETED) {
            throw new BusinessLogicException("Enrollment is not completed");
        }
        
        // Find course
        $course = $this->courseRepository->findById($courseIdVO);
        if (!$course) {
            throw new NotFoundException("Course with ID {$courseId} not found");
        }
        
        // Check if certificate already exists
        $existingCertificate = $this->certificateRepository->findByEnrollment($enrollment->getId());
        if ($existingCertificate) {
            return CertificateDTO::fromEntity($existingCertificate);
        }
        
        // Generate certificate number
        $year = (int) date('Y');
        $certificateNumber = $this->certificateRepository->getNextCertificateNumber($year);
        
        // Create certificate
        $certificate = Certificate::create(
            userId: $userIdVO,
            courseId: $courseIdVO,
            enrollmentId: $enrollment->getId(),
            certificateNumber: $certificateNumber,
            courseName: $course->getTitle(),
            completionDate: $enrollment->getCompletedAt() ?? new \DateTimeImmutable(),
            score: $enrollment->getCompletionScore() ?? 0.0
        );
        
        // Set additional data
        $certificate->setUserName($userId); // In real app, fetch from User service
        $certificate->setTemplateData([
            'userName' => $userId,
            'courseName' => $course->getTitle(),
            'completionDate' => $certificate->getCompletionDate()->format('Y-m-d'),
            'score' => $certificate->getScore(),
            'certificateNumber' => $certificateNumber->getValue()
        ]);
        
        $this->certificateRepository->save($certificate);
        
        return CertificateDTO::fromEntity($certificate);
    }
    
    public function verify(string $certificateNumber): CertificateDTO
    {
        // Parse certificate number to create object
        if (!preg_match('/^CERT-(\d{4})-(\d{5})$/', $certificateNumber, $matches)) {
            throw new \InvalidArgumentException("Invalid certificate number format");
        }
        
        $year = (int) $matches[1];
        $sequence = (int) $matches[2];
        $certificateNumberVO = CertificateNumber::generate($year, $sequence);
        
        $certificate = $this->certificateRepository->findByNumber($certificateNumberVO);
        
        if (!$certificate) {
            throw new NotFoundException("Certificate not found");
        }
        
        return CertificateDTO::fromEntity($certificate);
    }
    
    public function revoke(string $certificateId, string $reason): bool
    {
        $certificateIdVO = CertificateId::fromString($certificateId);
        $certificate = $this->certificateRepository->findById($certificateIdVO);
        
        if (!$certificate) {
            throw new NotFoundException("Certificate with ID {$certificateId} not found");
        }
        
        $certificate->revoke($reason);
        $this->certificateRepository->save($certificate);
        
        return true;
    }
    
    public function reinstate(string $certificateId): bool
    {
        $certificateIdVO = CertificateId::fromString($certificateId);
        $certificate = $this->certificateRepository->findById($certificateIdVO);
        
        if (!$certificate) {
            throw new NotFoundException("Certificate with ID {$certificateId} not found");
        }
        
        $certificate->reinstate();
        $this->certificateRepository->save($certificate);
        
        return true;
    }
    
    public function findUserCertificates(string $userId): array
    {
        $userIdVO = UserId::fromString($userId);
        $certificates = $this->certificateRepository->findByUser($userIdVO);
        
        return array_map(
            fn(Certificate $certificate) => CertificateDTO::fromEntity($certificate),
            $certificates
        );
    }
    
    public function findCourseCertificates(string $courseId): array
    {
        $courseIdVO = CourseId::fromString($courseId);
        $certificates = $this->certificateRepository->findByCourse($courseIdVO);
        
        return array_map(
            fn(Certificate $certificate) => CertificateDTO::fromEntity($certificate),
            $certificates
        );
    }
    
    public function getStatistics(string $userId): array
    {
        $userIdVO = UserId::fromString($userId);
        
        return [
            'total' => count($this->certificateRepository->findByUser($userIdVO)),
            'valid' => $this->certificateRepository->countValidByUser($userIdVO)
        ];
    }
} 