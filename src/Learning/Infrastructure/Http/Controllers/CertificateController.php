<?php

declare(strict_types=1);

namespace App\Learning\Infrastructure\Http\Controllers;

use App\Learning\Application\Service\CertificateService;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\JsonResponse;

class CertificateController
{
    public function __construct(
        private readonly CertificateService $certificateService
    ) {}
    
    public function issue(Request $request): JsonResponse
    {
        try {
            $data = json_decode($request->getContent(), true);
            
            if (!$data || !isset($data['userId']) || !isset($data['courseId'])) {
                return new JsonResponse(['error' => 'Missing required fields'], Response::HTTP_BAD_REQUEST);
            }
            
            $certificate = $this->certificateService->issue(
                $data['userId'],
                $data['courseId'],
                $data['templateCode'] ?? 'default'
            );
            
            return new JsonResponse(['data' => $certificate], Response::HTTP_CREATED);
        } catch (\App\Common\Exceptions\BusinessLogicException $e) {
            return new JsonResponse(['error' => $e->getMessage()], Response::HTTP_BAD_REQUEST);
        } catch (\App\Common\Exceptions\NotFoundException $e) {
            return new JsonResponse(['error' => $e->getMessage()], Response::HTTP_NOT_FOUND);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => 'Internal server error'], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
    
    public function verify(string $certificateNumber): JsonResponse
    {
        try {
            $certificate = $this->certificateService->verify($certificateNumber);
            
            return new JsonResponse(['data' => $certificate]);
        } catch (\App\Common\Exceptions\NotFoundException $e) {
            return new JsonResponse(['error' => $e->getMessage()], Response::HTTP_NOT_FOUND);
        } catch (\InvalidArgumentException $e) {
            return new JsonResponse(['error' => $e->getMessage()], Response::HTTP_BAD_REQUEST);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => 'Internal server error'], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
    
    public function revoke(string $id, Request $request): JsonResponse
    {
        try {
            $data = json_decode($request->getContent(), true);
            
            if (!$data || !isset($data['reason'])) {
                return new JsonResponse(['error' => 'Missing reason field'], Response::HTTP_BAD_REQUEST);
            }
            
            $result = $this->certificateService->revoke($id, $data['reason']);
            
            if ($result) {
                return new JsonResponse(['message' => 'Certificate revoked successfully']);
            }
            
            return new JsonResponse(['error' => 'Failed to revoke certificate'], Response::HTTP_BAD_REQUEST);
        } catch (\App\Common\Exceptions\NotFoundException $e) {
            return new JsonResponse(['error' => $e->getMessage()], Response::HTTP_NOT_FOUND);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => 'Internal server error'], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
    
    public function reinstate(string $id): JsonResponse
    {
        try {
            $result = $this->certificateService->reinstate($id);
            
            if ($result) {
                return new JsonResponse(['message' => 'Certificate reinstated successfully']);
            }
            
            return new JsonResponse(['error' => 'Failed to reinstate certificate'], Response::HTTP_BAD_REQUEST);
        } catch (\App\Common\Exceptions\NotFoundException $e) {
            return new JsonResponse(['error' => $e->getMessage()], Response::HTTP_NOT_FOUND);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => 'Internal server error'], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
    
    public function userCertificates(string $userId): JsonResponse
    {
        try {
            $certificates = $this->certificateService->findUserCertificates($userId);
            
            return new JsonResponse(['data' => $certificates]);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => 'Internal server error'], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
    
    public function courseCertificates(string $courseId): JsonResponse
    {
        try {
            $certificates = $this->certificateService->findCourseCertificates($courseId);
            
            return new JsonResponse(['data' => $certificates]);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => 'Internal server error'], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
} 