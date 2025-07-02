<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('courses', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('course_code', 50)->unique();
            $table->string('title');
            $table->text('description');
            $table->enum('status', ['draft', 'under_review', 'published', 'archived'])
                ->default('draft');
            $table->integer('duration_minutes');
            $table->json('metadata')->nullable();
            $table->timestamp('published_at')->nullable();
            $table->timestamps();
            $table->softDeletes();
            
            // Indexes
            $table->index('status');
            $table->index('published_at');
            $table->index('created_at');
        });
    }
    
    public function down(): void
    {
        Schema::dropIfExists('courses');
    }
}; 