<?php

declare(strict_types=1);

namespace App\User\Infrastructure\Http\Controllers;

use App\Common\Http\BaseController;
use App\User\Domain\Service\UserServiceInterface;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Message\UploadedFileInterface;

/**
 * Controller for user import/export operations
 */
class UserImportExportController extends BaseController
{
    public function __construct(
        private UserServiceInterface $userService
    ) {
    }
    
    /**
     * Import users from CSV
     */
    public function import(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $uploadedFiles = $request->getUploadedFiles();
        
        if (empty($uploadedFiles['file'])) {
            return $this->error($response, 'No file uploaded', 400);
        }
        
        /** @var UploadedFileInterface $uploadedFile */
        $uploadedFile = $uploadedFiles['file'];
        
        if ($uploadedFile->getError() !== UPLOAD_ERR_OK) {
            return $this->error($response, 'File upload failed', 400);
        }
        
        $tempFile = tempnam(sys_get_temp_dir(), 'import_');
        $uploadedFile->moveTo($tempFile);
        
        try {
            $results = $this->userService->importFromCsv($tempFile);
            
            return $this->json($response, [
                'data' => $results,
                'message' => sprintf(
                    'Import completed: %d success, %d failed',
                    $results['success'],
                    $results['failed']
                )
            ]);
        } catch (\Exception $e) {
            return $this->error($response, $e->getMessage(), 400);
        } finally {
            unlink($tempFile);
        }
    }
    
    /**
     * Export users to CSV
     */
    public function export(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $params = $request->getQueryParams();
        $criteria = [];
        
        if (!empty($params['status'])) {
            $criteria['status'] = $params['status'];
        }
        
        if (!empty($params['role'])) {
            $criteria['role'] = $params['role'];
        }
        
        if (!empty($params['department'])) {
            $criteria['department'] = $params['department'];
        }
        
        try {
            $filePath = $this->userService->exportToCsv($criteria);
            
            $response = $response
                ->withHeader('Content-Type', 'text/csv')
                ->withHeader('Content-Disposition', 'attachment; filename="users_export.csv"')
                ->withHeader('Content-Length', (string) filesize($filePath));
            
            $stream = fopen($filePath, 'r');
            $response->getBody()->write(stream_get_contents($stream));
            fclose($stream);
            unlink($filePath);
            
            return $response;
        } catch (\Exception $e) {
            return $this->error($response, $e->getMessage(), 500);
        }
    }
} 