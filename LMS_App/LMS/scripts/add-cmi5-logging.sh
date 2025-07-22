#!/bin/bash

# Скрипт для добавления логирования в Cmi5 модуль

echo "📝 Добавляем логирование в Cmi5 модуль..."
echo "========================================"

# Добавляем логирование в Cmi5Service
cat << 'EOF' > patch-cmi5-service.swift
// Временный патч для добавления логирования
extension Cmi5Service {
    static func enableDebugLogging() {
        print("🔍 CMI5 DEBUG: Logging enabled")
    }
}

// Добавляем логирование в методы
extension Cmi5Repository {
    func logOperation(_ operation: String, _ details: String = "") {
        print("🔍 CMI5 REPO: \(operation) \(details)")
    }
}
EOF

echo "✅ Патч создан"

# Инструкции
echo ""
echo "📋 Для активации логирования добавьте в нужные методы:"
echo ""
echo "В Cmi5Service.loadPackages():"
echo '    print("🔍 CMI5: Loading packages...")'
echo '    print("🔍 CMI5: Found \(packages.count) packages")'
echo ""
echo "В Cmi5Service.importPackage():"
echo '    print("🔍 CMI5: Importing package from \(url)")'
echo '    print("🔍 CMI5: Package saved with ID: \(savedPackage.id)")'
echo ""
echo "В Cmi5Repository методы:"
echo '    print("🔍 CMI5 REPO: getAllPackages() called")'
echo '    print("🔍 CMI5 REPO: Returning \(packages.count) packages")'
echo '    print("🔍 CMI5 REPO: createPackage() - \(package.title)")'
echo ""
echo "В Cmi5ImportViewModel.importPackage():"
echo '    print("🔍 CMI5 VM: Starting import...")'
echo '    print("🔍 CMI5 VM: Import result: \(result.package.title)")'
echo ""
echo "Используйте Console.app с фильтром: CMI5" 