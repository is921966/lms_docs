<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Infrastructure\Repository;

use Learning\Infrastructure\Repository\InMemoryCertificateRepository;
use Learning\Domain\Certificate;
use Learning\Domain\ValueObjects\CertificateId;
use Learning\Domain\ValueObjects\CertificateNumber;
use Learning\Domain\ValueObjects\CourseId;
use Learning\Domain\ValueObjects\EnrollmentId;
use User\Domain\ValueObjects\UserId;
use PHPUnit\Framework\TestCase;

class InMemoryCertificateRepositoryTest extends TestCase
{
    private InMemoryCertificateRepository $repository;
    
    protected function setUp(): void
    {
        $this->repository = new InMemoryCertificateRepository();
    }
    
    public function testCanSaveAndFindCertificate(): void
    {
        $certificate = $this->createCertificate();
        
        $this->repository->save($certificate);
        
        $found = $this->repository->findById($certificate->getId());
        
        $this->assertNotNull($found);
        $this->assertEquals($certificate->getId()->getValue(), $found->getId()->getValue());
    }
    
    public function testCanFindByNumber(): void
    {
        $certificate = $this->createCertificate();
        $this->repository->save($certificate);
        
        $found = $this->repository->findByNumber($certificate->getCertificateNumber());
        
        $this->assertNotNull($found);
        $this->assertEquals($certificate->getId()->getValue(), $found->getId()->getValue());
    }
    
    public function testCanFindByUser(): void
    {
        $userId = UserId::generate();
        $year = (int) date('Y');
        
        $cert1 = Certificate::create(
            $userId,
            CourseId::generate(),
            EnrollmentId::generate(),
            CertificateNumber::generate($year, 1),
            'Course 1',
            new \DateTimeImmutable(),
            85.5
        );
        $cert1->setUserName('User Name');
        
        $cert2 = Certificate::create(
            $userId,
            CourseId::generate(),
            EnrollmentId::generate(),
            CertificateNumber::generate($year, 2),
            'Course 2',
            new \DateTimeImmutable(),
            90.0
        );
        $cert2->setUserName('User Name');
        
        $this->repository->save($cert1);
        $this->repository->save($cert2);
        
        $certificates = $this->repository->findByUser($userId);
        
        $this->assertCount(2, $certificates);
    }
    
    public function testCanGetNextCertificateNumber(): void
    {
        $cert1 = $this->createCertificate();
        $this->repository->save($cert1);
        
        $year = (int) date('Y');
        $nextNumber = $this->repository->getNextCertificateNumber($year);
        
        $this->assertInstanceOf(CertificateNumber::class, $nextNumber);
        $this->assertStringStartsWith('CERT-', (string) $nextNumber);
    }
    
    private function createCertificate(): Certificate
    {
        static $counter = 0;
        $counter++;
        $year = (int) date('Y');
        
        $cert = Certificate::create(
            UserId::generate(),
            CourseId::generate(),
            EnrollmentId::generate(),
            CertificateNumber::generate($year, $counter),
            'Test Course',
            new \DateTimeImmutable(),
            95.0
        );
        $cert->setUserName('Test User');
        
        return $cert;
    }
} 