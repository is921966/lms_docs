<?php

declare(strict_types=1);

namespace Learning\Infrastructure\Repository;

use Learning\Domain\Repository\CertificateRepositoryInterface;
use Learning\Domain\Certificate;
use Learning\Domain\ValueObjects\CertificateId;
use Learning\Domain\ValueObjects\CertificateNumber;
use Learning\Domain\ValueObjects\CourseId;
use Learning\Domain\ValueObjects\EnrollmentId;
use User\Domain\ValueObjects\UserId;

class InMemoryCertificateRepository implements CertificateRepositoryInterface
{
    /** @var array<string, Certificate> */
    private array $certificates = [];
    
    public function save(Certificate $certificate): void
    {
        $this->certificates[$certificate->getId()->getValue()] = $certificate;
    }
    
    public function findById(CertificateId $id): ?Certificate
    {
        return $this->certificates[$id->getValue()] ?? null;
    }
    
    public function findByNumber(CertificateNumber $number): ?Certificate
    {
        foreach ($this->certificates as $certificate) {
            if ($certificate->getCertificateNumber()->getValue() === $number->getValue()) {
                return $certificate;
            }
        }
        
        return null;
    }
    
    public function findByEnrollment(EnrollmentId $enrollmentId): ?Certificate
    {
        foreach ($this->certificates as $certificate) {
            if ($certificate->getEnrollmentId()->getValue() === $enrollmentId->getValue()) {
                return $certificate;
            }
        }
        
        return null;
    }
    
    public function findByUser(UserId $userId, bool $validOnly = false): array
    {
        $certificates = array_filter(
            $this->certificates,
            fn(Certificate $certificate) => $certificate->getUserId()->getValue() === $userId->getValue()
        );
        
        if ($validOnly) {
            $certificates = array_filter(
                $certificates,
                fn(Certificate $certificate) => $certificate->isValid()
            );
        }
        
        return array_values($certificates);
    }
    
    public function findByCourse(CourseId $courseId, bool $validOnly = false): array
    {
        $certificates = array_filter(
            $this->certificates,
            fn(Certificate $certificate) => $certificate->getCourseId()->getValue() === $courseId->getValue()
        );
        
        if ($validOnly) {
            $certificates = array_filter(
                $certificates,
                fn(Certificate $certificate) => $certificate->isValid()
            );
        }
        
        return array_values($certificates);
    }
    
    public function findExpiringSoon(\DateTimeImmutable $beforeDate): array
    {
        $now = new \DateTimeImmutable();
        
        return array_values(array_filter(
            $this->certificates,
            function (Certificate $certificate) use ($now, $beforeDate) {
                $expiryDate = $certificate->getExpiryDate();
                return $expiryDate !== null && 
                       $expiryDate > $now && 
                       $expiryDate <= $beforeDate &&
                       $certificate->isValid();
            }
        ));
    }
    
    public function getNextCertificateNumber(int $year): CertificateNumber
    {
        $maxNumber = 0;
        
        foreach ($this->certificates as $certificate) {
            $number = $certificate->getCertificateNumber()->getValue();
            if (preg_match("/CERT-{$year}-(\d+)/", $number, $matches)) {
                $num = (int) $matches[1];
                if ($num > $maxNumber) {
                    $maxNumber = $num;
                }
            }
        }
        
        return CertificateNumber::generate($year, $maxNumber + 1);
    }
    
    public function numberExists(CertificateNumber $number): bool
    {
        return $this->findByNumber($number) !== null;
    }
    
    public function countValidByUser(UserId $userId): int
    {
        return count($this->findByUser($userId, true));
    }
    
    public function delete(Certificate $certificate): void
    {
        unset($this->certificates[$certificate->getId()->getValue()]);
    }
} 