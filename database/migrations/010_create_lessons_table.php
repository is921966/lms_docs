<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('lessons', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('module_id');
            $table->string('title');
            $table->text('description')->nullable();
            $table->enum('content_type', ['video', 'text', 'quiz', 'assignment', 'document']);
            $table->json('content_data');
            $table->integer('order_index');
            $table->integer('duration_minutes');
            $table->integer('passing_score')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamps();
            
            // Foreign keys
            $table->foreign('module_id')
                ->references('id')
                ->on('modules')
                ->onDelete('cascade');
            
            // Indexes
            $table->index(['module_id', 'order_index']);
            $table->index('content_type');
        });
    }
    
    public function down(): void
    {
        Schema::dropIfExists('lessons');
    }
}; 