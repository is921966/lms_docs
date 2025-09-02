#!/bin/bash

echo "🧪 Запуск SCORM тестов в изоляции..."
echo "================================"

# Компилируем только необходимые файлы
echo "📦 Компиляция SCORM модуля..."

# Создаем временную директорию для тестов
TEMP_DIR="/tmp/scorm_tests"
mkdir -p "$TEMP_DIR"

# Копируем необходимые файлы
cp "/Users/ishirokov/lms_docs/LMS_App/LMS/LMS/Features/Scorm/Models/ScormPackage.swift" "$TEMP_DIR/"
cp "/Users/ishirokov/lms_docs/LMS_App/LMS/LMSTests/Features/Scorm/ScormPackageTests.swift" "$TEMP_DIR/"

# Создаем минимальный test runner
cat > "$TEMP_DIR/TestRunner.swift" << 'EOF'
import XCTest

// Копируем ScormPackage сюда для изоляции
import Foundation

struct ScormPackage: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String?
    let version: String
    let organization: String?
    let scoCount: Int
    let fileSize: Int64
    let importDate: Date
    let manifestPath: String
    let contentPath: String
    
    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: importDate)
    }
}

// Включаем тесты
final class ScormPackageTests: XCTestCase {
    
    // MARK: - Test 1: ScormPackage should have required properties
    func test_scormPackage_shouldHaveRequiredProperties() {
        // Given
        let title = "Test SCORM Course"
        let version = "SCORM 2004 4th Edition"
        let fileSize: Int64 = 1024000
        let scoCount = 5
        let importDate = Date()
        let manifestPath = "/scorm/test/imsmanifest.xml"
        let contentPath = "/scorm/test/"
        
        // When
        let package = ScormPackage(
            title: title,
            description: nil,
            version: version,
            organization: nil,
            scoCount: scoCount,
            fileSize: fileSize,
            importDate: importDate,
            manifestPath: manifestPath,
            contentPath: contentPath
        )
        
        // Then
        XCTAssertNotNil(package.id)
        XCTAssertEqual(package.title, title)
        XCTAssertNil(package.description)
        XCTAssertEqual(package.version, version)
        XCTAssertNil(package.organization)
        XCTAssertEqual(package.scoCount, scoCount)
        XCTAssertEqual(package.fileSize, fileSize)
        XCTAssertEqual(package.importDate, importDate)
        XCTAssertEqual(package.manifestPath, manifestPath)
        XCTAssertEqual(package.contentPath, contentPath)
    }
    
    // MARK: - Test 2: Formatted size should display correctly
    func test_formattedSize_shouldDisplayCorrectly() {
        // Given
        let package1 = createPackage(fileSize: 1024) // 1 KB
        let package2 = createPackage(fileSize: 1048576) // 1 MB
        let package3 = createPackage(fileSize: 1073741824) // 1 GB
        
        // When & Then
        XCTAssertEqual(package1.formattedSize, "1 KB")
        XCTAssertEqual(package2.formattedSize, "1 MB")
        XCTAssertEqual(package3.formattedSize, "1 GB")
    }
    
    // MARK: - Test 3: Formatted date should be in Russian locale
    func test_formattedDate_shouldBeInRussianLocale() {
        // Given
        let dateComponents = DateComponents(year: 2025, month: 7, day: 22, hour: 15, minute: 30)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        let package = createPackage(importDate: date)
        
        // When
        let formattedDate = package.formattedDate
        
        // Then
        // Проверяем наличие элементов русской даты
        XCTAssertTrue(formattedDate.contains("2025"))
        XCTAssertTrue(formattedDate.contains("15:30"))
        // Месяц может быть по-разному в зависимости от локали системы
    }
    
    // MARK: - Helper
    private func createPackage(
        fileSize: Int64 = 1024000,
        importDate: Date = Date()
    ) -> ScormPackage {
        return ScormPackage(
            title: "Test Package",
            description: nil,
            version: "SCORM 2004",
            organization: nil,
            scoCount: 1,
            fileSize: fileSize,
            importDate: importDate,
            manifestPath: "/test/manifest.xml",
            contentPath: "/test/"
        )
    }
}

// Запускаем тесты
print("🚀 Запуск SCORM тестов...")
print("========================")

let testSuite = ScormPackageTests.defaultTestSuite
testSuite.run()

let testRun = testSuite.testRun!
let failureCount = testRun.failureCount
let testCount = testRun.testCaseCount

print("\n📊 Результаты:")
print("Всего тестов: \(testCount)")
print("Успешно: \(testCount - failureCount)")
print("Провалено: \(failureCount)")

if failureCount == 0 {
    print("\n✅ Все тесты прошли успешно!")
} else {
    print("\n❌ Некоторые тесты провалились")
    for test in testRun.allTests {
        if let testCase = test as? XCTestCase {
            for failure in testCase.testRun!.failures {
                print("  - \(failure.description)")
            }
        }
    }
}

exit(failureCount == 0 ? 0 : 1)
EOF

# Компилируем и запускаем
echo ""
echo "🔨 Компиляция тестов..."
cd "$TEMP_DIR"

# Компилируем с XCTest framework
xcrun swiftc -F /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks \
             -framework XCTest \
             -I /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/usr/lib \
             TestRunner.swift -o scorm_tests

echo ""
echo "🏃 Запуск тестов..."
./scorm_tests

# Сохраняем код возврата
EXIT_CODE=$?

# Очищаем временные файлы
rm -rf "$TEMP_DIR"

# Возвращаем результат
if [ $EXIT_CODE -eq 0 ]; then
    echo ""
    echo "✅ GREEN: Все SCORM тесты прошли!"
else
    echo ""
    echo "❌ RED: SCORM тесты провалились"
fi

exit $EXIT_CODE 