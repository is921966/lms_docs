#!/bin/bash

echo "🎯 Настройка Cmi5 тестовых данных..."
echo "===================================="

DEVICE_ID="C0F60722-8F57-46A8-A737-2A1CD8819E8E"
CMI5_COURSES_DIR="/Users/ishirokov/lms_docs/cmi5_courses"

# 1. Проверка наличия курсов
echo "📦 Проверка Cmi5 курсов..."
if [ ! -f "$CMI5_COURSES_DIR/ai_fluency_course_v1.0.zip" ] || [ ! -f "$CMI5_COURSES_DIR/corporate_culture_tsum_v1.0.zip" ]; then
    echo "❌ Cmi5 курсы не найдены в $CMI5_COURSES_DIR"
    exit 1
fi

echo "✅ Найдены курсы:"
echo "  - AI Fluency Course"
echo "  - Corporate Culture TSUM"

# 2. Создание директории для тестовых данных
TEST_DATA_DIR="LMSUITests/TestData/Cmi5Packages"
echo ""
echo "📁 Создание директории для тестовых данных..."
mkdir -p "$TEST_DATA_DIR"

# 3. Копирование курсов
echo "📋 Копирование Cmi5 пакетов..."
cp "$CMI5_COURSES_DIR/ai_fluency_course_v1.0.zip" "$TEST_DATA_DIR/"
cp "$CMI5_COURSES_DIR/corporate_culture_tsum_v1.0.zip" "$TEST_DATA_DIR/"

# 4. Создание helper класса для тестов
echo ""
echo "🔧 Создание helper класса для Cmi5 тестов..."
cat > "LMSUITests/Helpers/Cmi5TestHelper.swift" << 'EOF'
import Foundation
import XCTest

/// Helper для работы с Cmi5 тестовыми данными
class Cmi5TestHelper {
    
    /// Пути к тестовым Cmi5 пакетам
    enum TestPackage: String, CaseIterable {
        case aiFluency = "ai_fluency_course_v1.0.zip"
        case corporateCulture = "corporate_culture_tsum_v1.0.zip"
        
        var displayName: String {
            switch self {
            case .aiFluency:
                return "AI Fluency: Mastering Artificial Intelligence"
            case .corporateCulture:
                return "Корпоративная культура ЦУМ"
            }
        }
        
        var description: String {
            switch self {
            case .aiFluency:
                return "Comprehensive course on AI fundamentals and applications"
            case .corporateCulture:
                return "Введение в корпоративную культуру ЦУМ"
            }
        }
        
        /// Получить URL тестового пакета
        var url: URL? {
            let bundle = Bundle(for: Cmi5TestHelper.self)
            return bundle.url(forResource: rawValue.replacingOccurrences(of: ".zip", with: ""), 
                            withExtension: "zip",
                            subdirectory: "TestData/Cmi5Packages")
        }
    }
    
    /// Проверить доступность всех тестовых пакетов
    static func verifyTestPackages() -> Bool {
        for package in TestPackage.allCases {
            guard let url = package.url, FileManager.default.fileExists(atPath: url.path) else {
                print("❌ Тестовый пакет не найден: \(package.rawValue)")
                return false
            }
            print("✅ Тестовый пакет найден: \(package.displayName)")
        }
        return true
    }
    
    /// Загрузить тестовый пакет в приложение (mock)
    static func mockUploadPackage(_ package: TestPackage, in app: XCUIApplication) {
        // Эмулируем загрузку пакета через UI
        // В реальном приложении это будет file picker
        
        // Нажимаем кнопку загрузки
        app.buttons["Загрузить пакет"].tap()
        
        // В тестовом режиме выбираем из предустановленных
        let picker = app.sheets.firstMatch
        XCTAssertTrue(picker.waitForExistence(timeout: 5))
        
        // Выбираем нужный пакет
        picker.buttons[package.displayName].tap()
        
        // Ждем загрузки
        let progressIndicator = app.progressIndicators.firstMatch
        if progressIndicator.exists {
            // Ждем пока индикатор исчезнет (макс 30 сек)
            XCTAssertTrue(progressIndicator.waitForNonExistence(timeout: 30))
        }
    }
}

/// Расширение для UI тестов с Cmi5
extension XCTestCase {
    
    /// Подготовить Cmi5 тестовое окружение
    func setupCmi5TestEnvironment(in app: XCUIApplication) {
        // Проверяем наличие тестовых пакетов
        XCTAssertTrue(Cmi5TestHelper.verifyTestPackages(), 
                     "Cmi5 тестовые пакеты должны быть доступны")
        
        // Включаем Cmi5 модуль если нужно
        if !app.buttons["Cmi5 Контент"].exists {
            // Переходим в настройки
            app.tabBars.buttons["Ещё"].tap()
            app.buttons["Настройки"].tap()
            app.buttons["Feature Flags"].tap()
            
            // Включаем Cmi5
            let cmi5Toggle = app.switches["Cmi5 Контент"]
            if cmi5Toggle.exists && cmi5Toggle.value as? String == "0" {
                cmi5Toggle.tap()
            }
            
            // Возвращаемся
            app.navigationBars.buttons.firstMatch.tap()
            app.navigationBars.buttons.firstMatch.tap()
        }
    }
    
    /// Перейти к Cmi5 модулю
    func navigateToCmi5(in app: XCUIApplication) {
        // Проверяем, есть ли Cmi5 в табах
        if app.tabBars.buttons["Cmi5 Контент"].exists {
            app.tabBars.buttons["Cmi5 Контент"].tap()
        } else {
            // Иначе ищем в меню "Ещё"
            app.tabBars.buttons["Ещё"].tap()
            
            let cmi5Button = app.buttons["Cmi5 Контент"]
            XCTAssertTrue(cmi5Button.waitForExistence(timeout: 5))
            cmi5Button.tap()
        }
        
        // Ждем загрузки Cmi5 экрана
        XCTAssertTrue(app.navigationBars["Cmi5 Контент"].waitForExistence(timeout: 5))
    }
}
EOF

# 5. Обновление Info.plist для включения тестовых данных
echo ""
echo "📝 Обновление конфигурации тестов..."
if [ -f "LMSUITests/Info.plist" ]; then
    # Добавляем ресурсы в Info.plist если нужно
    echo "✅ Info.plist найден"
else
    # Создаем базовый Info.plist для UI тестов
    cat > "LMSUITests/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
</dict>
</plist>
EOF
fi

# 6. Создание mock сервиса для тестов
echo ""
echo "🎭 Создание mock Cmi5 сервиса..."
cat > "LMS/Services/Cmi5/MockCmi5Service.swift" << 'EOF'
import Foundation
import SwiftUI

/// Mock сервис для Cmi5 тестирования
class MockCmi5Service: ObservableObject {
    static let shared = MockCmi5Service()
    
    @Published var packages: [Cmi5Package] = []
    @Published var isLoading = false
    
    private init() {
        // Инициализируем с тестовыми пакетами в debug режиме
        #if DEBUG
        setupTestPackages()
        #endif
    }
    
    /// Настройка тестовых пакетов
    func setupTestPackages() {
        packages = [
            Cmi5Package(
                id: UUID(),
                title: "AI Fluency: Mastering Artificial Intelligence",
                description: "Comprehensive course on AI fundamentals and applications",
                version: "1.0",
                launchUrl: "index.html",
                activities: [
                    Cmi5Activity(
                        id: "activity_1",
                        title: "Introduction to AI",
                        description: "Basic concepts and history"
                    ),
                    Cmi5Activity(
                        id: "activity_2", 
                        title: "Machine Learning Basics",
                        description: "Understanding ML algorithms"
                    )
                ],
                metadata: Cmi5Metadata(
                    duration: "PT2H",
                    keywords: ["AI", "Machine Learning", "Technology"],
                    difficulty: "Beginner"
                )
            ),
            Cmi5Package(
                id: UUID(),
                title: "Корпоративная культура ЦУМ",
                description: "Введение в корпоративную культуру ЦУМ",
                version: "1.0",
                launchUrl: "index.html",
                activities: [
                    Cmi5Activity(
                        id: "culture_intro",
                        title: "Введение",
                        description: "Знакомство с ЦУМ"
                    ),
                    Cmi5Activity(
                        id: "culture_values",
                        title: "Наши ценности", 
                        description: "Основные принципы работы"
                    )
                ],
                metadata: Cmi5Metadata(
                    duration: "PT1H",
                    keywords: ["Культура", "ЦУМ", "Ценности"],
                    difficulty: "Beginner"
                )
            )
        ]
    }
    
    /// Загрузить пакет (mock)
    func uploadPackage(from url: URL) async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Эмулируем загрузку
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 секунда
        
        // В тестах просто добавляем фейковый пакет
        let newPackage = Cmi5Package(
            id: UUID(),
            title: "Uploaded: \(url.lastPathComponent)",
            description: "Test package uploaded from \(url.lastPathComponent)",
            version: "1.0",
            launchUrl: "index.html",
            activities: [],
            metadata: Cmi5Metadata(
                duration: "PT30M",
                keywords: ["Test"],
                difficulty: "Beginner"
            )
        )
        
        await MainActor.run {
            packages.append(newPackage)
        }
    }
    
    /// Удалить пакет
    func deletePackage(_ package: Cmi5Package) {
        packages.removeAll { $0.id == package.id }
    }
}
EOF

echo ""
echo "✅ Cmi5 тестовое окружение настроено!"
echo ""
echo "📋 Что было сделано:"
echo "  1. Скопированы Cmi5 пакеты в тестовую директорию"
echo "  2. Создан Cmi5TestHelper для работы с тестовыми данными"
echo "  3. Добавлены расширения для UI тестов"
echo "  4. Создан MockCmi5Service с предустановленными пакетами"
echo ""
echo "🎯 Теперь Cmi5 UI тесты должны работать!" 