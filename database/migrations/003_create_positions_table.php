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
        // Position sections (departments/divisions)
        Schema::create('position_sections', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('code')->unique();
            $table->text('description')->nullable();
            $table->unsignedBigInteger('parent_id')->nullable();
            $table->integer('sort_order')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            
            $table->index('code');
            $table->index('parent_id');
            $table->index('is_active');
            $table->index('sort_order');
            
            $table->foreign('parent_id')->references('id')->on('position_sections')->nullOnDelete();
        });
        
        // Positions
        Schema::create('positions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('section_id')->constrained('position_sections')->cascadeOnDelete();
            $table->string('title');
            $table->string('code')->unique();
            $table->text('description')->nullable();
            $table->text('responsibilities')->nullable();
            $table->text('requirements')->nullable();
            $table->enum('level', ['junior', 'middle', 'senior', 'lead', 'expert']);
            $table->integer('grade')->nullable();
            $table->boolean('is_managerial')->default(false);
            $table->boolean('is_active')->default(true);
            $table->json('metadata')->nullable();
            $table->timestamps();
            
            $table->index('code');
            $table->index('section_id');
            $table->index('level');
            $table->index('grade');
            $table->index('is_managerial');
            $table->index('is_active');
        });
        
        // Add foreign key to users table
        Schema::table('users', function (Blueprint $table) {
            $table->foreign('position_id')->references('id')->on('positions')->nullOnDelete();
        });
        
        // Career paths
        Schema::create('career_paths', function (Blueprint $table) {
            $table->id();
            $table->foreignId('from_position_id')->constrained('positions')->cascadeOnDelete();
            $table->foreignId('to_position_id')->constrained('positions')->cascadeOnDelete();
            $table->enum('path_type', ['vertical', 'horizontal', 'diagonal']);
            $table->integer('typical_years')->nullable();
            $table->text('requirements')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            
            $table->unique(['from_position_id', 'to_position_id']);
            $table->index('from_position_id');
            $table->index('to_position_id');
            $table->index('path_type');
            $table->index('is_active');
        });
        
        // Career path competency gaps
        Schema::create('career_path_gaps', function (Blueprint $table) {
            $table->id();
            $table->foreignId('career_path_id')->constrained()->cascadeOnDelete();
            $table->foreignId('competency_id')->constrained()->cascadeOnDelete();
            $table->integer('from_level');
            $table->integer('to_level');
            $table->boolean('is_critical')->default(false);
            $table->timestamps();
            
            $table->index('career_path_id');
            $table->index('competency_id');
        });
        
        // Position history
        Schema::create('position_histories', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('position_id')->constrained()->cascadeOnDelete();
            $table->date('start_date');
            $table->date('end_date')->nullable();
            $table->enum('change_type', ['promotion', 'transfer', 'demotion', 'restructure']);
            $table->text('notes')->nullable();
            $table->timestamps();
            
            $table->index(['user_id', 'start_date']);
            $table->index('position_id');
            $table->index('change_type');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Remove foreign key from users table
        Schema::table('users', function (Blueprint $table) {
            $table->dropForeign(['position_id']);
        });
        
        Schema::dropIfExists('position_histories');
        Schema::dropIfExists('career_path_gaps');
        Schema::dropIfExists('career_paths');
        Schema::dropIfExists('positions');
        Schema::dropIfExists('position_sections');
    }
}; 