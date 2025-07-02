<?php

declare(strict_types=1);

namespace Learning\Domain\Repository;

use Learning\Domain\Certificate;
use Learning\Domain\ValueObjects\CertificateId;
use Learning\Domain\ValueObjects\CertificateNumber;
use Learning\Domain\ValueObjects\CourseId;
use Learning\Domain\ValueObjects\EnrollmentId;
use User\Domain\ValueObjects\UserId;

interface CertificateRepositoryInterface
{
    /**
     * Find certificate by ID
     */
    public function findById(CertificateId $id): ?Certificate;
    
    /**
     * Find certificate by number
     */
    public function findByNumber(CertificateNumber $number): ?Certificate;
    
    /**
     * Find certificate by enrollment
     */
    public function findByEnrollment(EnrollmentId $enrollmentId): ?Certificate;
    
    /**
     * Find all certificates for user
     * @return Certificate[]
     */
    public function findByUser(UserId $userId, bool $validOnly = false): array;
    
    /**
     * Find all certificates for course
     * @return Certificate[]
     */
    public function findByCourse(CourseId $courseId, bool $validOnly = false): array;
    
    /**
     * Find certificates expiring soon
     * @return Certificate[]
     */
    public function findExpiringSoon(\DateTimeImmutable $beforeDate): array;
    
    /**
     * Get next certificate number for year
     */
    public function getNextCertificateNumber(int $year): CertificateNumber;
    
    /**
     * Check if certificate number exists
     */
    public function numberExists(CertificateNumber $number): bool;
    
    /**
     * Count valid certificates for user
     */
    public function countValidByUser(UserId $userId): int;
    
    /**
     * Save certificate
     */
    public function save(Certificate $certificate): void;
    
    /**
     * Delete certificate
     */
    public function delete(Certificate $certificate): void;
} 