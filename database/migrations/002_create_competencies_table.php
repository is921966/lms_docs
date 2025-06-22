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
        // Competency categories
        Schema::create('competency_categories', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('slug')->unique();
            $table->text('description')->nullable();
            $table->string('color', 7)->default('#000000');
            $table->integer('sort_order')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            
            $table->index('slug');
            $table->index('is_active');
            $table->index('sort_order');
        });
        
        // Competencies
        Schema::create('competencies', function (Blueprint $table) {
            $table->id();
            $table->foreignId('category_id')->constrained('competency_categories')->cascadeOnDelete();
            $table->string('name');
            $table->string('code')->unique();
            $table->text('description')->nullable();
            $table->enum('type', ['hard', 'soft', 'digital'])->default('hard');
            $table->integer('max_level')->default(5);
            $table->json('level_descriptions')->nullable();
            $table->boolean('is_required')->default(false);
            $table->boolean('is_active')->default(true);
            $table->json('metadata')->nullable();
            $table->timestamps();
            
            $table->index('code');
            $table->index('category_id');
            $table->index('type');
            $table->index('is_required');
            $table->index('is_active');
        });
        
        // User competencies
        Schema::create('user_competencies', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('competency_id')->constrained()->cascadeOnDelete();
            $table->integer('current_level')->default(0);
            $table->integer('target_level')->nullable();
            $table->date('achieved_at')->nullable();
            $table->date('expires_at')->nullable();
            $table->foreignId('assessed_by')->nullable()->constrained('users')->nullOnDelete();
            $table->text('assessment_notes')->nullable();
            $table->enum('status', ['active', 'expired', 'pending'])->default('active');
            $table->timestamps();
            
            $table->unique(['user_id', 'competency_id']);
            $table->index(['user_id', 'status']);
            $table->index('competency_id');
            $table->index('achieved_at');
            $table->index('expires_at');
        });
        
        // Competency assessments history
        Schema::create('competency_assessments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('competency_id')->constrained()->cascadeOnDelete();
            $table->integer('previous_level');
            $table->integer('new_level');
            $table->foreignId('assessed_by')->constrained('users')->cascadeOnDelete();
            $table->enum('assessment_type', ['self', 'manager', 'test', 'course', 'external']);
            $table->text('notes')->nullable();
            $table->json('evidence')->nullable();
            $table->timestamp('assessed_at');
            $table->timestamps();
            
            $table->index(['user_id', 'competency_id']);
            $table->index('assessed_by');
            $table->index('assessment_type');
            $table->index('assessed_at');
        });
        
        // Position competencies (requirements)
        Schema::create('position_competencies', function (Blueprint $table) {
            $table->id();
            $table->foreignId('position_id')->constrained()->cascadeOnDelete();
            $table->foreignId('competency_id')->constrained()->cascadeOnDelete();
            $table->integer('required_level');
            $table->boolean('is_critical')->default(false);
            $table->timestamps();
            
            $table->unique(['position_id', 'competency_id']);
            $table->index('position_id');
            $table->index('competency_id');
            $table->index('is_critical');
        });
        
        // Competency development activities
        Schema::create('competency_activities', function (Blueprint $table) {
            $table->id();
            $table->foreignId('competency_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->text('description')->nullable();
            $table->enum('type', ['course', 'book', 'article', 'video', 'practice', 'mentoring', 'other']);
            $table->string('url')->nullable();
            $table->integer('estimated_hours')->nullable();
            $table->integer('from_level');
            $table->integer('to_level');
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            
            $table->index('competency_id');
            $table->index('type');
            $table->index(['from_level', 'to_level']);
            $table->index('is_active');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('competency_activities');
        Schema::dropIfExists('position_competencies');
        Schema::dropIfExists('competency_assessments');
        Schema::dropIfExists('user_competencies');
        Schema::dropIfExists('competencies');
        Schema::dropIfExists('competency_categories');
    }
}; 