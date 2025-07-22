<?php

namespace App\OrgStructure\Infrastructure\DTO;

class LdapUserData
{
    public function __construct(
        private string $tabNumber,
        private string $fullName,
        private string $email,
        private ?string $phone = null,
        private ?string $department = null,
        private ?string $title = null,
        private ?string $managerDn = null,
        private ?string $distinguishedName = null
    ) {}
    
    public function getTabNumber(): string
    {
        return $this->tabNumber;
    }
    
    public function getFullName(): string
    {
        return $this->fullName;
    }
    
    public function getEmail(): string
    {
        return $this->email;
    }
    
    public function getPhone(): ?string
    {
        return $this->phone;
    }
    
    public function getDepartment(): ?string
    {
        return $this->department;
    }
    
    public function getTitle(): ?string
    {
        return $this->title;
    }
    
    public function getManagerDn(): ?string
    {
        return $this->managerDn;
    }
    
    public function getDistinguishedName(): ?string
    {
        return $this->distinguishedName;
    }
} 