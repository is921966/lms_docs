<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class ProductionSeeder extends Seeder
{
    /**
     * Seed the production database with initial data.
     */
    public function run(): void
    {
        // Create admin user
        $adminId = Str::uuid();
        DB::table('users')->insertOrIgnore([
            'id' => $adminId,
            'email' => 'admin@lms.company.ru',
            'password' => Hash::make('Admin123!'),
            'first_name' => 'System',
            'last_name' => 'Administrator',
            'display_name' => 'Admin',
            'is_admin' => true,
            'status' => 'active',
            'email_verified_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Create demo student user
        $studentId = Str::uuid();
        DB::table('users')->insertOrIgnore([
            'id' => $studentId,
            'email' => 'student@lms.company.ru',
            'password' => Hash::make('Student123!'),
            'first_name' => 'Demo',
            'last_name' => 'Student',
            'display_name' => 'Student',
            'is_admin' => false,
            'status' => 'active',
            'email_verified_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Create basic competency categories
        $techCategoryId = Str::uuid();
        DB::table('competency_categories')->insertOrIgnore([
            'id' => $techCategoryId,
            'name' => 'Technical Skills',
            'slug' => 'technical-skills',
            'description' => 'Technical competencies required for IT positions',
            'color' => '#3B82F6',
            'icon' => 'cpu',
            'order' => 1,
            'is_active' => true,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $softCategoryId = Str::uuid();
        DB::table('competency_categories')->insertOrIgnore([
            'id' => $softCategoryId,
            'name' => 'Soft Skills',
            'slug' => 'soft-skills',
            'description' => 'Interpersonal and communication skills',
            'color' => '#10B981',
            'icon' => 'users',
            'order' => 2,
            'is_active' => true,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Create sample competencies
        $competencies = [
            [
                'name' => 'Swift Programming',
                'category_id' => $techCategoryId,
                'description' => 'iOS development using Swift',
                'color' => '#FF6B6B',
            ],
            [
                'name' => 'PHP Development',
                'category_id' => $techCategoryId,
                'description' => 'Backend development with PHP',
                'color' => '#4ECDC4',
            ],
            [
                'name' => 'Team Collaboration',
                'category_id' => $softCategoryId,
                'description' => 'Working effectively in teams',
                'color' => '#45B7D1',
            ],
            [
                'name' => 'Communication',
                'category_id' => $softCategoryId,
                'description' => 'Clear and effective communication',
                'color' => '#96CEB4',
            ],
        ];

        foreach ($competencies as $index => $competency) {
            DB::table('competencies')->insertOrIgnore([
                'id' => Str::uuid(),
                'name' => $competency['name'],
                'category_id' => $competency['category_id'],
                'description' => $competency['description'],
                'color' => $competency['color'],
                'order' => $index + 1,
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        // Create sample positions
        $positions = [
            [
                'title' => 'iOS Developer',
                'department' => 'IT',
                'level' => 'middle',
                'description' => 'Mobile application developer for iOS platform',
            ],
            [
                'title' => 'Backend Developer',
                'department' => 'IT',
                'level' => 'senior',
                'description' => 'Server-side application developer',
            ],
            [
                'title' => 'HR Manager',
                'department' => 'HR',
                'level' => 'middle',
                'description' => 'Human resources management',
            ],
        ];

        foreach ($positions as $index => $position) {
            DB::table('positions')->insertOrIgnore([
                'id' => Str::uuid(),
                'title' => $position['title'],
                'department' => $position['department'],
                'level' => $position['level'],
                'description' => $position['description'],
                'order' => $index + 1,
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        // Create sample courses
        $courses = [
            [
                'title' => 'Introduction to Swift',
                'description' => 'Learn the basics of Swift programming',
                'type' => 'video',
                'duration_hours' => 8,
                'difficulty' => 'beginner',
            ],
            [
                'title' => 'Advanced iOS Development',
                'description' => 'Master advanced iOS development techniques',
                'type' => 'course',
                'duration_hours' => 24,
                'difficulty' => 'advanced',
            ],
            [
                'title' => 'PHP Backend Basics',
                'description' => 'Introduction to PHP backend development',
                'type' => 'pdf',
                'duration_hours' => 12,
                'difficulty' => 'beginner',
            ],
            [
                'title' => 'Team Leadership',
                'description' => 'Essential leadership skills for team management',
                'type' => 'workshop',
                'duration_hours' => 6,
                'difficulty' => 'intermediate',
            ],
        ];

        foreach ($courses as $index => $course) {
            DB::table('courses')->insertOrIgnore([
                'id' => Str::uuid(),
                'title' => $course['title'],
                'slug' => Str::slug($course['title']),
                'description' => $course['description'],
                'type' => $course['type'],
                'duration_hours' => $course['duration_hours'],
                'difficulty' => $course['difficulty'],
                'status' => 'published',
                'created_by' => $adminId,
                'order' => $index + 1,
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        // Create onboarding program
        $onboardingId = Str::uuid();
        DB::table('programs')->insertOrIgnore([
            'id' => $onboardingId,
            'title' => 'New Employee Onboarding',
            'slug' => 'new-employee-onboarding',
            'description' => 'Complete onboarding program for new employees',
            'type' => 'onboarding',
            'duration_days' => 30,
            'status' => 'active',
            'created_by' => $adminId,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $this->command->info('Production database seeded successfully!');
    }
} 