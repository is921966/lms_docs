<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('modules', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('course_id');
            $table->string('title');
            $table->text('description')->nullable();
            $table->integer('order_index');
            $table->integer('duration_minutes');
            $table->json('metadata')->nullable();
            $table->timestamps();
            
            // Foreign keys
            $table->foreign('course_id')
                ->references('id')
                ->on('courses')
                ->onDelete('cascade');
            
            // Indexes
            $table->index(['course_id', 'order_index']);
        });
    }
    
    public function down(): void
    {
        Schema::dropIfExists('modules');
    }
}; 