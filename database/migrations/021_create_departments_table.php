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
        Schema::create('departments', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('name');
            $table->string('code', 50)->unique();
            $table->uuid('parent_id')->nullable();
            $table->integer('level')->default(0);
            $table->integer('employee_count')->default(0);
            $table->timestamps();
            
            // Indexes
            $table->index('parent_id');
            $table->index('code');
            $table->index('level');
            
            // Foreign key to self
            $table->foreign('parent_id')
                ->references('id')
                ->on('departments')
                ->onDelete('restrict');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('departments');
    }
}; 