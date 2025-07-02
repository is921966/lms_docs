<?php

declare(strict_types=1);

namespace User\Application\Service\User;

use App\User\Domain\Repository\UserRepositoryInterface;
use Psr\Log\LoggerInterface;

/**
 * Service for importing and exporting users
 */
class UserImportExportService
{
    public function __construct(
        private UserRepositoryInterface $userRepository,
        private UserCrudService $crudService,
        private LoggerInterface $logger
    ) {
    }
    
    /**
     * Import users from CSV
     */
    public function importFromCsv(string $filePath): array
    {
        $this->logger->info('Importing users from CSV', ['file' => $filePath]);
        
        if (!file_exists($filePath)) {
            throw new \InvalidArgumentException('CSV file not found');
        }
        
        $results = [
            'success' => 0,
            'failed' => 0,
            'errors' => []
        ];
        
        $handle = fopen($filePath, 'r');
        $headers = fgetcsv($handle);
        
        while (($row = fgetcsv($handle)) !== false) {
            $data = array_combine($headers, $row);
            
            try {
                $this->crudService->createUser($data);
                $results['success']++;
            } catch (\Exception $e) {
                $results['failed']++;
                $results['errors'][] = [
                    'row' => $data,
                    'error' => $e->getMessage()
                ];
            }
        }
        
        fclose($handle);
        
        $this->logger->info('CSV import completed', $results);
        
        return $results;
    }
    
    /**
     * Export users to CSV
     */
    public function exportToCsv(array $criteria): string
    {
        $this->logger->info('Exporting users to CSV', ['criteria' => $criteria]);
        
        $users = $this->userRepository->search($criteria);
        
        $filePath = tempnam(sys_get_temp_dir(), 'users_export_');
        $handle = fopen($filePath, 'w');
        
        // Write headers
        fputcsv($handle, [
            'ID', 'Email', 'First Name', 'Last Name', 'Middle Name',
            'Phone', 'Department', 'Position ID', 'Status', 'Created At'
        ]);
        
        // Write data
        foreach ($users as $user) {
            fputcsv($handle, [
                $user->getId()->getValue(),
                $user->getEmail()->getValue(),
                $user->getFirstName(),
                $user->getLastName(),
                $user->getMiddleName(),
                $user->getPhone(),
                $user->getDepartment(),
                $user->getPositionId(),
                $user->getStatus(),
                $user->getCreatedAt()->format('Y-m-d H:i:s')
            ]);
        }
        
        fclose($handle);
        
        $this->logger->info('Users exported successfully', ['count' => count($users)]);
        
        return $filePath;
    }
} 