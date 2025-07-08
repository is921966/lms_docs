<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Таблица для Cmi5 пакетов
        Schema::create('cmi5_packages', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('course_id')->nullable();
            $table->string('package_name');
            $table->string('package_version', 50)->nullable();
            $table->json('manifest'); // Сохраняем полный манифест как JSON
            $table->uuid('uploaded_by');
            $table->bigInteger('file_size');
            $table->string('file_path'); // Путь к загруженному файлу
            $table->enum('status', ['processing', 'valid', 'invalid', 'archived'])
                ->default('processing');
            $table->json('validation_errors')->nullable();
            $table->timestamps();
            
            // Foreign keys
            $table->foreign('course_id')->references('id')->on('courses')
                ->onDelete('cascade');
            $table->foreign('uploaded_by')->references('id')->on('users');
            
            // Indexes
            $table->index('course_id');
            $table->index('status');
            $table->index('created_at');
        });
        
        // Таблица для Cmi5 активностей
        Schema::create('cmi5_activities', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('package_id');
            $table->string('activity_id'); // ID из манифеста
            $table->string('title');
            $table->text('description')->nullable();
            $table->string('launch_url');
            $table->enum('launch_method', ['OwnWindow', 'AnyWindow'])
                ->default('AnyWindow');
            $table->enum('move_on', [
                'Passed', 
                'Completed', 
                'CompletedAndPassed', 
                'CompletedOrPassed', 
                'NotApplicable'
            ])->default('CompletedOrPassed');
            $table->decimal('mastery_score', 3, 2)->nullable(); // 0.00 - 1.00
            $table->string('activity_type');
            $table->string('duration')->nullable(); // ISO 8601 duration
            $table->integer('order_index')->default(0);
            $table->timestamps();
            
            // Foreign keys
            $table->foreign('package_id')->references('id')->on('cmi5_packages')
                ->onDelete('cascade');
            
            // Indexes
            $table->index('package_id');
            $table->index('activity_id');
        });
        
        // Таблица для xAPI Actors (learners)
        Schema::create('xapi_actors', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('object_type')->default('Agent');
            $table->string('name')->nullable();
            $table->string('mbox')->nullable(); // mailto:email
            $table->string('account_name')->nullable();
            $table->string('account_homepage')->nullable();
            $table->json('additional_info')->nullable();
            $table->timestamps();
            
            // Indexes
            $table->unique('mbox');
            $table->index(['account_name', 'account_homepage']);
        });
        
        // Таблица для xAPI Statements
        Schema::create('xapi_statements', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('actor_id');
            $table->json('verb'); // {id, display}
            $table->json('object'); // {objectType, id, definition}
            $table->json('result')->nullable(); // {score, success, completion, response, duration}
            $table->json('context')->nullable(); // {registration, contextActivities, language}
            $table->uuid('registration')->nullable();
            $table->timestamp('timestamp');
            $table->timestamp('stored');
            $table->json('authority')->nullable();
            $table->string('version')->default('1.0.3');
            $table->boolean('voided')->default(false);
            
            // Foreign keys
            $table->foreign('actor_id')->references('id')->on('xapi_actors');
            
            // Indexes
            $table->index('actor_id');
            $table->index('registration');
            $table->index('timestamp');
            $table->index('stored');
            $table->index('voided');
        });
        
        // Таблица для xAPI State (сохранение состояния активностей)
        Schema::create('xapi_state', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('activity_id');
            $table->uuid('agent_id');
            $table->string('state_id'); // Идентификатор состояния
            $table->uuid('registration')->nullable();
            $table->json('state_data');
            $table->timestamps();
            
            // Composite unique key
            $table->unique(['activity_id', 'agent_id', 'state_id', 'registration'], 
                'xapi_state_unique');
            
            // Foreign keys
            $table->foreign('agent_id')->references('id')->on('xapi_actors');
            
            // Indexes
            $table->index('activity_id');
            $table->index('agent_id');
            $table->index('registration');
        });
        
        // Таблица для прогресса прохождения Cmi5 активностей
        Schema::create('cmi5_progress', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('user_id');
            $table->uuid('activity_id');
            $table->uuid('registration');
            $table->enum('status', [
                'not_started',
                'launched', 
                'initialized',
                'in_progress',
                'completed',
                'passed',
                'failed',
                'terminated',
                'abandoned'
            ])->default('not_started');
            $table->decimal('score', 5, 2)->nullable(); // 0.00 - 100.00
            $table->integer('progress_percent')->default(0);
            $table->integer('time_spent_seconds')->default(0);
            $table->timestamp('first_launched_at')->nullable();
            $table->timestamp('last_launched_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();
            
            // Foreign keys
            $table->foreign('user_id')->references('id')->on('users');
            $table->foreign('activity_id')->references('id')->on('cmi5_activities');
            
            // Indexes
            $table->unique(['user_id', 'activity_id', 'registration']);
            $table->index('status');
            $table->index('completed_at');
        });
    }
    
    public function down(): void
    {
        Schema::dropIfExists('cmi5_progress');
        Schema::dropIfExists('xapi_state');
        Schema::dropIfExists('xapi_statements');
        Schema::dropIfExists('xapi_actors');
        Schema::dropIfExists('cmi5_activities');
        Schema::dropIfExists('cmi5_packages');
    }
}; 