#!/bin/bash
# Скрипт для создания нового модуля с автоматической регистрацией

set -e

if [ $# -eq 0 ]; then
    echo "❌ Использование: ./create-feature.sh <FeatureName>"
    echo "Пример: ./create-feature.sh Notifications"
    exit 1
fi

FEATURE_NAME=$1
FEATURE_NAME_LOWER=$(echo "$FEATURE_NAME" | tr '[:upper:]' '[:lower:]')

echo "🚀 Создание нового модуля: $FEATURE_NAME"

# 1. Создаем структуру папок
echo "📁 Создание структуры папок..."
mkdir -p "LMS/Features/$FEATURE_NAME/Views"
mkdir -p "LMS/Features/$FEATURE_NAME/Models"
mkdir -p "LMS/Features/$FEATURE_NAME/ViewModels"
mkdir -p "LMS/Features/$FEATURE_NAME/Services"

# 2. Создаем базовый View
echo "📝 Создание базового View..."
cat > "LMS/Features/$FEATURE_NAME/Views/${FEATURE_NAME}View.swift" << EOF
import SwiftUI

struct ${FEATURE_NAME}View: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("${FEATURE_NAME} Module")
                    .font(.largeTitle)
                    .padding()
                
                Text("Функционал в разработке")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("$FEATURE_NAME")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    ${FEATURE_NAME}View()
        .environmentObject(AuthViewModel())
}
EOF

# 3. Добавляем в FeatureRegistry
echo "📋 Регистрация в FeatureRegistry..."
if [ ! -f "LMS/Features/FeatureRegistry.swift" ]; then
    # Создаем FeatureRegistry если его нет
    cat > "LMS/Features/FeatureRegistry.swift" << 'EOF'
import SwiftUI

enum Feature: String, CaseIterable {
    case auth = "Авторизация"
    case users = "Пользователи"
    case courses = "Курсы"
    case profile = "Профиль"
    case settings = "Настройки"
    case tests = "Тесты"
    case analytics = "Аналитика"
    case onboarding = "Онбординг"
    // NEW_FEATURES_HERE
    
    var isEnabled: Bool {
        switch self {
        case .auth, .users, .courses, .profile, .settings, .tests, .analytics:
            return true
        default:
            return UserDefaults.standard.bool(forKey: "feature_\(self.rawValue)")
        }
    }
    
    var icon: String {
        switch self {
        case .auth: return "person.circle"
        case .users: return "person.2"
        case .courses: return "book"
        case .profile: return "person"
        case .settings: return "gear"
        case .tests: return "checkmark.circle"
        case .analytics: return "chart.bar"
        case .onboarding: return "star"
        // NEW_ICONS_HERE
        }
    }
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .auth: AuthenticationView()
        case .users: UserManagementView()
        case .courses: CoursesListView()
        case .profile: ProfileView()
        case .settings: SettingsView()
        case .tests: TestsListView()
        case .analytics: AnalyticsView()
        case .onboarding: OnboardingProgramsView()
        // NEW_VIEWS_HERE
        }
    }
}
EOF
fi

# Добавляем новый feature в FeatureRegistry
sed -i '' "s|// NEW_FEATURES_HERE|case $FEATURE_NAME_LOWER = \"$FEATURE_NAME\"\n    // NEW_FEATURES_HERE|" "LMS/Features/FeatureRegistry.swift"
sed -i '' "s|// NEW_ICONS_HERE|case .$FEATURE_NAME_LOWER: return \"questionmark.circle\"\n        // NEW_ICONS_HERE|" "LMS/Features/FeatureRegistry.swift"
sed -i '' "s|// NEW_VIEWS_HERE|case .$FEATURE_NAME_LOWER: ${FEATURE_NAME}View()\n        // NEW_VIEWS_HERE|" "LMS/Features/FeatureRegistry.swift"

# 4. Создаем Integration Test
echo "🧪 Создание Integration Test..."
mkdir -p "LMSUITests/Features"
cat > "LMSUITests/Features/${FEATURE_NAME}IntegrationTests.swift" << EOF
import XCTest

final class ${FEATURE_NAME}IntegrationTests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func test${FEATURE_NAME}IsAccessibleFromMainMenu() throws {
        // Проверяем, что модуль доступен из главного меню
        // Сначала включаем feature flag
        app.launchArguments.append("-feature_${FEATURE_NAME}_enabled")
        app.launch()
        
        // Проверяем наличие в табах
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        
        let ${FEATURE_NAME_LOWER}Tab = tabBar.buttons["$FEATURE_NAME"]
        XCTAssertTrue(${FEATURE_NAME_LOWER}Tab.exists, "$FEATURE_NAME должен быть доступен в навигации")
        
        // Проверяем, что можно перейти
        ${FEATURE_NAME_LOWER}Tab.tap()
        
        let navTitle = app.navigationBars["$FEATURE_NAME"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 2))
    }
}
EOF

# 5. Обновляем INTEGRATION_STATUS.md
echo "📊 Обновление статуса интеграции..."
if [ ! -f "docs/INTEGRATION_STATUS.md" ]; then
    mkdir -p docs
    cat > "docs/INTEGRATION_STATUS.md" << EOF
# 📊 Статус интеграции модулей

Последнее обновление: $(date +"%Y-%m-%d %H:%M")

| Модуль | Код | Тесты | UI | Навигация | Feature Flag | Статус |
|--------|-----|-------|----|-----------|--------------|---------| 
| Auth | ✅ | ✅ | ✅ | ✅ | enabled | Production |
| Users | ✅ | ✅ | ✅ | ✅ | enabled | Production |
| Courses | ✅ | ✅ | ✅ | ✅ | enabled | Production |
| Profile | ✅ | ✅ | ✅ | ✅ | enabled | Production |
| Settings | ✅ | ✅ | ✅ | ✅ | enabled | Production |
| Tests | ✅ | ✅ | ✅ | ✅ | enabled | Production |
| Analytics | ✅ | ✅ | ✅ | ✅ | enabled | Production |
| Onboarding | ✅ | ✅ | ✅ | ✅ | enabled | Production |
| Competencies | ✅ | ✅ | ✅ | ❌ | disabled | Ready |
| Positions | ✅ | ✅ | ✅ | ❌ | disabled | Ready |
| Feed | ✅ | ✅ | ✅ | ❌ | disabled | Ready |
EOF
fi

# Добавляем новый модуль в таблицу
echo "| $FEATURE_NAME | ✅ | ⏳ | ✅ | ❌ | disabled | Development |" >> "docs/INTEGRATION_STATUS.md"

echo "✅ Модуль $FEATURE_NAME успешно создан!"
echo ""
echo "📝 Следующие шаги:"
echo "1. Реализовать функционал в LMS/Features/$FEATURE_NAME/"
echo "2. Написать unit тесты"
echo "3. Включить feature flag: UserDefaults.standard.set(true, forKey: \"feature_${FEATURE_NAME}\")"
echo "4. Запустить integration test: xcodebuild test -only-testing:LMSUITests/${FEATURE_NAME}IntegrationTests" 