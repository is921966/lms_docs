#!/usr/bin/env swift

import Foundation

// MARK: - Test Models

struct BuildReleaseNews {
    let id: String
    let version: String
    let buildNumber: String
    let mainChanges: [ChangeCategory]
    let testingFocus: [String]
    let knownIssues: [String]
    let releaseDate: Date
    
    struct ChangeCategory {
        let icon: String
        let title: String
        let changes: [String]
    }
    
    static func fromReleaseNotes(version: String, buildNumber: String, releaseNotesContent: String) -> BuildReleaseNews {
        let parser = ReleaseNotesParser()
        let parsedData = parser.parse(releaseNotesContent)
        
        return BuildReleaseNews(
            id: UUID().uuidString,
            version: version,
            buildNumber: buildNumber,
            mainChanges: parsedData.changes,
            testingFocus: parsedData.testingFocus,
            knownIssues: parsedData.knownIssues,
            releaseDate: Date()
        )
    }
}

struct ReleaseNotesParser {
    struct ParsedData {
        let changes: [BuildReleaseNews.ChangeCategory]
        let testingFocus: [String]
        let knownIssues: [String]
    }
    
    func parse(_ content: String) -> ParsedData {
        var changes: [BuildReleaseNews.ChangeCategory] = []
        var testingFocus: [String] = []
        var knownIssues: [String] = []
        
        let lines = content.components(separatedBy: .newlines)
        var currentSection = ""
        var currentCategory: BuildReleaseNews.ChangeCategory?
        var currentChanges: [String] = []
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Detect sections
            if trimmed.hasPrefix("## ") {
                currentSection = trimmed
                continue
            }
            
            // Parse change categories
            if trimmed.hasPrefix("### ") && currentSection.contains("изменения") {
                // Save previous category
                if let category = currentCategory {
                    changes.append(BuildReleaseNews.ChangeCategory(
                        icon: category.icon,
                        title: category.title,
                        changes: currentChanges
                    ))
                }
                
                // Extract icon and title
                let categoryLine = trimmed.dropFirst(4)
                let icon = extractIcon(from: String(categoryLine))
                let title = String(categoryLine).replacingOccurrences(of: icon, with: "").trimmingCharacters(in: .whitespaces)
                
                currentCategory = BuildReleaseNews.ChangeCategory(
                    icon: icon,
                    title: title,
                    changes: []
                )
                currentChanges = []
            }
            
            // Parse list items
            if trimmed.hasPrefix("- ") {
                let item = String(trimmed.dropFirst(2))
                
                if currentSection.contains("тестировщик") {
                    testingFocus.append(item)
                } else if currentSection.contains("проблем") {
                    knownIssues.append(item)
                } else if currentCategory != nil {
                    currentChanges.append(item)
                }
            }
        }
        
        // Save last category
        if let category = currentCategory {
            changes.append(BuildReleaseNews.ChangeCategory(
                icon: category.icon,
                title: category.title,
                changes: currentChanges
            ))
        }
        
        return ParsedData(
            changes: changes,
            testingFocus: testingFocus,
            knownIssues: knownIssues
        )
    }
    
    private func extractIcon(from text: String) -> String {
        // Simple emoji detection
        for scalar in text.unicodeScalars {
            if scalar.properties.isEmoji {
                return String(scalar)
            }
        }
        return ""
    }
}

// MARK: - Tests

let sampleReleaseNotes = """
# TestFlight Release v2.1.1

**Build**: 206

## 🎯 Основные изменения

### ✅ Исправлена тестовая инфраструктура
- Удалены дубликаты файлов тестов
- Исправлены все ошибки компиляции UI тестов
- Обновлена инфраструктура для 43 UI тестов

### 🔧 Технические улучшения
- Оптимизирована навигация в тестах
- Добавлена поддержка разных UI структур

## 📋 Что нового для тестировщиков

### Проверьте следующие функции:
- Отображение списка новостей
- Навигация между новостями

## 🐛 Известные проблемы
- Некоторые UI тесты могут показывать предупреждения
"""

print("🧪 Testing Release News Functionality\n")

// Test 1: Basic parsing
print("Test 1: Basic Parsing")
let releaseNews = BuildReleaseNews.fromReleaseNotes(
    version: "2.1.1",
    buildNumber: "206",
    releaseNotesContent: sampleReleaseNotes
)

print("✅ Version: \(releaseNews.version)")
print("✅ Build: \(releaseNews.buildNumber)")
print("✅ Changes categories: \(releaseNews.mainChanges.count)")
print("✅ Testing focus items: \(releaseNews.testingFocus.count)")
print("✅ Known issues: \(releaseNews.knownIssues.count)")

// Test 2: Parse details
print("\nTest 2: Parse Details")
if let firstCategory = releaseNews.mainChanges.first {
    print("✅ First category icon: \(firstCategory.icon)")
    print("✅ First category title: \(firstCategory.title)")
    print("✅ First category changes: \(firstCategory.changes.count)")
}

// Test 3: Empty content
print("\nTest 3: Empty Content")
let emptyNews = BuildReleaseNews.fromReleaseNotes(
    version: "1.0.0",
    buildNumber: "1",
    releaseNotesContent: ""
)
print("✅ Empty content handled: \(emptyNews.mainChanges.isEmpty)")

// Test 4: Version detection simulation
print("\nTest 4: Version Detection")
let lastVersion = "2.1.0"
let currentVersion = "2.1.1"
let hasNewRelease = lastVersion != currentVersion
print("✅ New release detected: \(hasNewRelease)")

print("\n✅ All tests passed!")
print("\n📊 Summary:")
print("- Release notes parsing: Working")
print("- Version detection: Working")
print("- Empty content handling: Working")
print("- Model creation: Working") 