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
        Schema::table('users', function (Blueprint $table) {
            // Добавить недостающие колонки если их нет
            if (!Schema::hasColumn('users', 'middle_name')) {
                $table->string('middle_name', 100)->nullable()->after('last_name');
            }
            if (!Schema::hasColumn('users', 'phone')) {
                $table->string('phone', 20)->nullable()->after('middle_name');
            }
            if (!Schema::hasColumn('users', 'department')) {
                $table->string('department', 100)->nullable()->after('phone');
            }
            if (!Schema::hasColumn('users', 'display_name')) {
                $table->string('display_name')->nullable()->after('department');
            }
            if (!Schema::hasColumn('users', 'position_title')) {
                $table->string('position_title', 100)->nullable()->after('display_name');
            }
            if (!Schema::hasColumn('users', 'position_id')) {
                $table->uuid('position_id')->nullable()->after('position_title');
            }
            if (!Schema::hasColumn('users', 'manager_id')) {
                $table->uuid('manager_id')->nullable()->after('position_id');
            }
            if (!Schema::hasColumn('users', 'ad_username')) {
                $table->string('ad_username', 100)->nullable()->unique()->after('manager_id');
            }
            if (!Schema::hasColumn('users', 'is_admin')) {
                $table->boolean('is_admin')->default(false)->after('status');
            }
            if (!Schema::hasColumn('users', 'suspension_reason')) {
                $table->text('suspension_reason')->nullable()->after('deleted_at');
            }
            if (!Schema::hasColumn('users', 'suspended_until')) {
                $table->timestamp('suspended_until')->nullable()->after('suspension_reason');
            }
            if (!Schema::hasColumn('users', 'password_changed_at')) {
                $table->timestamp('password_changed_at')->nullable()->after('email_verified_at');
            }
            if (!Schema::hasColumn('users', 'last_login_at')) {
                $table->timestamp('last_login_at')->nullable()->after('password_changed_at');
            }
            if (!Schema::hasColumn('users', 'last_login_ip')) {
                $table->string('last_login_ip', 45)->nullable()->after('last_login_at');
            }
            if (!Schema::hasColumn('users', 'last_user_agent')) {
                $table->text('last_user_agent')->nullable()->after('last_login_ip');
            }
            if (!Schema::hasColumn('users', 'login_count')) {
                $table->integer('login_count')->default(0)->after('last_user_agent');
            }
            if (!Schema::hasColumn('users', 'two_factor_enabled')) {
                $table->boolean('two_factor_enabled')->default(false)->after('login_count');
            }
            if (!Schema::hasColumn('users', 'two_factor_secret')) {
                $table->string('two_factor_secret')->nullable()->after('two_factor_enabled');
            }
            if (!Schema::hasColumn('users', 'ldap_synced_at')) {
                $table->timestamp('ldap_synced_at')->nullable()->after('two_factor_secret');
            }
            if (!Schema::hasColumn('users', 'metadata')) {
                $table->json('metadata')->nullable()->after('ldap_synced_at');
            }
            
            // Добавить индексы
            $table->index('status');
            $table->index('department');
            $table->index('is_admin');
            $table->index('deleted_at');
            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // Удалить индексы
            $table->dropIndex(['status']);
            $table->dropIndex(['department']);
            $table->dropIndex(['is_admin']);
            $table->dropIndex(['deleted_at']);
            $table->dropIndex(['created_at']);
            
            // Удалить колонки
            $table->dropColumn([
                'middle_name',
                'phone',
                'department',
                'display_name',
                'position_title',
                'position_id',
                'manager_id',
                'ad_username',
                'is_admin',
                'suspension_reason',
                'suspended_until',
                'password_changed_at',
                'last_login_at',
                'last_login_ip',
                'last_user_agent',
                'login_count',
                'two_factor_enabled',
                'two_factor_secret',
                'ldap_synced_at',
                'metadata'
            ]);
        });
    }
}; 