<?php

declare(strict_types=1);

namespace App\Learning\Application\DTO;

use App\Learning\Domain\Certificate;

final class CertificateDTO
{
    public function __construct(
        public readonly ?string $id,
        public readonly string $userId,
        public readonly string $courseId,
        public readonly string $enrollmentId,
        public readonly string $certificateNumber,
        public readonly string $courseName,
        public readonly ?string $userName,
        public readonly ?string $instructorName,
        public readonly string $completionDate,
        public readonly float $score,
        public readonly ?string $expiryDate,
        public readonly bool $isValid,
        public readonly ?string $revokedAt,
        public readonly ?string $revocationReason,
        public readonly array $templateData,
        public readonly ?string $verificationUrl,
        public readonly ?string $createdAt = null,
        public readonly ?string $updatedAt = null
    ) {}
    
    public static function fromArray(array $data): self
    {
        return new self(
            id: $data['id'] ?? null,
            userId: $data['userId'],
            courseId: $data['courseId'],
            enrollmentId: $data['enrollmentId'],
            certificateNumber: $data['certificateNumber'],
            courseName: $data['courseName'],
            userName: $data['userName'] ?? null,
            instructorName: $data['instructorName'] ?? null,
            completionDate: $data['completionDate'],
            score: $data['score'],
            expiryDate: $data['expiryDate'] ?? null,
            isValid: $data['isValid'] ?? true,
            revokedAt: $data['revokedAt'] ?? null,
            revocationReason: $data['revocationReason'] ?? null,
            templateData: $data['templateData'] ?? [],
            verificationUrl: $data['verificationUrl'] ?? null,
            createdAt: $data['createdAt'] ?? null,
            updatedAt: $data['updatedAt'] ?? null
        );
    }
    
    public static function fromEntity(Certificate $certificate): self
    {
        return new self(
            id: $certificate->getId()->toString(),
            userId: $certificate->getUserId()->getValue(),
            courseId: $certificate->getCourseId()->toString(),
            enrollmentId: $certificate->getEnrollmentId()->toString(),
            certificateNumber: $certificate->getCertificateNumber()->getValue(),
            courseName: $certificate->getCourseName(),
            userName: $certificate->getUserName(),
            instructorName: $certificate->getInstructorName(),
            completionDate: $certificate->getCompletionDate()->format('c'),
            score: $certificate->getScore(),
            expiryDate: $certificate->getExpiryDate()?->format('c'),
            isValid: $certificate->isValid(),
            revokedAt: $certificate->getRevokedAt()?->format('c'),
            revocationReason: $certificate->getRevocationReason(),
            templateData: $certificate->getTemplateData(),
            verificationUrl: null, // Generated separately if needed
            createdAt: $certificate->getCreatedAt()->format('c'),
            updatedAt: $certificate->getUpdatedAt()->format('c')
        );
    }
    
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'userId' => $this->userId,
            'courseId' => $this->courseId,
            'enrollmentId' => $this->enrollmentId,
            'certificateNumber' => $this->certificateNumber,
            'courseName' => $this->courseName,
            'userName' => $this->userName,
            'instructorName' => $this->instructorName,
            'completionDate' => $this->completionDate,
            'score' => $this->score,
            'expiryDate' => $this->expiryDate,
            'isValid' => $this->isValid,
            'revokedAt' => $this->revokedAt,
            'revocationReason' => $this->revocationReason,
            'templateData' => $this->templateData,
            'verificationUrl' => $this->verificationUrl,
            'createdAt' => $this->createdAt,
            'updatedAt' => $this->updatedAt,
        ];
    }
} 