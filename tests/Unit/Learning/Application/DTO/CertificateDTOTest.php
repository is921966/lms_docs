<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Application\DTO;

use App\Learning\Application\DTO\CertificateDTO;
use App\Learning\Domain\Certificate;
use App\Learning\Domain\ValueObjects\CertificateNumber;
use App\Learning\Domain\ValueObjects\CourseId;
use App\Learning\Domain\ValueObjects\EnrollmentId;
use App\User\Domain\ValueObjects\UserId;
use PHPUnit\Framework\TestCase;

class CertificateDTOTest extends TestCase
{
    public function testCanBeCreatedFromArray(): void
    {
        $data = [
            'id' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            'userId' => 'a1b2c3d4-e5f6-4789-0123-456789abcdef',
            'courseId' => 'c1d2e3f4-a5b6-4789-0123-456789abcdef',
            'enrollmentId' => 'e1f2g3h4-i5j6-7890-1234-567890abcdef',
            'certificateNumber' => 'CERT-2024-00001',
            'courseName' => 'PHP Advanced Course',
            'userName' => 'John Doe',
            'instructorName' => 'Dr. Smith',
            'completionDate' => '2024-01-15T10:00:00+00:00',
            'score' => 95.5,
            'expiryDate' => '2026-01-15T23:59:59+00:00',
            'isValid' => true,
            'verificationUrl' => 'https://lms.example.com/verify/123'
        ];
        
        $dto = CertificateDTO::fromArray($data);
        
        $this->assertEquals($data['id'], $dto->id);
        $this->assertEquals($data['userId'], $dto->userId);
        $this->assertEquals($data['certificateNumber'], $dto->certificateNumber);
        $this->assertEquals($data['courseName'], $dto->courseName);
        $this->assertEquals($data['userName'], $dto->userName);
        $this->assertEquals($data['score'], $dto->score);
        $this->assertTrue($dto->isValid);
    }
    
    public function testCanBeCreatedFromDomainEntity(): void
    {
        $certificate = $this->createTestCertificate();
        $certificate->setUserName('Jane Smith');
        $certificate->setInstructorName('Prof. Johnson');
        
        $dto = CertificateDTO::fromEntity($certificate);
        
        $this->assertEquals($certificate->getId()->toString(), $dto->id);
        $this->assertEquals($certificate->getUserId()->getValue(), $dto->userId);
        $this->assertEquals($certificate->getCertificateNumber()->getValue(), $dto->certificateNumber);
        $this->assertEquals($certificate->getCourseName(), $dto->courseName);
        $this->assertEquals('Jane Smith', $dto->userName);
        $this->assertEquals('Prof. Johnson', $dto->instructorName);
        $this->assertEquals($certificate->getScore(), $dto->score);
        $this->assertTrue($dto->isValid);
    }
    
    public function testCanConvertToArray(): void
    {
        $dto = new CertificateDTO(
            id: 'cert-123',
            userId: 'user-456',
            courseId: 'course-789',
            enrollmentId: 'enroll-012',
            certificateNumber: 'CERT-2024-00100',
            courseName: 'Test Course',
            userName: 'Test User',
            instructorName: 'Test Instructor',
            completionDate: '2024-03-01T12:00:00+00:00',
            score: 88.0,
            expiryDate: null,
            isValid: true,
            revokedAt: null,
            revocationReason: null,
            templateData: ['duration' => '40 hours'],
            verificationUrl: null,
            createdAt: '2024-03-01T12:00:00+00:00',
            updatedAt: '2024-03-01T12:00:00+00:00'
        );
        
        $array = $dto->toArray();
        
        $this->assertIsArray($array);
        $this->assertEquals($dto->id, $array['id']);
        $this->assertEquals($dto->certificateNumber, $array['certificateNumber']);
        $this->assertEquals($dto->courseName, $array['courseName']);
        $this->assertEquals($dto->score, $array['score']);
        $this->assertTrue($array['isValid']);
    }
    
    private function createTestCertificate(): Certificate
    {
        return Certificate::create(
            userId: UserId::generate(),
            courseId: CourseId::generate(),
            enrollmentId: EnrollmentId::generate(),
            certificateNumber: CertificateNumber::generate(2024, 1),
            courseName: 'Test Course',
            completionDate: new \DateTimeImmutable('2024-01-15'),
            score: 95.5
        );
    }
}
