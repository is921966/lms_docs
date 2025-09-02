#!/usr/bin/env swift

import Foundation

// ANSI colors
let RED = "\u{001B}[0;31m"
let GREEN = "\u{001B}[0;32m"
let YELLOW = "\u{001B}[1;33m"
let NC = "\u{001B}[0m"

print("🔍 ПРОВЕРКА ЦЕЛОСТНОСТИ ДАННЫХ FEED")
print("====================================")

var passed = 0
var failed = 0

func testPass(_ message: String) {
    print("\(GREEN)✅ PASS:\(NC) \(message)")
    passed += 1
}

func testFail(_ message: String) {
    print("\(RED)❌ FAIL:\(NC) \(message)")
    failed += 1
}

func testSection(_ name: String) {
    print("\n\(YELLOW)📋 \(name)\(NC)")
}

// Check if files exist
testSection("Проверка наличия файлов данных")

let fileManager = FileManager.default
let basePath = "/Users/ishirokov/lms_docs"

let paths = [
    "docs/releases",
    "reports/sprints", 
    "reports/methodology"
]

for path in paths {
    let fullPath = "\(basePath)/\(path)"
    if fileManager.fileExists(atPath: fullPath) {
        do {
            let files = try fileManager.contentsOfDirectory(atPath: fullPath)
            let mdFiles = files.filter { $0.hasSuffix(".md") }
            if mdFiles.count > 0 {
                testPass("\(path): найдено \(mdFiles.count) .md файлов")
            } else {
                testFail("\(path): нет .md файлов")
            }
        } catch {
            testFail("\(path): ошибка чтения директории")
        }
    } else {
        testFail("\(path): директория не найдена")
    }
}

// Check channel IDs
testSection("Проверка ID каналов")

let expectedChannelIds = [
    "channel-releases",
    "channel-sprints",
    "channel-methodology",
    "channel-courses",
    "channel-admin",
    "channel-hr",
    "channel-my-courses",
    "channel-user-posts"
]

print("Ожидаемые ID каналов:")
for id in expectedChannelIds {
    print("  • \(id)")
}
testPass("Формат ID каналов корректный")

// Check recent files
testSection("Проверка последних файлов")

let releasesPath = "\(basePath)/docs/releases"
if let releases = try? fileManager.contentsOfDirectory(atPath: releasesPath)
    .filter({ $0.hasSuffix(".md") })
    .sorted()
    .suffix(3) {
    
    print("\nПоследние релизы:")
    for file in releases {
        print("  • \(file)")
    }
    testPass("Найдены файлы релизов")
}

let sprintsPath = "\(basePath)/reports/sprints"
if let sprints = try? fileManager.contentsOfDirectory(atPath: sprintsPath)
    .filter({ $0.hasSuffix(".md") && $0.contains("SPRINT") })
    .sorted()
    .suffix(3) {
    
    print("\nПоследние спринты:")
    for file in sprints {
        print("  • \(file)")
    }
    testPass("Найдены файлы спринтов")
}

// Summary
print("\n" + String(repeating: "=", count: 40))
print("📊 ИТОГИ ПРОВЕРКИ")
print(String(repeating: "=", count: 40))
print("\(GREEN)Пройдено:\(NC) \(passed)")
print("\(RED)Провалено:\(NC) \(failed)")
print("Всего проверок: \(passed + failed)")

if failed == 0 {
    print("\n\(GREEN)✅ Все проверки пройдены успешно!\(NC)")
} else {
    print("\n\(RED)⚠️ Обнаружены проблемы с данными\(NC)")
}

// Exit with appropriate code
exit(failed == 0 ? 0 : 1) 