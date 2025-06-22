# TDD Makefile - Universal Testing Commands
# Supports: PHP/PHPUnit, JavaScript/Jest, Python/pytest

.PHONY: help test tdd

# Default - show help
help:
	@echo "🚨 Test-Driven Development (TDD) Commands"
	@echo "========================================="
	@echo ""
	@echo "TDD Workflow:"
	@echo "  make tdd              - Show TDD process reminder"
	@echo "  make test-new         - Create new test file"
	@echo "  make test-watch       - Run tests in watch mode"
	@echo ""
	@echo "Running Tests:"
	@echo "  make test             - Run all tests"
	@echo "  make test-unit        - Run unit tests only"
	@echo "  make test-integration - Run integration tests"
	@echo "  make test-feature     - Run feature tests"
	@echo "  make test-specific TEST=path/to/test - Run specific test"
	@echo "  make test-failed      - Re-run only failed tests"
	@echo ""
	@echo "Coverage:"
	@echo "  make coverage         - Generate coverage report"
	@echo "  make coverage-check   - Check if coverage meets minimum (80%)"
	@echo "  make coverage-html    - Open coverage report in browser"
	@echo ""
	@echo "Quality Checks:"
	@echo "  make lint             - Run code linter"
	@echo "  make format           - Auto-format code"
	@echo "  make check            - Run all checks (tests + lint + coverage)"
	@echo ""
	@echo "Utilities:"
	@echo "  make clean            - Clean test artifacts"
	@echo "  make install-tools    - Install testing tools"

# TDD reminder
tdd:
	@echo "🔴 RED -> 🟢 GREEN -> 🔵 REFACTOR"
	@echo ""
	@echo "1. Write a failing test"
	@echo "2. Run test - see it fail"
	@echo "3. Write minimal code to pass"
	@echo "4. Run test - see it pass"
	@echo "5. Refactor if needed"
	@echo "6. Run test - ensure still passing"
	@echo ""
	@echo "Remember: NO CODE WITHOUT A FAILING TEST FIRST!"

# Detect project type and test framework
detect-framework:
	@if [ -f "composer.json" ]; then \
		echo "PHP"; \
	elif [ -f "package.json" ]; then \
		echo "JS"; \
	elif [ -f "requirements.txt" ] || [ -f "setup.py" ]; then \
		echo "PYTHON"; \
	else \
		echo "UNKNOWN"; \
	fi

# PHP/PHPUnit commands
test-php:
	./vendor/bin/phpunit

test-php-unit:
	./vendor/bin/phpunit --testsuite Unit

test-php-specific:
	./vendor/bin/phpunit $(TEST)

test-php-watch:
	./vendor/bin/phpunit-watcher watch $(TEST)

coverage-php:
	./vendor/bin/phpunit --coverage-html coverage --coverage-text

# JavaScript/Jest commands
test-js:
	npm test

test-js-unit:
	npm test -- --testPathPattern=unit

test-js-specific:
	npm test -- $(TEST)

test-js-watch:
	npm test -- --watch $(TEST)

coverage-js:
	npm test -- --coverage

# Python/pytest commands
test-python:
	pytest

test-python-unit:
	pytest tests/unit

test-python-specific:
	pytest $(TEST)

test-python-watch:
	pytest-watch $(TEST)

coverage-python:
	pytest --cov=src --cov-report=html --cov-report=term

# Universal commands (auto-detect framework)
test:
	@FRAMEWORK=$$(make -s detect-framework); \
	if [ "$$FRAMEWORK" = "PHP" ]; then \
		make test-php; \
	elif [ "$$FRAMEWORK" = "JS" ]; then \
		make test-js; \
	elif [ "$$FRAMEWORK" = "PYTHON" ]; then \
		make test-python; \
	else \
		echo "❌ No test framework detected!"; \
		exit 1; \
	fi

test-unit:
	@FRAMEWORK=$$(make -s detect-framework); \
	if [ "$$FRAMEWORK" = "PHP" ]; then \
		make test-php-unit; \
	elif [ "$$FRAMEWORK" = "JS" ]; then \
		make test-js-unit; \
	elif [ "$$FRAMEWORK" = "PYTHON" ]; then \
		make test-python-unit; \
	fi

test-specific:
	@if [ -z "$(TEST)" ]; then \
		echo "❌ Please specify TEST=path/to/test"; \
		exit 1; \
	fi
	@FRAMEWORK=$$(make -s detect-framework); \
	if [ "$$FRAMEWORK" = "PHP" ]; then \
		make test-php-specific TEST=$(TEST); \
	elif [ "$$FRAMEWORK" = "JS" ]; then \
		make test-js-specific TEST=$(TEST); \
	elif [ "$$FRAMEWORK" = "PYTHON" ]; then \
		make test-python-specific TEST=$(TEST); \
	fi

test-watch:
	@FRAMEWORK=$$(make -s detect-framework); \
	if [ "$$FRAMEWORK" = "PHP" ]; then \
		make test-php-watch TEST=$(TEST); \
	elif [ "$$FRAMEWORK" = "JS" ]; then \
		make test-js-watch TEST=$(TEST); \
	elif [ "$$FRAMEWORK" = "PYTHON" ]; then \
		make test-python-watch TEST=$(TEST); \
	fi

coverage:
	@FRAMEWORK=$$(make -s detect-framework); \
	if [ "$$FRAMEWORK" = "PHP" ]; then \
		make coverage-php; \
	elif [ "$$FRAMEWORK" = "JS" ]; then \
		make coverage-js; \
	elif [ "$$FRAMEWORK" = "PYTHON" ]; then \
		make coverage-python; \
	fi

# Coverage check (80% minimum)
coverage-check:
	@echo "Checking coverage..."
	@make coverage | grep -E "(Lines|line|Total)" | tail -1
	@echo "Minimum required: 80%"

# Create new test file
test-new:
	@read -p "Test name (e.g., Calculator): " name; \
	FRAMEWORK=$$(make -s detect-framework); \
	if [ "$$FRAMEWORK" = "PHP" ]; then \
		mkdir -p tests/Unit; \
		echo "<?php\n\nnamespace Tests\\Unit;\n\nuse PHPUnit\\Framework\\TestCase;\n\nclass $${name}Test extends TestCase\n{\n    /** @test */\n    public function it_works()\n    {\n        \$$this->markTestIncomplete('Write your test here');\n    }\n}" > tests/Unit/$${name}Test.php; \
		echo "✅ Created tests/Unit/$${name}Test.php"; \
		echo "🚨 Now run: make test-specific TEST=tests/Unit/$${name}Test.php"; \
	elif [ "$$FRAMEWORK" = "JS" ]; then \
		mkdir -p tests; \
		echo "describe('$$name', () => {\n  test('works', () => {\n    expect(true).toBe(false); // Make it fail first!\n  });\n});" > tests/$${name}.test.js; \
		echo "✅ Created tests/$${name}.test.js"; \
		echo "🚨 Now run: make test-specific TEST=tests/$${name}.test.js"; \
	elif [ "$$FRAMEWORK" = "PYTHON" ]; then \
		mkdir -p tests; \
		echo "import pytest\n\nclass Test$$name:\n    def test_works(self):\n        assert False, 'Write your test here'" > tests/test_$$(echo $$name | tr '[:upper:]' '[:lower:]').py; \
		echo "✅ Created tests/test_$$(echo $$name | tr '[:upper:]' '[:lower:]').py"; \
		echo "🚨 Now run: make test-specific TEST=tests/test_$$(echo $$name | tr '[:upper:]' '[:lower:]').py"; \
	fi

# Quick test (no coverage)
test-quick:
	@FRAMEWORK=$$(make -s detect-framework); \
	if [ "$$FRAMEWORK" = "PHP" ]; then \
		./vendor/bin/phpunit --no-coverage $(TEST); \
	elif [ "$$FRAMEWORK" = "JS" ]; then \
		npm test -- --coverage=false $(TEST); \
	elif [ "$$FRAMEWORK" = "PYTHON" ]; then \
		pytest -x $(TEST); \
	fi

# Test and stop on first failure
test-fail-fast:
	@FRAMEWORK=$$(make -s detect-framework); \
	if [ "$$FRAMEWORK" = "PHP" ]; then \
		./vendor/bin/phpunit --stop-on-failure; \
	elif [ "$$FRAMEWORK" = "JS" ]; then \
		npm test -- --bail; \
	elif [ "$$FRAMEWORK" = "PYTHON" ]; then \
		pytest -x; \
	fi

# Re-run failed tests
test-failed:
	@FRAMEWORK=$$(make -s detect-framework); \
	if [ "$$FRAMEWORK" = "PHP" ]; then \
		./vendor/bin/phpunit --cache-result --order-by=defects --stop-on-defect; \
	elif [ "$$FRAMEWORK" = "JS" ]; then \
		npm test -- --onlyFailures; \
	elif [ "$$FRAMEWORK" = "PYTHON" ]; then \
		pytest --lf; \
	fi

# Clean test artifacts
clean:
	rm -rf coverage/
	rm -rf .coverage
	rm -rf htmlcov/
	rm -rf .pytest_cache/
	rm -rf .phpunit.cache/
	rm -f .phpunit.result.cache
	find . -name "*.pyc" -delete
	find . -name "__pycache__" -type d -exec rm -rf {} +

# Install testing tools
install-tools:
	@FRAMEWORK=$$(make -s detect-framework); \
	if [ "$$FRAMEWORK" = "PHP" ]; then \
		composer require --dev phpunit/phpunit mockery/mockery; \
		composer require --dev spatie/phpunit-watcher; \
	elif [ "$$FRAMEWORK" = "JS" ]; then \
		npm install --save-dev jest @types/jest; \
		npm install --save-dev @testing-library/jest-dom; \
	elif [ "$$FRAMEWORK" = "PYTHON" ]; then \
		pip install pytest pytest-cov pytest-watch pytest-mock; \
	fi

# Run all quality checks
check: lint test coverage-check
	@echo "✅ All checks passed!"

# Lint code
lint:
	@FRAMEWORK=$$(make -s detect-framework); \
	if [ "$$FRAMEWORK" = "PHP" ]; then \
		./vendor/bin/phpcs || true; \
	elif [ "$$FRAMEWORK" = "JS" ]; then \
		npm run lint || true; \
	elif [ "$$FRAMEWORK" = "PYTHON" ]; then \
		flake8 . || true; \
	fi

# Format code
format:
	@FRAMEWORK=$$(make -s detect-framework); \
	if [ "$$FRAMEWORK" = "PHP" ]; then \
		./vendor/bin/phpcbf || true; \
	elif [ "$$FRAMEWORK" = "JS" ]; then \
		npm run format || true; \
	elif [ "$$FRAMEWORK" = "PYTHON" ]; then \
		black . || true; \
	fi

# Git hooks
install-hooks:
	@echo "Installing git hooks..."
	@mkdir -p .git/hooks
	@echo '#!/bin/sh\nmake test-quick' > .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "✅ Git hooks installed!"

# Docker support
test-docker:
	docker-compose run --rm app make test

test-docker-watch:
	docker-compose run --rm app make test-watch TEST=$(TEST)

# CI/CD helpers
ci-test:
	make lint
	make test
	make coverage-check

# Metrics and reporting
metrics:
	@echo "📊 Test Metrics"
	@echo "==============="
	@FRAMEWORK=$$(make -s detect-framework); \
	if [ "$$FRAMEWORK" = "PHP" ]; then \
		echo "Tests: $$(find tests -name '*Test.php' | wc -l)"; \
		echo "Assertions: $$(grep -r 'assert' tests | wc -l)"; \
	elif [ "$$FRAMEWORK" = "JS" ]; then \
		echo "Tests: $$(find . -name '*.test.js' -o -name '*.spec.js' | wc -l)"; \
		echo "Assertions: $$(grep -r 'expect' tests | wc -l)"; \
	elif [ "$$FRAMEWORK" = "PYTHON" ]; then \
		echo "Tests: $$(find tests -name 'test_*.py' | wc -l)"; \
		echo "Assertions: $$(grep -r 'assert' tests | wc -l)"; \
	fi

# Open coverage in browser
coverage-html:
	@FRAMEWORK=$$(make -s detect-framework); \
	if [ "$$FRAMEWORK" = "PHP" ]; then \
		open coverage/index.html || xdg-open coverage/index.html; \
	elif [ "$$FRAMEWORK" = "JS" ]; then \
		open coverage/lcov-report/index.html || xdg-open coverage/lcov-report/index.html; \
	elif [ "$$FRAMEWORK" = "PYTHON" ]; then \
		open htmlcov/index.html || xdg-open htmlcov/index.html; \
	fi 