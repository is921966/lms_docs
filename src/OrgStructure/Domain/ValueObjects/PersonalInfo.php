<?php
declare(strict_types=1);

namespace App\OrgStructure\Domain\ValueObjects;

use App\OrgStructure\Domain\Exceptions\InvalidPersonalInfoException;

final class PersonalInfo
{
    public function __construct(
        private readonly string $fullName,
        private readonly string $email,
        private readonly string $phone
    ) {
        $this->validateFullName($fullName);
        $this->validateEmail($email);
        $this->validatePhone($phone);
    }
    
    public static function create(
        string $fullName,
        string $email,
        string $phone
    ): self {
        return new self($fullName, $email, $phone);
    }
    
    public static function fromName(string $fullName): self
    {
        // Extract email from name if possible (e.g., "John Doe <john@example.com>")
        if (preg_match('/<([^>]+@[^>]+)>/', $fullName, $matches)) {
            $email = $matches[1];
            $fullName = trim(str_replace('<' . $email . '>', '', $fullName));
        } else {
            // Generate default email from name
            $cleanedName = trim($fullName);
            
            // Transliterate Russian names for email
            $translit = [
                'а' => 'a', 'б' => 'b', 'в' => 'v', 'г' => 'g', 'д' => 'd',
                'е' => 'e', 'ё' => 'e', 'ж' => 'zh', 'з' => 'z', 'и' => 'i',
                'й' => 'y', 'к' => 'k', 'л' => 'l', 'м' => 'm', 'н' => 'n',
                'о' => 'o', 'п' => 'p', 'р' => 'r', 'с' => 's', 'т' => 't',
                'у' => 'u', 'ф' => 'f', 'х' => 'h', 'ц' => 'ts', 'ч' => 'ch',
                'ш' => 'sh', 'щ' => 'sch', 'ъ' => '', 'ы' => 'y', 'ь' => '',
                'э' => 'e', 'ю' => 'yu', 'я' => 'ya',
                'А' => 'A', 'Б' => 'B', 'В' => 'V', 'Г' => 'G', 'Д' => 'D',
                'Е' => 'E', 'Ё' => 'E', 'Ж' => 'Zh', 'З' => 'Z', 'И' => 'I',
                'Й' => 'Y', 'К' => 'K', 'Л' => 'L', 'М' => 'M', 'Н' => 'N',
                'О' => 'O', 'П' => 'P', 'Р' => 'R', 'С' => 'S', 'Т' => 'T',
                'У' => 'U', 'Ф' => 'F', 'Х' => 'H', 'Ц' => 'Ts', 'Ч' => 'Ch',
                'Ш' => 'Sh', 'Щ' => 'Sch', 'Ъ' => '', 'Ы' => 'Y', 'Ь' => '',
                'Э' => 'E', 'Ю' => 'Yu', 'Я' => 'Ya'
            ];
            
            $translitName = strtr($cleanedName, $translit);
            // Remove dots from abbreviations and clean up
            $translitName = str_replace('.', '', $translitName);
            $nameParts = preg_split('/\s+/', trim($translitName));
            $nameParts = array_filter($nameParts);
            
            if (count($nameParts) > 0) {
                $emailName = strtolower(implode('.', $nameParts));
                // Remove any non-alphanumeric characters except dots
                $emailName = preg_replace('/[^a-z0-9.]/', '', $emailName);
                $email = $emailName . '@company.local';
            } else {
                $email = 'unknown@company.local';
            }
        }
        
        // Default phone number
        $phone = '+7(000)000-00-00';
        
        return new self($fullName, $email, $phone);
    }

    private function validateFullName(string $fullName): void
    {
        if (empty(trim($fullName))) {
            throw new InvalidPersonalInfoException('Full name cannot be empty');
        }
        
        if (strlen($fullName) > 255) {
            throw new InvalidPersonalInfoException('Full name is too long');
        }
        
        if (!preg_match('/^[\p{L}\s\.\-\']+$/u', $fullName)) {
            throw new InvalidPersonalInfoException('Full name contains invalid characters');
        }
    }

    private function validateEmail(string $email): void
    {
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            throw new InvalidPersonalInfoException('Invalid email format');
        }
    }

    private function validatePhone(string $phone): void
    {
        // Allow various phone formats
        if (!preg_match('/^[\+\d\s\(\)\-\.]+$/', $phone)) {
            throw new InvalidPersonalInfoException('Invalid phone format');
        }
        
        // Extract only digits
        $digits = preg_replace('/[^\d]/', '', $phone);
        if (strlen($digits) < 10 || strlen($digits) > 15) {
            throw new InvalidPersonalInfoException('Phone number must contain 10-15 digits');
        }
    }

    public function getFullName(): string
    {
        return $this->fullName;
    }

    public function getEmail(): string
    {
        return $this->email;
    }

    public function getPhone(): string
    {
        return $this->phone;
    }

    public function getFirstName(): string
    {
        $parts = explode(' ', $this->fullName);
        return $parts[1] ?? $parts[0];
    }

    public function getLastName(): string
    {
        $parts = explode(' ', $this->fullName);
        return $parts[0];
    }

    public function getMiddleName(): ?string
    {
        $parts = explode(' ', $this->fullName);
        return $parts[2] ?? null;
    }

    public function equals(PersonalInfo $other): bool
    {
        return $this->fullName === $other->fullName
            && $this->email === $other->email
            && $this->phone === $other->phone;
    }
} 