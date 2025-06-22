<?php

declare(strict_types=1);

namespace App\User\Application\Service\User;

use App\Common\Exceptions\BusinessLogicException;
use App\Common\Exceptions\ValidationException;
use App\User\Domain\Repository\RoleRepositoryInterface;
use App\User\Domain\Repository\UserRepositoryInterface;
use App\User\Domain\User;
use App\User\Domain\ValueObjects\Email;
use App\User\Domain\ValueObjects\Password;
use App\User\Domain\ValueObjects\UserId;
use Psr\Log\LoggerInterface;

/**
 * Service for basic CRUD operations on users
 */
class UserCrudService
{
    public function __construct(
        private UserRepositoryInterface $userRepository,
        private RoleRepositoryInterface $roleRepository,
        private LoggerInterface $logger
    ) {
    }
    
    /**
     * Create a new user
     */
    public function createUser(array $data): User
    {
        $this->logger->info('Creating new user', ['email' => $data['email'] ?? null]);
        
        // Validate required fields
        $this->validateUserData($data);
        
        // Check if email already exists
        $email = new Email($data['email']);
        if ($this->userRepository->emailExists($email)) {
            throw ValidationException::withErrors(['email' => 'Email already exists']);
        }
        
        // Create user
        $user = User::create(
            $email,
            $data['firstName'],
            $data['lastName'],
            !empty($data['password']) ? Password::fromPlainText($data['password']) : null,
            $data['adUsername'] ?? null
        );
        
        // Update profile with optional fields if provided
        if (!empty($data['middleName']) || !empty($data['phone']) || !empty($data['department'])) {
            $user->updateProfile(
                $data['firstName'],
                $data['lastName'],
                $data['middleName'] ?? null,
                $data['phone'] ?? null,
                $data['department'] ?? null
            );
        }
        
        // Assign default role
        $defaultRole = $this->roleRepository->getDefaultRole();
        if ($defaultRole) {
            $user->addRole($defaultRole);
        }
        
        // Assign additional roles if provided
        if (!empty($data['roles'])) {
            $roles = $this->roleRepository->findByNames($data['roles']);
            foreach ($roles as $role) {
                $user->addRole($role);
            }
        }
        
        // Save user
        $this->userRepository->save($user);
        
        $this->logger->info('User created successfully', ['userId' => $user->getId()->getValue()]);
        
        return $user;
    }
    
    /**
     * Update user
     */
    public function updateUser(UserId $userId, array $data): User
    {
        $this->logger->info('Updating user', ['userId' => $userId->getValue()]);
        
        $user = $this->userRepository->getById($userId);
        
        // Update email if provided and different
        if (!empty($data['email']) && $data['email'] !== $user->getEmail()->getValue()) {
            $email = new Email($data['email']);
            if ($this->userRepository->emailExists($email, $userId)) {
                throw ValidationException::withErrors(['email' => 'Email already exists']);
            }
            $user->changeEmail($email);
        }
        
        // Update profile info if any fields are provided
        if (isset($data['firstName']) || isset($data['lastName']) || 
            array_key_exists('middleName', $data) || array_key_exists('phone', $data) || 
            array_key_exists('department', $data)) {
            
            $user->updateProfile(
                $data['firstName'] ?? $user->getFirstName(),
                $data['lastName'] ?? $user->getLastName(),
                $data['middleName'] ?? $user->getMiddleName(),
                $data['phone'] ?? $user->getPhone(),
                $data['department'] ?? $user->getDepartment()
            );
        }
        
        // Note: positionId, managerId, adUsername cannot be updated after creation
        // These would need to be added to the domain model if update is required
        
        // Save user
        $this->userRepository->save($user);
        
        $this->logger->info('User updated successfully', ['userId' => $userId->getValue()]);
        
        return $user;
    }
    
    /**
     * Delete user (soft delete)
     */
    public function deleteUser(UserId $userId): void
    {
        $this->logger->info('Deleting user', ['userId' => $userId->getValue()]);
        
        $user = $this->userRepository->getById($userId);
        
        if ($user->isDeleted()) {
            throw new BusinessLogicException('User is already deleted');
        }
        
        $user->delete();
        $this->userRepository->save($user);
        
        $this->logger->info('User deleted successfully', ['userId' => $userId->getValue()]);
    }
    
    /**
     * Get user by ID
     */
    public function getUser(UserId $userId): User
    {
        return $this->userRepository->getById($userId);
    }
    
    /**
     * Search users
     */
    public function searchUsers(array $criteria): array
    {
        return $this->userRepository->search($criteria);
    }
    
    /**
     * Validate user data
     */
    private function validateUserData(array $data): void
    {
        $errors = [];
        
        if (empty($data['email'])) {
            $errors['email'] = 'Email is required';
        }
        
        if (empty($data['firstName'])) {
            $errors['firstName'] = 'First name is required';
        }
        
        if (empty($data['lastName'])) {
            $errors['lastName'] = 'Last name is required';
        }
        
        if (!empty($errors)) {
            throw ValidationException::withErrors($errors);
        }
    }
} 