<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Infrastructure\Http\Controllers;

use Learning\Infrastructure\Http\Controllers\CertificateController;
use Learning\Application\Service\CertificateService;
use Learning\Application\DTO\CertificateDTO;
use PHPUnit\Framework\TestCase;
use PHPUnit\Framework\MockObject\MockObject;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\JsonResponse;

class CertificateControllerTest extends TestCase
{
    private CertificateService&MockObject $certificateService;
    private CertificateController $controller;
    
    protected function setUp(): void
    {
        $this->certificateService = $this->createMock(CertificateService::class);
        $this->controller = new CertificateController($this->certificateService);
    }
    
    public function testCanIssueCertificate(): void
    {
        $requestData = [
            'userId' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            'courseId' => 'c1d2e3f4-a5b6-4789-0123-456789abcdef'
        ];
        
        $certificateDto = $this->createCertificateDto();
        
        $this->certificateService
            ->expects($this->once())
            ->method('issue')
            ->with($requestData['userId'], $requestData['courseId'], 'default')
            ->willReturn($certificateDto);
        
        $request = Request::create('/', 'POST', [], [], [], [], json_encode($requestData));
        $response = $this->controller->issue($request);
        
        $this->assertEquals(Response::HTTP_CREATED, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertEquals('CERT-2025-00001', $data['data']['certificateNumber']);
    }
    
    public function testCanVerifyCertificate(): void
    {
        $certificateNumber = 'CERT-2025-00123';
        $certificateDto = $this->createCertificateDto();
        
        $this->certificateService
            ->expects($this->once())
            ->method('verify')
            ->with($certificateNumber)
            ->willReturn($certificateDto);
        
        $response = $this->controller->verify($certificateNumber);
        
        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertTrue($data['data']['isValid']);
    }
    
    public function testCanGetUserCertificates(): void
    {
        $userId = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
        $certificates = [
            $this->createCertificateDto(),
            $this->createCertificateDto()
        ];
        
        $this->certificateService
            ->expects($this->once())
            ->method('findUserCertificates')
            ->with($userId)
            ->willReturn($certificates);
        
        $response = $this->controller->userCertificates($userId);
        
        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertCount(2, $data['data']);
    }
    
    private function createCertificateDto(): CertificateDTO
    {
        return new CertificateDTO(
            id: 'cert-123',
            userId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            courseId: 'c1d2e3f4-a5b6-4789-0123-456789abcdef',
            enrollmentId: 'enrollment-123',
            certificateNumber: 'CERT-2025-00001',
            courseName: 'Test Course',
            userName: 'John Doe',
            instructorName: null,
            completionDate: '2024-01-01',
            score: 90.0,
            expiryDate: null,
            isValid: true,
            revokedAt: null,
            revocationReason: null,
            templateData: [],
            verificationUrl: null,
            createdAt: '2024-01-01T00:00:00+00:00',
            updatedAt: '2024-01-01T00:00:00+00:00'
        );
    }
} 