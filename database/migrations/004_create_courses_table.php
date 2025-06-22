<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Course categories
        Schema::create('course_categories', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('slug')->unique();
            $table->text('description')->nullable();
            $table->string('icon')->nullable();
            $table->integer('sort_order')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            
            $table->index('slug');
            $table->index('is_active');
            $table->index('sort_order');
        });
        
        // Courses
        Schema::create('courses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('category_id')->constrained('course_categories')->cascadeOnDelete();
            $table->string('title');
            $table->string('code')->unique();
            $table->text('description');
            $table->text('objectives')->nullable();
            $table->text('target_audience')->nullable();
            $table->string('cover_image')->nullable();
            $table->enum('type', ['online', 'offline', 'blended', 'webinar']);
            $table->enum('difficulty', ['beginner', 'intermediate', 'advanced', 'expert']);
            $table->integer('duration_hours');
            $table->decimal('passing_score', 5, 2)->default(70.00);
            $table->boolean('is_mandatory')->default(false);
            $table->boolean('is_active')->default(true);
            $table->boolean('is_published')->default(false);
            $table->foreignId('created_by')->constrained('users')->cascadeOnDelete();
            $table->json('metadata')->nullable();
            $table->timestamp('published_at')->nullable();
            $table->timestamps();
            
            $table->index('code');
            $table->index('category_id');
            $table->index('type');
            $table->index('difficulty');
            $table->index('is_mandatory');
            $table->index('is_active');
            $table->index('is_published');
            $table->index('created_by');
        });
        
        // Course modules
        Schema::create('course_modules', function (Blueprint $table) {
            $table->id();
            $table->foreignId('course_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->text('description')->nullable();
            $table->integer('sort_order')->default(0);
            $table->integer('duration_minutes')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            
            $table->index(['course_id', 'sort_order']);
            $table->index('is_active');
        });
        
        // Course lessons
        Schema::create('course_lessons', function (Blueprint $table) {
            $table->id();
            $table->foreignId('module_id')->constrained('course_modules')->cascadeOnDelete();
            $table->string('title');
            $table->text('content')->nullable();
            $table->enum('type', ['video', 'text', 'presentation', 'document', 'quiz', 'assignment']);
            $table->string('resource_url')->nullable();
            $table->integer('duration_minutes')->nullable();
            $table->integer('sort_order')->default(0);
            $table->boolean('is_active')->default(true);
            $table->json('metadata')->nullable();
            $table->timestamps();
            
            $table->index(['module_id', 'sort_order']);
            $table->index('type');
            $table->index('is_active');
        });
        
        // Course materials
        Schema::create('course_materials', function (Blueprint $table) {
            $table->id();
            $table->foreignId('course_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->text('description')->nullable();
            $table->enum('type', ['document', 'video', 'link', 'archive']);
            $table->string('file_path')->nullable();
            $table->string('url')->nullable();
            $table->integer('file_size')->nullable();
            $table->boolean('is_downloadable')->default(true);
            $table->timestamps();
            
            $table->index('course_id');
            $table->index('type');
        });
        
        // Course competencies
        Schema::create('course_competencies', function (Blueprint $table) {
            $table->id();
            $table->foreignId('course_id')->constrained()->cascadeOnDelete();
            $table->foreignId('competency_id')->constrained()->cascadeOnDelete();
            $table->integer('target_level');
            $table->timestamps();
            
            $table->unique(['course_id', 'competency_id']);
            $table->index('course_id');
            $table->index('competency_id');
        });
        
        // Course enrollments
        Schema::create('course_enrollments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('course_id')->constrained()->cascadeOnDelete();
            $table->enum('status', ['enrolled', 'in_progress', 'completed', 'failed', 'cancelled']);
            $table->decimal('progress', 5, 2)->default(0.00);
            $table->decimal('score', 5, 2)->nullable();
            $table->timestamp('enrolled_at');
            $table->timestamp('started_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamp('expires_at')->nullable();
            $table->integer('attempts')->default(0);
            $table->json('metadata')->nullable();
            $table->timestamps();
            
            $table->unique(['user_id', 'course_id']);
            $table->index(['user_id', 'status']);
            $table->index('course_id');
            $table->index('status');
            $table->index('enrolled_at');
            $table->index('completed_at');
        });
        
        // Lesson progress
        Schema::create('lesson_progress', function (Blueprint $table) {
            $table->id();
            $table->foreignId('enrollment_id')->constrained('course_enrollments')->cascadeOnDelete();
            $table->foreignId('lesson_id')->constrained('course_lessons')->cascadeOnDelete();
            $table->enum('status', ['not_started', 'in_progress', 'completed']);
            $table->integer('time_spent_seconds')->default(0);
            $table->timestamp('started_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamps();
            
            $table->unique(['enrollment_id', 'lesson_id']);
            $table->index('enrollment_id');
            $table->index('lesson_id');
            $table->index('status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('lesson_progress');
        Schema::dropIfExists('course_enrollments');
        Schema::dropIfExists('course_competencies');
        Schema::dropIfExists('course_materials');
        Schema::dropIfExists('course_lessons');
        Schema::dropIfExists('course_modules');
        Schema::dropIfExists('courses');
        Schema::dropIfExists('course_categories');
    }
}; 