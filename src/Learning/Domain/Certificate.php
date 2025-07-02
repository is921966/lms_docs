<?php

declare(strict_types=1);

namespace Learning\Domain;

use Learning\Domain\ValueObjects\CertificateId;
use Learning\Domain\ValueObjects\CertificateNumber;
use Learning\Domain\ValueObjects\EnrollmentId;
use Learning\Domain\ValueObjects\CourseId;
use User\Domain\ValueObjects\UserId;

class Certificate
{
    private CertificateId $id;
    private UserId $userId;
    private CourseId $courseId;
    private EnrollmentId $enrollmentId;
    private CertificateNumber $certificateNumber;
    private string $courseName;
    private ?string $userName = null;
    private ?string $instructorName = null;
    private \DateTimeImmutable $completionDate;
    private float $score;
    private ?\DateTimeImmutable $expiryDate = null;
    private ?\DateTimeImmutable $revokedAt = null;
    private ?string $revocationReason = null;
    private array $templateData = [];
    private \DateTimeImmutable $createdAt;
    private \DateTimeImmutable $updatedAt;
    
    private function __construct(
        CertificateId $id,
        UserId $userId,
        CourseId $courseId,
        EnrollmentId $enrollmentId,
        CertificateNumber $certificateNumber,
        string $courseName,
        \DateTimeImmutable $completionDate,
        float $score
    ) {
        $this->id = $id;
        $this->userId = $userId;
        $this->courseId = $courseId;
        $this->enrollmentId = $enrollmentId;
        $this->certificateNumber = $certificateNumber;
        $this->courseName = $courseName;
        $this->completionDate = $completionDate;
        $this->score = $score;
        $this->createdAt = new \DateTimeImmutable();
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public static function create(
        UserId $userId,
        CourseId $courseId,
        EnrollmentId $enrollmentId,
        CertificateNumber $certificateNumber,
        string $courseName,
        \DateTimeImmutable $completionDate,
        float $score
    ): self {
        return new self(
            CertificateId::generate(),
            $userId,
            $courseId,
            $enrollmentId,
            $certificateNumber,
            $courseName,
            $completionDate,
            $score
        );
    }
    
    public function setUserName(string $userName): void
    {
        $this->userName = $userName;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function setInstructorName(string $instructorName): void
    {
        $this->instructorName = $instructorName;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function setTemplateData(array $templateData): void
    {
        $this->templateData = $templateData;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function setExpiryDate(\DateTimeImmutable $expiryDate): void
    {
        $this->expiryDate = $expiryDate;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function revoke(string $reason): void
    {
        if ($this->revokedAt !== null) {
            throw new \DomainException('Certificate is already revoked');
        }
        
        $this->revokedAt = new \DateTimeImmutable();
        $this->revocationReason = $reason;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function reinstate(): void
    {
        if ($this->revokedAt === null) {
            throw new \DomainException('Certificate is not revoked');
        }
        
        $this->revokedAt = null;
        $this->revocationReason = null;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function isValid(): bool
    {
        return $this->revokedAt === null;
    }
    
    public function isValidOn(\DateTimeImmutable $date): bool
    {
        if (!$this->isValid()) {
            return false;
        }
        
        if ($this->expiryDate === null) {
            return true;
        }
        
        return $date <= $this->expiryDate;
    }
    
    public function generateVerificationUrl(string $baseUrl): string
    {
        return sprintf(
            '%s/certificates/verify/%s',
            rtrim($baseUrl, '/'),
            $this->id->getValue()
        );
    }
    
    public function generateQrCodeData(string $verificationUrl): string
    {
        // In real implementation, this would use a QR code library
        // For now, return a mock base64 encoded PNG
        return 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';
    }
    
    // Getters
    public function getId(): CertificateId
    {
        return $this->id;
    }
    
    public function getUserId(): UserId
    {
        return $this->userId;
    }
    
    public function getCourseId(): CourseId
    {
        return $this->courseId;
    }
    
    public function getEnrollmentId(): EnrollmentId
    {
        return $this->enrollmentId;
    }
    
    public function getCertificateNumber(): CertificateNumber
    {
        return $this->certificateNumber;
    }
    
    public function getCourseName(): string
    {
        return $this->courseName;
    }
    
    public function getUserName(): ?string
    {
        return $this->userName;
    }
    
    public function getInstructorName(): ?string
    {
        return $this->instructorName;
    }
    
    public function getCompletionDate(): \DateTimeImmutable
    {
        return $this->completionDate;
    }
    
    public function getScore(): float
    {
        return $this->score;
    }
    
    public function getExpiryDate(): ?\DateTimeImmutable
    {
        return $this->expiryDate;
    }
    
    public function getRevokedAt(): ?\DateTimeImmutable
    {
        return $this->revokedAt;
    }
    
    public function getRevocationReason(): ?string
    {
        return $this->revocationReason;
    }
    
    public function getTemplateData(): array
    {
        return $this->templateData;
    }
    
    public function getCreatedAt(): \DateTimeImmutable
    {
        return $this->createdAt;
    }
    
    public function getUpdatedAt(): \DateTimeImmutable
    {
        return $this->updatedAt;
    }
} 