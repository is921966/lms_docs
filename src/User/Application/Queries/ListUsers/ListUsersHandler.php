<?php

namespace User\Application\Queries\ListUsers;

use User\Domain\UserRepository;
use User\Application\DTO\UserListResponse;

class ListUsersHandler
{
    private UserRepository $repository;

    public function __construct(UserRepository $repository)
    {
        $this->repository = $repository;
    }

    public function handle(ListUsersQuery $query): UserListResponse
    {
        // Получить всех пользователей (временная реализация)
        // В реальной реализации это должно быть в репозитории
        $allUsers = $this->repository->findAll();
        
        // Применить фильтры
        $filteredUsers = $this->applyFilters($allUsers, $query->getFilters());
        
        // Применить поиск
        if ($query->getSearch()) {
            $filteredUsers = $this->applySearch($filteredUsers, $query->getSearch());
        }
        
        // Применить сортировку
        if ($query->getSortBy()) {
            $filteredUsers = $this->applySort($filteredUsers, $query->getSortBy(), $query->getSortOrder());
        }
        
        // Подсчитать общее количество
        $total = count($filteredUsers);
        
        // Применить пагинацию
        $paginatedUsers = array_slice(
            $filteredUsers,
            $query->getOffset(),
            $query->getPerPage()
        );
        
        // Преобразовать в массив для ответа
        $userData = array_map(function ($user) {
            return [
                'id' => (string) $user->getId(),
                'firstName' => $user->getFirstName(),
                'lastName' => $user->getLastName(),
                'email' => $user->getEmail(),
                'department' => $user->getDepartment(),
                'status' => $user->getStatus(),
                'role' => $user->getRole(),
                'isAdmin' => $user->isAdmin(),
                'createdAt' => $user->getCreatedAt()->format('Y-m-d H:i:s')
            ];
        }, $paginatedUsers);
        
        return new UserListResponse(
            $userData,
            $total,
            $query->getPage(),
            $query->getPerPage()
        );
    }
    
    private function applyFilters(array $users, array $filters): array
    {
        if (empty($filters)) {
            return $users;
        }
        
        return array_filter($users, function ($user) use ($filters) {
            foreach ($filters as $field => $value) {
                switch ($field) {
                    case 'status':
                        if ($user->getStatus() !== $value) {
                            return false;
                        }
                        break;
                    case 'department':
                        if ($user->getDepartment() !== $value) {
                            return false;
                        }
                        break;
                    case 'role':
                        if ($user->getRole() !== $value) {
                            return false;
                        }
                        break;
                    case 'isAdmin':
                        if ($user->isAdmin() !== (bool)$value) {
                            return false;
                        }
                        break;
                }
            }
            return true;
        });
    }
    
    private function applySearch(array $users, string $search): array
    {
        $searchLower = mb_strtolower($search);
        
        return array_filter($users, function ($user) use ($searchLower) {
            return mb_stripos($user->getFirstName(), $searchLower) !== false ||
                   mb_stripos($user->getLastName(), $searchLower) !== false ||
                   mb_stripos($user->getEmail(), $searchLower) !== false ||
                   mb_stripos($user->getDepartment() ?? '', $searchLower) !== false;
        });
    }
    
    private function applySort(array $users, string $sortBy, string $sortOrder): array
    {
        usort($users, function ($a, $b) use ($sortBy, $sortOrder) {
            $aValue = $bValue = null;
            
            switch ($sortBy) {
                case 'name':
                    $aValue = $a->getFirstName() . ' ' . $a->getLastName();
                    $bValue = $b->getFirstName() . ' ' . $b->getLastName();
                    break;
                case 'email':
                    $aValue = $a->getEmail();
                    $bValue = $b->getEmail();
                    break;
                case 'department':
                    $aValue = $a->getDepartment() ?? '';
                    $bValue = $b->getDepartment() ?? '';
                    break;
                case 'createdAt':
                    $aValue = $a->getCreatedAt()->getTimestamp();
                    $bValue = $b->getCreatedAt()->getTimestamp();
                    break;
                default:
                    return 0;
            }
            
            $result = $aValue <=> $bValue;
            return $sortOrder === 'desc' ? -$result : $result;
        });
        
        return $users;
    }
} 