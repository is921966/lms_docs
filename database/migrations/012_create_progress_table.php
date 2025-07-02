<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('progress', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('enrollment_id');
            $table->uuid('lesson_id');
            $table->enum('status', ['not_started', 'in_progress', 'completed', 'failed'])
                ->default('not_started');
            $table->timestamp('started_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->integer('time_spent_seconds')->default(0);
            $table->integer('attempts')->default(0);
            $table->decimal('score', 5, 2)->nullable();
            $table->json('submission_data')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamps();
            
            // Foreign keys
            $table->foreign('enrollment_id')
                ->references('id')
                ->on('enrollments')
                ->onDelete('cascade');
            
            $table->foreign('lesson_id')
                ->references('id')
                ->on('lessons')
                ->onDelete('cascade');
            
            // Indexes
            $table->unique(['enrollment_id', 'lesson_id']);
            $table->index('status');
            $table->index('completed_at');
        });
    }
    
    public function down(): void
    {
        Schema::dropIfExists('progress');
    }
}; 