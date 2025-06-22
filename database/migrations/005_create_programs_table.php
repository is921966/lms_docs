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
        // Program types
        Schema::create('program_types', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('code')->unique();
            $table->text('description')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            
            $table->index('code');
            $table->index('is_active');
        });
        
        // Development programs
        Schema::create('programs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('type_id')->constrained('program_types')->cascadeOnDelete();
            $table->string('name');
            $table->string('code')->unique();
            $table->text('description');
            $table->text('objectives')->nullable();
            $table->enum('target', ['all', 'new_employees', 'managers', 'specialists', 'custom']);
            $table->integer('duration_days');
            $table->boolean('is_mandatory')->default(false);
            $table->boolean('is_active')->default(true);
            $table->foreignId('created_by')->constrained('users')->cascadeOnDelete();
            $table->json('metadata')->nullable();
            $table->timestamps();
            
            $table->index('code');
            $table->index('type_id');
            $table->index('target');
            $table->index('is_mandatory');
            $table->index('is_active');
        });
        
        // Program stages
        Schema::create('program_stages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('program_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->text('description')->nullable();
            $table->integer('sort_order')->default(0);
            $table->integer('duration_days');
            $table->boolean('is_sequential')->default(true);
            $table->timestamps();
            
            $table->index(['program_id', 'sort_order']);
        });
        
        // Program activities
        Schema::create('program_activities', function (Blueprint $table) {
            $table->id();
            $table->foreignId('stage_id')->constrained('program_stages')->cascadeOnDelete();
            $table->string('name');
            $table->text('description')->nullable();
            $table->enum('type', ['course', 'meeting', 'task', 'assessment', 'document', 'external']);
            $table->morphs('activityable'); // Polymorphic relation to course, task, etc.
            $table->integer('sort_order')->default(0);
            $table->integer('day_offset')->default(0); // Days from stage start
            $table->boolean('is_mandatory')->default(true);
            $table->json('metadata')->nullable();
            $table->timestamps();
            
            $table->index(['stage_id', 'sort_order']);
            $table->index('type');
            $table->index('is_mandatory');
        });
        
        // Program enrollments
        Schema::create('program_enrollments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('program_id')->constrained()->cascadeOnDelete();
            $table->foreignId('assigned_by')->nullable()->constrained('users')->nullOnDelete();
            $table->enum('status', ['assigned', 'in_progress', 'completed', 'cancelled', 'expired']);
            $table->decimal('progress', 5, 2)->default(0.00);
            $table->date('start_date');
            $table->date('due_date');
            $table->date('completed_date')->nullable();
            $table->text('notes')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamps();
            
            $table->unique(['user_id', 'program_id']);
            $table->index(['user_id', 'status']);
            $table->index('program_id');
            $table->index('status');
            $table->index('start_date');
            $table->index('due_date');
        });
        
        // Program activity progress
        Schema::create('program_activity_progress', function (Blueprint $table) {
            $table->id();
            $table->foreignId('enrollment_id')->constrained('program_enrollments')->cascadeOnDelete();
            $table->foreignId('activity_id')->constrained('program_activities')->cascadeOnDelete();
            $table->enum('status', ['pending', 'in_progress', 'completed', 'skipped']);
            $table->timestamp('started_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->json('result')->nullable();
            $table->timestamps();
            
            $table->unique(['enrollment_id', 'activity_id']);
            $table->index('enrollment_id');
            $table->index('activity_id');
            $table->index('status');
        });
        
        // Onboarding templates
        Schema::create('onboarding_templates', function (Blueprint $table) {
            $table->id();
            $table->foreignId('program_id')->constrained()->cascadeOnDelete();
            $table->foreignId('position_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('section_id')->nullable()->constrained('position_sections')->nullOnDelete();
            $table->string('name');
            $table->boolean('is_default')->default(false);
            $table->boolean('is_active')->default(true);
            $table->json('metadata')->nullable();
            $table->timestamps();
            
            $table->index('program_id');
            $table->index('position_id');
            $table->index('section_id');
            $table->index('is_default');
            $table->index('is_active');
        });
        
        // Mentorship assignments
        Schema::create('mentorships', function (Blueprint $table) {
            $table->id();
            $table->foreignId('mentee_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('mentor_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('program_enrollment_id')->nullable()->constrained()->nullOnDelete();
            $table->date('start_date');
            $table->date('end_date')->nullable();
            $table->enum('status', ['active', 'completed', 'cancelled']);
            $table->text('goals')->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();
            
            $table->index(['mentee_id', 'status']);
            $table->index(['mentor_id', 'status']);
            $table->index('program_enrollment_id');
            $table->index('status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('mentorships');
        Schema::dropIfExists('onboarding_templates');
        Schema::dropIfExists('program_activity_progress');
        Schema::dropIfExists('program_enrollments');
        Schema::dropIfExists('program_activities');
        Schema::dropIfExists('program_stages');
        Schema::dropIfExists('programs');
        Schema::dropIfExists('program_types');
    }
}; 