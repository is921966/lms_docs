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
        Schema::create('competencies', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('name', 200);
            $table->text('description');
            $table->uuid('category_id');
            $table->integer('required_level')->default(1);
            $table->boolean('is_core')->default(false);
            $table->timestamps();
            
            // Indexes
            $table->index('category_id');
            $table->index('is_core');
            $table->index(['category_id', 'is_core']);
            
            // Foreign keys
            $table->foreign('category_id')
                ->references('id')
                ->on('competency_categories')
                ->onDelete('restrict');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('competencies');
    }
};
