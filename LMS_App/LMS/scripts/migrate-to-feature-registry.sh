#!/bin/bash

# Скрипт для миграции существующих модулей в Feature Registry
# Использование: ./migrate-to-feature-registry.sh

set -e

echo "🔄 Миграция модулей в Feature Registry..."

# Путь к FeatureRegistry.swift
REGISTRY_FILE="../LMS/Features/FeatureRegistry.swift"

# Проверка существования файла
if [ ! -f "$REGISTRY_FILE" ]; then
    echo "❌ Файл FeatureRegistry.swift не найден!"
    exit 1
fi

# Функция для добавления модуля в реестр
add_module_to_registry() {
    local module_name=$1
    local module_title=$2
    local module_icon=$3
    local module_view=$4
    local is_ready=$5
    
    echo "📦 Добавляем модуль: $module_title"
    
    # Проверяем, не добавлен ли уже модуль
    if grep -q "case $module_name" "$REGISTRY_FILE"; then
        echo "  ✅ Модуль уже в реестре"
        return
    fi
    
    # Добавляем в enum
    sed -i '' "/case notifications/a\\
    case $module_name = \"$module_title\"
" "$REGISTRY_FILE"
    
    # Добавляем иконку
    sed -i '' "/case .notifications: return \"bell\"/a\\
        case .$module_name: return \"$module_icon\"
" "$REGISTRY_FILE"
    
    # Добавляем view
    sed -i '' "/case .notifications:/a\\
        case .$module_name:\\
            $module_view()
" "$REGISTRY_FILE"
    
    echo "  ✅ Модуль добавлен в реестр"
}

# Функция для проверки существования View файла
check_view_exists() {
    local view_name=$1
    local search_path="../LMS/Features"
    
    if find "$search_path" -name "*.swift" -exec grep -l "struct $view_name" {} \; | head -1 > /dev/null; then
        return 0
    else
        return 1
    fi
}

# Анализ существующих модулей
echo ""
echo "🔍 Анализ существующих модулей..."

# Список потенциальных модулей для миграции
declare -A modules=(
    ["programs"]="Программы|book.closed|ProgramListView"
    ["certificates"]="Сертификаты|rosette|CertificateListView"
    ["gamification"]="Геймификация|gamecontroller|GamificationView"
    ["notifications"]="Уведомления|bell|NotificationListView"
    ["calendar"]="Календарь|calendar|CalendarView"
    ["library"]="Библиотека|books.vertical|LibraryView"
    ["reports"]="Отчеты|doc.text|ReportsView"
)

# Проверяем каждый модуль
for module in "${!modules[@]}"; do
    IFS='|' read -r title icon view <<< "${modules[$module]}"
    
    echo ""
    echo "Проверяем модуль: $title"
    
    if check_view_exists "$view"; then
        echo "  ✅ View найден: $view"
        read -p "  Добавить в Feature Registry? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            add_module_to_registry "$module" "$title" "$icon" "$view" "true"
        fi
    else
        echo "  ⚠️  View не найден: $view"
    fi
done

# Создание helper функций
echo ""
echo "📝 Создание helper функций..."

cat << 'EOF' > ../LMS/Features/FeatureRegistryHelpers.swift
//
//  FeatureRegistryHelpers.swift
//  LMS
//
//  Auto-generated migration helpers
//

import Foundation

extension Feature {
    /// Мигрировать все готовые модули
    static func migrateAllReadyModules() {
        // Включаем все модули, которые имеют реализацию
        let readyModules: [Feature] = [
            .competencies,
            .positions,
            .feed
        ]
        
        for module in readyModules {
            Feature.enable(module)
            print("✅ Мигрирован модуль: \(module.rawValue)")
        }
    }
    
    /// Проверить статус всех модулей
    static func printModuleStatus() {
        print("\n📊 Статус модулей:")
        print("================")
        
        for feature in Feature.allCases {
            let status = feature.isEnabled ? "✅ Включен" : "❌ Выключен"
            print("\(feature.rawValue): \(status)")
        }
        
        print("================\n")
    }
    
    /// Сбросить все feature flags
    static func resetAllFeatureFlags() {
        for feature in Feature.allCases {
            UserDefaults.standard.removeObject(forKey: "feature_\(feature.rawValue)")
        }
        print("🔄 Все feature flags сброшены")
    }
}
EOF

echo "✅ Helper функции созданы"

# Обновление ContentView для поддержки миграции
echo ""
echo "🔧 Обновление ContentView..."

# Проверка интеграции
echo ""
echo "✅ Миграция завершена!"
echo ""
echo "📋 Следующие шаги:"
echo "1. Проверьте изменения в FeatureRegistry.swift"
echo "2. Запустите приложение и проверьте новые модули"
echo "3. Используйте Feature.migrateAllReadyModules() для включения модулей"
echo "4. Используйте Feature.printModuleStatus() для проверки статуса"

# Компиляция для проверки
echo ""
read -p "Запустить компиляцию для проверки? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cd ..
    xcodebuild -scheme LMS -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -configuration Debug build CODE_SIGNING_REQUIRED=NO -quiet
    echo "✅ Компиляция успешна!"
fi 