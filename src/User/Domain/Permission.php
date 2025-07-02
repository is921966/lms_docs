<?php

declare(strict_types=1);

namespace User\Domain;

/**
 * Permission entity
 */
class Permission
{
    private int $id;
    private string $name;
    private string $displayName;
    private ?string $description;
    private string $category;
    private \DateTimeImmutable $createdAt;
    
    /**
     * Permission categories
     */
    public const CATEGORY_USER = 'user';
    public const CATEGORY_COMPETENCY = 'competency';
    public const CATEGORY_POSITION = 'position';
    public const CATEGORY_COURSE = 'course';
    public const CATEGORY_PROGRAM = 'program';
    public const CATEGORY_ANALYTICS = 'analytics';
    public const CATEGORY_SYSTEM = 'system';
    
    /**
     * Common permissions
     */
    public const USER_VIEW = 'user.view';
    public const USER_CREATE = 'user.create';
    public const USER_UPDATE = 'user.update';
    public const USER_DELETE = 'user.delete';
    public const USER_MANAGE_ROLES = 'user.manage_roles';
    
    public const COMPETENCY_VIEW = 'competency.view';
    public const COMPETENCY_CREATE = 'competency.create';
    public const COMPETENCY_UPDATE = 'competency.update';
    public const COMPETENCY_DELETE = 'competency.delete';
    public const COMPETENCY_ASSESS = 'competency.assess';
    
    public const POSITION_VIEW = 'position.view';
    public const POSITION_CREATE = 'position.create';
    public const POSITION_UPDATE = 'position.update';
    public const POSITION_DELETE = 'position.delete';
    
    public const COURSE_VIEW = 'course.view';
    public const COURSE_CREATE = 'course.create';
    public const COURSE_UPDATE = 'course.update';
    public const COURSE_DELETE = 'course.delete';
    public const COURSE_PUBLISH = 'course.publish';
    public const COURSE_ENROLL = 'course.enroll';
    public const COURSE_MANAGE_ENROLLMENTS = 'course.manage_enrollments';
    
    public const PROGRAM_VIEW = 'program.view';
    public const PROGRAM_CREATE = 'program.create';
    public const PROGRAM_UPDATE = 'program.update';
    public const PROGRAM_DELETE = 'program.delete';
    public const PROGRAM_ASSIGN = 'program.assign';
    
    public const ANALYTICS_VIEW = 'analytics.view';
    public const ANALYTICS_EXPORT = 'analytics.export';
    
    public const SYSTEM_MANAGE = 'system.manage';
    public const SYSTEM_AUDIT = 'system.audit';
    
    private function __construct(
        string $name,
        string $displayName,
        string $category,
        ?string $description = null
    ) {
        self::validateName($name);
        self::validateCategory($category);
        
        $this->name = $name;
        $this->displayName = $displayName;
        $this->category = $category;
        $this->description = $description;
        $this->createdAt = new \DateTimeImmutable();
    }
    
    /**
     * Create new permission
     */
    public static function create(
        string $name,
        string $displayName,
        string $category,
        ?string $description = null
    ): self {
        return new self($name, $displayName, $category, $description);
    }
    
    /**
     * Check if permission matches pattern
     */
    public function matches(string $pattern): bool
    {
        // Exact match
        if ($this->name === $pattern) {
            return true;
        }
        
        // Wildcard match (e.g., 'user.*' matches 'user.view', 'user.create', etc.)
        if (str_ends_with($pattern, '*')) {
            $prefix = rtrim($pattern, '*');
            return str_starts_with($this->name, $prefix);
        }
        
        return false;
    }
    
    /**
     * Check if permission is in category
     */
    public function isInCategory(string $category): bool
    {
        return $this->category === $category;
    }
    
    /**
     * Get permission resource
     */
    public function getResource(): string
    {
        $parts = explode('.', $this->name);
        return $parts[0] ?? '';
    }
    
    /**
     * Get permission action
     */
    public function getAction(): string
    {
        $parts = explode('.', $this->name);
        return $parts[1] ?? '';
    }
    
    /**
     * Validate permission name
     */
    private static function validateName(string $name): void
    {
        if (!preg_match('/^[a-z]+(\.[a-z_]+)+$/', $name)) {
            throw new \InvalidArgumentException(
                'Permission name must be in format: resource.action (e.g., user.view)'
            );
        }
    }
    
    /**
     * Validate category
     */
    private static function validateCategory(string $category): void
    {
        $validCategories = [
            self::CATEGORY_USER,
            self::CATEGORY_COMPETENCY,
            self::CATEGORY_POSITION,
            self::CATEGORY_COURSE,
            self::CATEGORY_PROGRAM,
            self::CATEGORY_ANALYTICS,
            self::CATEGORY_SYSTEM,
        ];
        
        if (!in_array($category, $validCategories, true)) {
            throw new \InvalidArgumentException(
                sprintf('Invalid permission category: %s', $category)
            );
        }
    }
    
    /**
     * Get all default permissions
     */
    public static function getDefaultPermissions(): array
    {
        return [
            // User permissions
            ['name' => self::USER_VIEW, 'displayName' => 'View users', 'category' => self::CATEGORY_USER],
            ['name' => self::USER_CREATE, 'displayName' => 'Create users', 'category' => self::CATEGORY_USER],
            ['name' => self::USER_UPDATE, 'displayName' => 'Update users', 'category' => self::CATEGORY_USER],
            ['name' => self::USER_DELETE, 'displayName' => 'Delete users', 'category' => self::CATEGORY_USER],
            ['name' => self::USER_MANAGE_ROLES, 'displayName' => 'Manage user roles', 'category' => self::CATEGORY_USER],
            
            // Competency permissions
            ['name' => self::COMPETENCY_VIEW, 'displayName' => 'View competencies', 'category' => self::CATEGORY_COMPETENCY],
            ['name' => self::COMPETENCY_CREATE, 'displayName' => 'Create competencies', 'category' => self::CATEGORY_COMPETENCY],
            ['name' => self::COMPETENCY_UPDATE, 'displayName' => 'Update competencies', 'category' => self::CATEGORY_COMPETENCY],
            ['name' => self::COMPETENCY_DELETE, 'displayName' => 'Delete competencies', 'category' => self::CATEGORY_COMPETENCY],
            ['name' => self::COMPETENCY_ASSESS, 'displayName' => 'Assess competencies', 'category' => self::CATEGORY_COMPETENCY],
            
            // Position permissions
            ['name' => self::POSITION_VIEW, 'displayName' => 'View positions', 'category' => self::CATEGORY_POSITION],
            ['name' => self::POSITION_CREATE, 'displayName' => 'Create positions', 'category' => self::CATEGORY_POSITION],
            ['name' => self::POSITION_UPDATE, 'displayName' => 'Update positions', 'category' => self::CATEGORY_POSITION],
            ['name' => self::POSITION_DELETE, 'displayName' => 'Delete positions', 'category' => self::CATEGORY_POSITION],
            
            // Course permissions
            ['name' => self::COURSE_VIEW, 'displayName' => 'View courses', 'category' => self::CATEGORY_COURSE],
            ['name' => self::COURSE_CREATE, 'displayName' => 'Create courses', 'category' => self::CATEGORY_COURSE],
            ['name' => self::COURSE_UPDATE, 'displayName' => 'Update courses', 'category' => self::CATEGORY_COURSE],
            ['name' => self::COURSE_DELETE, 'displayName' => 'Delete courses', 'category' => self::CATEGORY_COURSE],
            ['name' => self::COURSE_PUBLISH, 'displayName' => 'Publish courses', 'category' => self::CATEGORY_COURSE],
            ['name' => self::COURSE_ENROLL, 'displayName' => 'Enroll in courses', 'category' => self::CATEGORY_COURSE],
            ['name' => self::COURSE_MANAGE_ENROLLMENTS, 'displayName' => 'Manage course enrollments', 'category' => self::CATEGORY_COURSE],
            
            // Program permissions
            ['name' => self::PROGRAM_VIEW, 'displayName' => 'View programs', 'category' => self::CATEGORY_PROGRAM],
            ['name' => self::PROGRAM_CREATE, 'displayName' => 'Create programs', 'category' => self::CATEGORY_PROGRAM],
            ['name' => self::PROGRAM_UPDATE, 'displayName' => 'Update programs', 'category' => self::CATEGORY_PROGRAM],
            ['name' => self::PROGRAM_DELETE, 'displayName' => 'Delete programs', 'category' => self::CATEGORY_PROGRAM],
            ['name' => self::PROGRAM_ASSIGN, 'displayName' => 'Assign programs', 'category' => self::CATEGORY_PROGRAM],
            
            // Analytics permissions
            ['name' => self::ANALYTICS_VIEW, 'displayName' => 'View analytics', 'category' => self::CATEGORY_ANALYTICS],
            ['name' => self::ANALYTICS_EXPORT, 'displayName' => 'Export analytics', 'category' => self::CATEGORY_ANALYTICS],
            
            // System permissions
            ['name' => self::SYSTEM_MANAGE, 'displayName' => 'Manage system settings', 'category' => self::CATEGORY_SYSTEM],
            ['name' => self::SYSTEM_AUDIT, 'displayName' => 'View audit logs', 'category' => self::CATEGORY_SYSTEM],
        ];
    }
    
    // Getters
    
    public function getId(): int
    {
        return $this->id;
    }
    
    public function getName(): string
    {
        return $this->name;
    }
    
    public function getDisplayName(): string
    {
        return $this->displayName;
    }
    
    public function getDescription(): ?string
    {
        return $this->description;
    }
    
    public function getCategory(): string
    {
        return $this->category;
    }
    
    public function getCreatedAt(): \DateTimeImmutable
    {
        return $this->createdAt;
    }
} 