<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('enrollments', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('user_id');
            $table->uuid('course_id');
            $table->uuid('enrolled_by');
            $table->enum('enrollment_type', ['voluntary', 'mandatory', 'recommended'])
                ->default('voluntary');
            $table->enum('status', ['active', 'completed', 'suspended', 'cancelled'])
                ->default('active');
            $table->timestamp('enrolled_at');
            $table->timestamp('started_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamp('expires_at')->nullable();
            $table->decimal('progress_percentage', 5, 2)->default(0);
            $table->json('metadata')->nullable();
            $table->timestamps();
            
            // Foreign keys
            $table->foreign('user_id')
                ->references('id')
                ->on('users')
                ->onDelete('cascade');
            
            $table->foreign('course_id')
                ->references('id')
                ->on('courses')
                ->onDelete('cascade');
            
            $table->foreign('enrolled_by')
                ->references('id')
                ->on('users')
                ->onDelete('restrict');
            
            // Indexes
            $table->unique(['user_id', 'course_id']);
            $table->index('status');
            $table->index('enrolled_at');
            $table->index('completed_at');
        });
    }
    
    public function down(): void
    {
        Schema::dropIfExists('enrollments');
    }
}; 