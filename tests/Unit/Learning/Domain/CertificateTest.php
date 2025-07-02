<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Domain;

use Learning\Domain\Certificate;
use Learning\Domain\ValueObjects\CertificateId;
use Learning\Domain\ValueObjects\CertificateNumber;
use Learning\Domain\ValueObjects\EnrollmentId;
use Learning\Domain\ValueObjects\CourseId;
use User\Domain\ValueObjects\UserId;
use PHPUnit\Framework\TestCase;

class CertificateTest extends TestCase
{
    public function testCanBeCreated(): void
    {
        $userId = UserId::generate();
        $courseId = CourseId::generate();
        $enrollmentId = EnrollmentId::generate();
        $certificateNumber = CertificateNumber::generate(2024, 1);
        
        $certificate = Certificate::create(
            userId: $userId,
            courseId: $courseId,
            enrollmentId: $enrollmentId,
            certificateNumber: $certificateNumber,
            courseName: 'PHP Advanced Course',
            completionDate: new \DateTimeImmutable('2024-01-15'),
            score: 95.5
        );
        
        $this->assertInstanceOf(Certificate::class, $certificate);
        $this->assertInstanceOf(CertificateId::class, $certificate->getId());
        $this->assertTrue($certificate->getUserId()->equals($userId));
        $this->assertTrue($certificate->getCourseId()->equals($courseId));
        $this->assertTrue($certificate->getEnrollmentId()->equals($enrollmentId));
        $this->assertEquals('CERT-2024-00001', $certificate->getCertificateNumber()->getValue());
        $this->assertEquals('PHP Advanced Course', $certificate->getCourseName());
        $this->assertEquals('2024-01-15', $certificate->getCompletionDate()->format('Y-m-d'));
        $this->assertEquals(95.5, $certificate->getScore());
        $this->assertTrue($certificate->isValid());
        $this->assertNull($certificate->getRevokedAt());
    }
    
    public function testCanSetUserName(): void
    {
        $certificate = $this->createTestCertificate();
        
        $certificate->setUserName('John Doe');
        
        $this->assertEquals('John Doe', $certificate->getUserName());
    }
    
    public function testCanSetInstructorName(): void
    {
        $certificate = $this->createTestCertificate();
        
        $certificate->setInstructorName('Dr. Smith');
        
        $this->assertEquals('Dr. Smith', $certificate->getInstructorName());
    }
    
    public function testCanSetTemplateData(): void
    {
        $certificate = $this->createTestCertificate();
        
        $templateData = [
            'duration' => '40 hours',
            'level' => 'Advanced',
            'skills' => ['PHP', 'Laravel', 'TDD']
        ];
        
        $certificate->setTemplateData($templateData);
        
        $this->assertEquals($templateData, $certificate->getTemplateData());
    }
    
    public function testCanBeRevoked(): void
    {
        $certificate = $this->createTestCertificate();
        $this->assertTrue($certificate->isValid());
        
        $reason = 'Academic dishonesty';
        $certificate->revoke($reason);
        
        $this->assertFalse($certificate->isValid());
        $this->assertNotNull($certificate->getRevokedAt());
        $this->assertEquals($reason, $certificate->getRevocationReason());
    }
    
    public function testCannotBeRevokedTwice(): void
    {
        $certificate = $this->createTestCertificate();
        $certificate->revoke('First reason');
        
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Certificate is already revoked');
        
        $certificate->revoke('Second reason');
    }
    
    public function testCanBeReinstated(): void
    {
        $certificate = $this->createTestCertificate();
        $certificate->revoke('Mistake');
        $this->assertFalse($certificate->isValid());
        
        $certificate->reinstate();
        
        $this->assertTrue($certificate->isValid());
        $this->assertNull($certificate->getRevokedAt());
        $this->assertNull($certificate->getRevocationReason());
    }
    
    public function testCannotReinstateValidCertificate(): void
    {
        $certificate = $this->createTestCertificate();
        
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Certificate is not revoked');
        
        $certificate->reinstate();
    }
    
    public function testCanGenerateVerificationUrl(): void
    {
        $certificate = $this->createTestCertificate();
        $baseUrl = 'https://lms.example.com';
        
        $url = $certificate->generateVerificationUrl($baseUrl);
        
        $this->assertStringStartsWith($baseUrl . '/certificates/verify/', $url);
        $this->assertStringContainsString($certificate->getId()->getValue(), $url);
    }
    
    public function testCanGenerateQrCode(): void
    {
        $certificate = $this->createTestCertificate();
        $verificationUrl = 'https://lms.example.com/certificates/verify/123';
        
        $qrCode = $certificate->generateQrCodeData($verificationUrl);
        
        $this->assertStringStartsWith('data:image/png;base64,', $qrCode);
    }
    
    public function testCanCalculateValidityPeriod(): void
    {
        $certificate = $this->createTestCertificate();
        
        // No expiry
        $this->assertNull($certificate->getExpiryDate());
        $this->assertTrue($certificate->isValidOn(new \DateTimeImmutable('+10 years')));
        
        // With expiry
        $expiryDate = new \DateTimeImmutable('+2 years');
        $certificate->setExpiryDate($expiryDate);
        
        $this->assertEquals($expiryDate, $certificate->getExpiryDate());
        $this->assertTrue($certificate->isValidOn(new \DateTimeImmutable('+1 year')));
        $this->assertFalse($certificate->isValidOn(new \DateTimeImmutable('+3 years')));
    }
    
    private function createTestCertificate(): Certificate
    {
        return Certificate::create(
            userId: UserId::generate(),
            courseId: CourseId::generate(),
            enrollmentId: EnrollmentId::generate(),
            certificateNumber: CertificateNumber::generate(2024, 1),
            courseName: 'Test Course',
            completionDate: new \DateTimeImmutable(),
            score: 85.0
        );
    }
} 