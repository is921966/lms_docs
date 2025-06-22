.PHONY: help build up down restart logs shell test migrate seed clean

# Default target
help:
	@echo "LMS Corporate University - Available commands:"
	@echo "  make build       - Build Docker images"
	@echo "  make up          - Start all services"
	@echo "  make down        - Stop all services"
	@echo "  make restart     - Restart all services"
	@echo "  make logs        - Show logs"
	@echo "  make shell       - Enter app container shell"
	@echo "  make test        - Run tests"
	@echo "  make migrate     - Run database migrations"
	@echo "  make seed        - Seed database"
	@echo "  make clean       - Clean up containers and volumes"
	@echo "  make install     - Initial project setup"
	@echo "  make update      - Update dependencies"

# Build Docker images
build:
	docker-compose build --no-cache

# Start services
up:
	docker-compose up -d
	@echo "Services started. Access the application at http://localhost:8080"
	@echo "MailHog: http://localhost:8025"
	@echo "RabbitMQ: http://localhost:15672 (guest/guest)"
	@echo "PgAdmin: http://localhost:5050 (admin@lms.local/admin)"

# Start services with specific profile
up-dev:
	docker-compose --profile dev up -d

up-search:
	docker-compose --profile search up -d

up-analytics:
	docker-compose --profile analytics up -d

up-workers:
	docker-compose --profile workers up -d

up-all:
	docker-compose --profile dev --profile search --profile analytics --profile workers up -d

# Stop services
down:
	docker-compose down

# Restart services
restart: down up

# Show logs
logs:
	docker-compose logs -f

# Logs for specific service
logs-app:
	docker-compose logs -f app

logs-nginx:
	docker-compose logs -f nginx

logs-postgres:
	docker-compose logs -f postgres

# Enter container shell
shell:
	docker-compose exec app sh

shell-root:
	docker-compose exec -u root app sh

# Database commands
db-shell:
	docker-compose exec postgres psql -U postgres lms

migrate:
	docker-compose exec app php artisan migrate

migrate-fresh:
	docker-compose exec app php artisan migrate:fresh

migrate-rollback:
	docker-compose exec app php artisan migrate:rollback

seed:
	docker-compose exec app php artisan db:seed

migrate-seed: migrate seed

# Testing commands
.PHONY: test test-unit test-integration test-feature test-coverage test-watch

## Quick test commands for TDD
test-one: ## Run a single test file quickly (usage: make test-one TEST=UserTest)
	@docker run --rm -v $(PWD):/app -w /app --network lms_docs_lms_network php:8.2-cli \
		php vendor/bin/phpunit tests/Unit/**/$(TEST).php --stop-on-failure

test-class: ## Run all tests for a class (usage: make test-class CLASS=User)
	@docker run --rm -v $(PWD):/app -w /app --network lms_docs_lms_network php:8.2-cli \
		php vendor/bin/phpunit tests/Unit/**/$(CLASS)*.php

test-domain: ## Run all domain tests quickly
	@docker run --rm -v $(PWD):/app -w /app --network lms_docs_lms_network php:8.2-cli \
		php vendor/bin/phpunit tests/Unit/*/Domain/

test-last: ## Re-run the last failed test
	@docker run --rm -v $(PWD):/app -w /app --network lms_docs_lms_network php:8.2-cli \
		php vendor/bin/phpunit --order-by=defects --stop-on-failure

test-watch: ## Run tests in watch mode (requires fswatch: brew install fswatch)
	@echo "Watching for changes in src/ and tests/ directories..."
	@fswatch -o src/ tests/ | xargs -n1 -I{} make test-unit

## New simplified test commands
test-build: ## Build test environment
	docker-compose -f docker-compose.test.yml build

test-up: ## Start test environment
	docker-compose -f docker-compose.test.yml up -d
	@echo "Waiting for services to be ready..."
	@sleep 5

test-down: ## Stop test environment
	docker-compose -f docker-compose.test.yml down

test-run: ## Run tests in test environment
	docker-compose -f docker-compose.test.yml run --rm test

test-run-specific: ## Run specific test in test environment (usage: make test-run-specific TEST=path/to/test.php)
	docker-compose -f docker-compose.test.yml run --rm test vendor/bin/phpunit $(TEST)

test-shell: ## Enter test container shell
	docker-compose -f docker-compose.test.yml run --rm test sh

test-local: ## Run tests locally (requires PHP installed)
	./run-tests-local.sh

test-local-specific: ## Run specific test locally (usage: make test-local-specific TEST=path/to/test.php)
	./run-tests-local.sh $(TEST)

## Fix Docker issues
fix-docker: ## Fix Docker build issues
	@echo "Fixing Docker build issues..."
	@echo "1. Updating main Dockerfile to include LDAP..."
	@sed -i.bak 's/bcmath \\/bcmath \\\n        ldap \\/' Dockerfile
	@echo "2. Rebuilding containers..."
	docker-compose build --no-cache app
	@echo "3. Starting services..."
	docker-compose up -d
	@echo "Done! Try running tests now."

## Standard test commands
test: ## Run all tests
	@docker run --rm -v $(PWD):/app -w /app --network lms_docs_lms_network php:8.2-cli \
		php vendor/bin/phpunit

test-simple: ## Run a simple test to verify setup
	docker-compose exec app php vendor/bin/phpunit --version
	@echo "Creating simple test..."
	@echo '<?php use PHPUnit\Framework\TestCase; class SimpleTest extends TestCase { public function testTrue() { $$this->assertTrue(true); } }' > tests/SimpleTest.php
	docker-compose exec app php vendor/bin/phpunit tests/SimpleTest.php
	@rm -f tests/SimpleTest.php

test-unit: ## Run unit tests only
	docker-compose exec app php vendor/bin/phpunit --testsuite Unit

test-coverage: ## Generate test coverage report
	docker-compose exec app php vendor/bin/phpunit --coverage-html coverage

test-specific: ## Run specific test (usage: make test-specific TEST=tests/Unit/...)
	docker-compose exec app php vendor/bin/phpunit $(TEST)

# TDD Commands (MANDATORY USE!)
tdd: ## Start TDD session - write test first!
	@echo "🚨 TDD REMINDER: Write test FIRST, then code!"
	@echo "1. Create your test file"
	@echo "2. Run: make test-watch TEST=your/test/file.php"
	@echo "3. See it fail (RED)"
	@echo "4. Write minimal code"
	@echo "5. See it pass (GREEN)"
	@echo "6. Refactor if needed"

test-verify-tdd: ## Verify TDD compliance for current branch
	@echo "Checking TDD compliance..."
	@echo "Test commits:"
	@git log --oneline --grep="test" --grep="Test" --grep="TEST" | head -10
	@echo "\nImplementation commits:"
	@git log --oneline --grep="implement" --grep="add" --grep="feature" | head -10
	@echo "\nRemember: Tests should come BEFORE implementation!"

# Code quality
.PHONY: phpstan psalm cs-check cs-fix check-file-sizes

phpstan: ## Run PHPStan analysis
	$(DOCKER_PHP) vendor/bin/phpstan analyse

psalm: ## Run Psalm analysis
	$(DOCKER_PHP) vendor/bin/psalm

cs-check: ## Check code style
	$(DOCKER_PHP) vendor/bin/php-cs-fixer fix --dry-run --diff

cs-fix: ## Fix code style
	$(DOCKER_PHP) vendor/bin/php-cs-fixer fix

check-file-sizes: ## Check for files larger than 300 lines
	@echo "=== Files larger than 300 lines ==="
	@find src -name "*.php" -exec wc -l {} \; | awk '$$1 > 300 {print}' | sort -nr
	@echo ""
	@echo "=== File size summary ==="
	@echo "Optimal: 50-150 lines"
	@echo "Acceptable: 150-300 lines"
	@echo "Needs refactoring: > 300 lines"
	@echo "Critical: > 500 lines"

# Cache management
cache-clear:
	docker-compose exec app php artisan cache:clear
	docker-compose exec app php artisan config:clear
	docker-compose exec app php artisan route:clear
	docker-compose exec app php artisan view:clear

cache-warm:
	docker-compose exec app php artisan config:cache
	docker-compose exec app php artisan route:cache
	docker-compose exec app php artisan view:cache

# Composer commands
composer-install:
	docker-compose exec app composer install

composer-update:
	docker-compose exec app composer update

composer-dump:
	docker-compose exec app composer dump-autoload -o

# NPM commands (if frontend is included)
npm-install:
	docker-compose exec app npm install

npm-dev:
	docker-compose exec app npm run dev

npm-build:
	docker-compose exec app npm run build

npm-watch:
	docker-compose exec app npm run watch

# Queue management
queue-work:
	docker-compose exec app php artisan queue:work

queue-restart:
	docker-compose exec app php artisan queue:restart

# Clean up
clean:
	docker-compose down -v
	docker system prune -f

clean-all:
	docker-compose down -v --rmi all
	docker system prune -af

# Initial setup
install: build up
	@echo "Waiting for database to be ready..."
	@sleep 10
	docker-compose exec app composer install
	docker-compose exec app cp .env.example .env
	docker-compose exec app php artisan key:generate
	docker-compose exec app php artisan migrate
	docker-compose exec app php artisan db:seed
	@echo "Installation complete!"

# Update project
update: composer-update migrate cache-clear cache-warm
	@echo "Project updated!"

# Backup database
backup-db:
	@mkdir -p backups
	docker-compose exec postgres pg_dump -U postgres lms > backups/lms_backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "Database backed up to backups/"

# Restore database
restore-db:
	@echo "Available backups:"
	@ls -1 backups/*.sql 2>/dev/null || echo "No backups found"
	@echo "Usage: make restore-db-file FILE=backups/lms_backup_YYYYMMDD_HHMMSS.sql"

restore-db-file:
	docker-compose exec -T postgres psql -U postgres lms < $(FILE)
	@echo "Database restored from $(FILE)"

# ========== METHODOLOGY SYNC ==========

## Sync methodology to central repository
sync-methodology-push: ## Push methodology updates to central repository
	@echo "📤 Syncing methodology to central repository..."
	@./sync-methodology.sh to-central

## Sync methodology from central repository
sync-methodology-pull: ## Pull methodology updates from central repository
	@echo "📥 Syncing methodology from central repository..."
	@./sync-methodology.sh from-central

## Update methodology (alias for push)
update-methodology: sync-methodology-push ## Update central methodology repository (alias)

.PHONY: help sync-methodology-push sync-methodology-pull update-methodology 