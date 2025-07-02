<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Application\Service;

use Learning\Application\Service\CertificateService;
use Learning\Application\DTO\CertificateDTO;
use Learning\Domain\Certificate;
use Learning\Domain\Repository\CertificateRepositoryInterface;
use Learning\Domain\Repository\EnrollmentRepositoryInterface;
use Learning\Domain\Repository\CourseRepositoryInterface;
use Learning\Domain\Enrollment;
use Learning\Domain\Course;
use Learning\Domain\ValueObjects\CertificateId;
use Learning\Domain\ValueObjects\CertificateNumber;
use Learning\Domain\ValueObjects\CourseId;
use Learning\Domain\ValueObjects\CourseCode;
use Learning\Domain\ValueObjects\Duration;
use User\Domain\ValueObjects\UserId;
use PHPUnit\Framework\TestCase;
use PHPUnit\Framework\MockObject\MockObject;

class CertificateServiceTest extends TestCase
{
    private CertificateRepositoryInterface&MockObject $certificateRepository;
    private EnrollmentRepositoryInterface&MockObject $enrollmentRepository;
    private CourseRepositoryInterface&MockObject $courseRepository;
    private CertificateService $service;
    
    protected function setUp(): void
    {
        $this->certificateRepository = $this->createMock(CertificateRepositoryInterface::class);
        $this->enrollmentRepository = $this->createMock(EnrollmentRepositoryInterface::class);
        $this->courseRepository = $this->createMock(CourseRepositoryInterface::class);
        $this->service = new CertificateService(
            $this->certificateRepository,
            $this->enrollmentRepository,
            $this->courseRepository
        );
    }
    
    public function testCanIssueCertificate(): void
    {
        $userId = UserId::generate();
        $courseId = CourseId::generate();
        $enrollment = $this->createCompletedEnrollment($userId, $courseId);
        $course = $this->createTestCourse();
        $year = (int) date('Y');
        $certificateNumber = CertificateNumber::generate($year, 1);
        
        $this->enrollmentRepository
            ->expects($this->once())
            ->method('findByUserAndCourse')
            ->with($userId, $courseId)
            ->willReturn($enrollment);
        
        $this->courseRepository
            ->expects($this->once())
            ->method('findById')
            ->with($courseId)
            ->willReturn($course);
        
        $this->certificateRepository
            ->expects($this->once())
            ->method('findByEnrollment')
            ->with($enrollment->getId())
            ->willReturn(null);
        
        $this->certificateRepository
            ->expects($this->once())
            ->method('getNextCertificateNumber')
            ->with($year)
            ->willReturn($certificateNumber);
        
        $this->certificateRepository
            ->expects($this->once())
            ->method('save')
            ->with($this->isInstanceOf(Certificate::class));
        
        $dto = $this->service->issue($userId->getValue(), $courseId->getValue());
        
        $this->assertInstanceOf(CertificateDTO::class, $dto);
        $this->assertEquals($userId->getValue(), $dto->userId);
        $this->assertEquals($courseId->getValue(), $dto->courseId);
        $this->assertEquals("CERT-{$year}-00001", $dto->certificateNumber);
        $this->assertTrue($dto->isValid);
    }
    
    public function testCannotIssueCertificateForIncompleteEnrollment(): void
    {
        $userId = UserId::generate();
        $courseId = CourseId::generate();
        $enrollment = $this->createActiveEnrollment($userId, $courseId);
        
        $this->enrollmentRepository
            ->expects($this->once())
            ->method('findByUserAndCourse')
            ->willReturn($enrollment);
        
        $this->expectException(\Common\Exceptions\BusinessLogicException::class);
        $this->expectExceptionMessage('Enrollment is not completed');
        
        $this->service->issue($userId->getValue(), $courseId->getValue());
    }
    
    public function testCanVerifyCertificate(): void
    {
        $year = (int) date('Y');
        $certificateNumber = CertificateNumber::generate($year, 123);
        $certificate = $this->createTestCertificate();
        
        $this->certificateRepository
            ->expects($this->once())
            ->method('findByNumber')
            ->with($this->callback(function ($arg) use ($year) {
                return $arg instanceof CertificateNumber && $arg->getValue() === "CERT-{$year}-00123";
            }))
            ->willReturn($certificate);
        
        $dto = $this->service->verify("CERT-{$year}-00123");
        
        $this->assertInstanceOf(CertificateDTO::class, $dto);
        $this->assertTrue($dto->isValid);
    }
    
    public function testCanRevokeCertificate(): void
    {
        $certificateId = CertificateId::generate();
        $certificate = $this->createTestCertificate();
        
        $this->certificateRepository
            ->expects($this->once())
            ->method('findById')
            ->with($certificateId)
            ->willReturn($certificate);
        
        $this->certificateRepository
            ->expects($this->once())
            ->method('save')
            ->with($certificate);
        
        $result = $this->service->revoke($certificateId->getValue(), 'Academic dishonesty');
        
        $this->assertTrue($result);
    }
    
    public function testCanFindUserCertificates(): void
    {
        $userId = UserId::generate();
        $certificates = [
            $this->createTestCertificate(),
            $this->createTestCertificate()
        ];
        
        $this->certificateRepository
            ->expects($this->once())
            ->method('findByUser')
            ->with($userId)
            ->willReturn($certificates);
        
        $dtos = $this->service->findUserCertificates($userId->getValue());
        
        $this->assertCount(2, $dtos);
        $this->assertContainsOnlyInstancesOf(CertificateDTO::class, $dtos);
    }
    
    public function testThrowsExceptionWhenCertificateNotFound(): void
    {
        $year = (int) date('Y');
        
        $this->certificateRepository
            ->expects($this->once())
            ->method('findByNumber')
            ->willReturn(null);
        
        $this->expectException(\Common\Exceptions\NotFoundException::class);
        $this->expectExceptionMessage('Certificate not found');
        
        $this->service->verify("CERT-{$year}-99999");
    }
    
    private function createTestCourse(): Course
    {
        return Course::create(
            id: CourseId::generate(),
            code: CourseCode::fromString('CRS-001'),
            title: 'Test Course',
            description: 'Test Description',
            duration: Duration::fromHours(40)
        );
    }
    
    private function createCompletedEnrollment(UserId $userId, CourseId $courseId): Enrollment
    {
        $enrollment = Enrollment::create($userId, $courseId, $userId);
        $enrollment->activate();
        $enrollment->complete(90.0);
        return $enrollment;
    }
    
    private function createActiveEnrollment(UserId $userId, CourseId $courseId): Enrollment
    {
        $enrollment = Enrollment::create($userId, $courseId, $userId);
        $enrollment->activate();
        return $enrollment;
    }
    
    private function createTestCertificate(): Certificate
    {
        return Certificate::create(
            userId: UserId::generate(),
            courseId: CourseId::generate(),
            enrollmentId: \Learning\Domain\ValueObjects\EnrollmentId::generate(),
            certificateNumber: CertificateNumber::generate((int) date('Y'), 1),
            courseName: 'Test Course',
            completionDate: new \DateTimeImmutable(),
            score: 90.0
        );
    }
} 