<?php

namespace User\Domain;

use User\Domain\ValueObjects\Email;

class UserService
{
    public function createUser(UserRepository $repo, string $name, string $email, string $role): User
    {
        if (empty($name) || empty($email) || empty($role)) {
            throw new \InvalidArgumentException('Все поля обязательны');
        }
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            throw new \InvalidArgumentException('Некорректный email');
        }
        if ($repo->findByEmail($email)) {
            throw new \DomainException('Пользователь с таким email уже существует');
        }
        
        // Разделяем имя на firstName и lastName для фабричного метода
        $nameParts = explode(' ', $name, 2);
        $firstName = $nameParts[0];
        $lastName = $nameParts[1] ?? $firstName;
        
        $user = User::create(
            new Email($email),
            $firstName,
            $lastName
        );
        
        // TODO: Добавить роль к пользователю через метод addRole
        
        $repo->save($user);
        return $user;
    }
} 