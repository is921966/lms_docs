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
        Schema::create('org_employees', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('tab_number', 10)->unique();
            $table->string('name');
            $table->string('position');
            $table->uuid('department_id');
            $table->string('email')->nullable();
            $table->string('phone', 30)->nullable();
            $table->uuid('user_id')->nullable(); // Link to users table
            $table->timestamps();
            
            // Indexes
            $table->index('tab_number');
            $table->index('department_id');
            $table->index('user_id');
            $table->index('name');
            
            // Foreign keys
            $table->foreign('department_id')
                ->references('id')
                ->on('departments')
                ->onDelete('restrict');
                
            $table->foreign('user_id')
                ->references('id')
                ->on('users')
                ->onDelete('set null');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('org_employees');
    }
}; 