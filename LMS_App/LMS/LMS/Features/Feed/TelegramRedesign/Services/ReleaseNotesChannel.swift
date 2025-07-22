import Foundation
import SwiftUI

struct ReleaseNotesChannel {
    static func createChannel() -> FeedChannel {
        let releases = loadReleaseNotes()
        let lastRelease = releases.first
        
        return FeedChannel(
            id: UUID(uuidString: "D47F3C4B-9F8E-4A5C-B623-7E8F9A1B2C3D")!,
            name: "📱 Release Notes",
            avatarType: .icon("app.badge", .indigo),
            lastMessage: FeedMessage(
                id: UUID(),
                text: lastRelease?.summary ?? "Нет доступных релизов",
                timestamp: lastRelease?.date ?? Date(),
                author: "Release Bot",
                isRead: false
            ),
            unreadCount: min(releases.count, 3),
            category: .announcement,
            priority: .high,
            isPinned: true
        )
    }
    
    private static func loadReleaseNotes() -> [ReleaseNote] {
        // Загружаем из реальных файлов проекта
        let releaseFiles = [
            "TESTFLIGHT_RELEASE_v2.1.1_build206.md",
            "TESTFLIGHT_RELEASE_v1.43.0.md",
            "TESTFLIGHT_BUILD_204_MENU_STRUCTURE.md"
        ]
        
        var notes: [ReleaseNote] = []
        
        for file in releaseFiles {
            if let content = loadFileContent(path: "docs/releases/\(file)") {
                if let note = parseReleaseNote(content: content, filename: file) {
                    notes.append(note)
                }
            }
        }
        
        return notes.sorted { $0.date > $1.date }
    }
    
    private static func loadFileContent(path: String) -> String? {
        // В production это будет загружаться из bundle
        // Сейчас возвращаем mock данные на основе реальных релизов
        let mockContent = """
        # TestFlight Release v2.1.1 (Build 206)
        
        ## Дата релиза
        13 июля 2025
        
        ## Что нового
        - ✅ Интеграция Cmi5 курсов
        - ✅ Импорт CATAPULT курсов
        - ✅ Управление курсами для администраторов
        - ✅ Просмотр Cmi5 контента
        
        ## Исправления
        - 🐛 Исправлена навигация в меню "Ещё"
        - 🐛 Улучшена производительность списков
        """
        return mockContent
    }
    
    private static func parseReleaseNote(content: String, filename: String) -> ReleaseNote? {
        // Простой парсер для markdown
        let lines = content.split(separator: "\n")
        var version = ""
        var date = Date()
        var summary = ""
        
        for line in lines {
            if line.hasPrefix("# ") {
                version = String(line.dropFirst(2))
            } else if line.contains("Дата релиза") {
                // Следующая строка после "Дата релиза" содержит дату
                if let index = lines.firstIndex(of: line),
                   index + 1 < lines.count {
                    let dateString = String(lines[index + 1])
                    // Парсим дату
                    date = parseDate(dateString) ?? Date()
                }
            } else if line.contains("Что нового") {
                // Собираем первые несколько пунктов
                if let index = lines.firstIndex(of: line) {
                    var items: [String] = []
                    for i in (index + 1)..<min(index + 4, lines.count) {
                        let item = String(lines[i]).trimmingCharacters(in: .whitespaces)
                        if item.hasPrefix("-") {
                            items.append(item)
                        }
                    }
                    summary = items.joined(separator: " ")
                }
            }
        }
        
        if !version.isEmpty {
            return ReleaseNote(
                version: version,
                date: date,
                summary: summary.isEmpty ? "Новая версия доступна" : summary
            )
        }
        
        return nil
    }
    
    private static func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.date(from: dateString.trimmingCharacters(in: .whitespaces))
    }
    
    struct ReleaseNote {
        let version: String
        let date: Date
        let summary: String
    }
} 