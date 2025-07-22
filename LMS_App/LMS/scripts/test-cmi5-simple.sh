#!/bin/bash

# Простой тест Cmi5 функционала

echo "🧪 Быстрый тест Cmi5..."
echo "======================="

# Запускаем только интеграционный тест
xcodebuild test \
    -scheme LMS \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
    -only-testing:LMSTests/Cmi5ImportIntegrationTests/testImportPackageFullCycle \
    2>&1 | grep -E "(Test Case|Assertion|error:|failed:|passed:|FAILED|PASSED)"

echo ""
echo "✅ Тест завершен" 