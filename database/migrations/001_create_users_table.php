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
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('ad_username')->unique()->nullable();
            $table->string('email')->unique();
            $table->string('password')->nullable();
            $table->string('first_name');
            $table->string('last_name');
            $table->string('middle_name')->nullable();
            $table->string('display_name')->nullable();
            $table->string('phone')->nullable();
            $table->string('avatar')->nullable();
            $table->string('department')->nullable();
            $table->string('position_title')->nullable();
            $table->unsignedBigInteger('position_id')->nullable();
            $table->unsignedBigInteger('manager_id')->nullable();
            $table->date('hire_date')->nullable();
            $table->enum('status', ['active', 'inactive', 'suspended'])->default('active');
            $table->boolean('is_admin')->default(false);
            $table->json('roles')->nullable();
            $table->json('permissions')->nullable();
            $table->timestamp('email_verified_at')->nullable();
            $table->timestamp('last_login_at')->nullable();
            $table->timestamp('password_changed_at')->nullable();
            $table->timestamp('ldap_synced_at')->nullable();
            $table->string('remember_token')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamps();
            $table->softDeletes();
            
            // Indexes
            $table->index('email');
            $table->index('ad_username');
            $table->index('status');
            $table->index('department');
            $table->index('position_id');
            $table->index('manager_id');
            $table->index(['status', 'is_admin']);
            $table->index('created_at');
            
            // Foreign keys
            $table->foreign('manager_id')->references('id')->on('users')->nullOnDelete();
        });
        
        // Create password resets table
        Schema::create('password_resets', function (Blueprint $table) {
            $table->string('email')->index();
            $table->string('token');
            $table->timestamp('created_at')->nullable();
            
            $table->primary(['email', 'token']);
        });
        
        // Create user sessions table
        Schema::create('user_sessions', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->foreignId('user_id')->nullable()->index();
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->text('payload');
            $table->integer('last_activity')->index();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_sessions');
        Schema::dropIfExists('password_resets');
        Schema::dropIfExists('users');
    }
}; 