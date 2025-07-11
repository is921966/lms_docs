//
//  BuildReleaseNews.swift
//  LMS
//
//  Модель для автоматического создания новостей о релизах
//

import Foundation

/// Модель новости о релизе билда
struct BuildReleaseNews {
    let id: UUID
    let version: String
    let buildNumber: String
    let releaseDate: Date
    let mainChanges: [ChangeCategory]
    let testingFocus: [String]
    let knownIssues: [String]
    let technicalInfo: TechnicalInfo
    
    /// Категории изменений
    struct ChangeCategory {
        let title: String
        let icon: String
        let changes: [String]
    }
    
    /// Техническая информация
    struct TechnicalInfo {
        let minIOSVersion: String
        let recommendedIOSVersion: String
        let appSize: String
    }
    
    /// Создать новость из Release Notes
    static func fromReleaseNotes(
        version: String,
        buildNumber: String,
        releaseNotesContent: String
    ) -> BuildReleaseNews {
        // Парсим содержимое release notes
        let parser = ReleaseNotesParser()
        let parsedData = parser.parse(releaseNotesContent)
        
        return BuildReleaseNews(
            id: UUID(),
            version: version,
            buildNumber: buildNumber,
            releaseDate: Date(),
            mainChanges: parsedData.changes,
            testingFocus: parsedData.testingFocus,
            knownIssues: parsedData.knownIssues,
            technicalInfo: parsedData.technicalInfo
        )
    }
    
    /// Преобразовать в FeedItem для отображения в ленте
    func toFeedItem() -> FeedItem {
        var content = """
        # 🚀 Новая версия \(version) (Build \(buildNumber))
        
        """
        
        // Добавляем основные изменения
        for category in mainChanges {
            content += "\n## \(category.icon) \(category.title)\n"
            for change in category.changes {
                content += "• \(change)\n"
            }
        }
        
        // Добавляем фокус тестирования
        if !testingFocus.isEmpty {
            content += "\n## 🔍 Что протестировать\n"
            for focus in testingFocus {
                content += "• \(focus)\n"
            }
        }
        
        // Добавляем известные проблемы
        if !knownIssues.isEmpty {
            content += "\n## ⚠️ Известные проблемы\n"
            for issue in knownIssues {
                content += "• \(issue)\n"
            }
        }
        
        return FeedItem(
            id: id,
            type: .announcement,
            title: "Доступна новая версия \(version)",
            content: content,
            author: "Команда разработки",
            publishedAt: releaseDate,
            imageURL: nil,
            tags: ["release", "update", "testflight"],
            priority: .high,
            metadata: [
                "version": version,
                "build": buildNumber,
                "type": "app_release"
            ]
        )
    }
}

/// Парсер Release Notes
class ReleaseNotesParser {
    struct ParsedData {
        let changes: [BuildReleaseNews.ChangeCategory]
        let testingFocus: [String]
        let knownIssues: [String]
        let technicalInfo: BuildReleaseNews.TechnicalInfo
    }
    
    func parse(_ content: String) -> ParsedData {
        // Простой парсер для markdown формата
        let lines = content.components(separatedBy: .newlines)
        var changes: [BuildReleaseNews.ChangeCategory] = []
        var testingFocus: [String] = []
        var knownIssues: [String] = []
        var currentSection = ""
        var currentCategory: BuildReleaseNews.ChangeCategory?
        var currentChanges: [String] = []
        
        for line in lines {
            // Определяем секции
            if line.hasPrefix("### ") {
                // Сохраняем предыдущую категорию
                if let category = currentCategory {
                    changes.append(BuildReleaseNews.ChangeCategory(
                        title: category.title,
                        icon: category.icon,
                        changes: currentChanges
                    ))
                }
                
                // Начинаем новую категорию
                let title = line.replacingOccurrences(of: "### ", with: "")
                let icon = extractIcon(from: title)
                currentCategory = BuildReleaseNews.ChangeCategory(
                    title: title.replacingOccurrences(of: icon + " ", with: ""),
                    icon: icon,
                    changes: []
                )
                currentChanges = []
            } else if line.hasPrefix("## ") {
                currentSection = line.replacingOccurrences(of: "## ", with: "")
            } else if line.hasPrefix("- ") || line.hasPrefix("• ") {
                let item = line
                    .replacingOccurrences(of: "- ", with: "")
                    .replacingOccurrences(of: "• ", with: "")
                    .trimmingCharacters(in: .whitespaces)
                
                if currentSection.contains("тестир") || currentSection.contains("провер") {
                    testingFocus.append(item)
                } else if currentSection.contains("проблем") || currentSection.contains("issue") {
                    knownIssues.append(item)
                } else if currentCategory != nil {
                    currentChanges.append(item)
                }
            }
        }
        
        // Сохраняем последнюю категорию
        if let category = currentCategory {
            changes.append(BuildReleaseNews.ChangeCategory(
                title: category.title,
                icon: category.icon,
                changes: currentChanges
            ))
        }
        
        // Технические данные (можно расширить парсинг)
        let technicalInfo = BuildReleaseNews.TechnicalInfo(
            minIOSVersion: "17.0",
            recommendedIOSVersion: "18.5",
            appSize: "~45 MB"
        )
        
        return ParsedData(
            changes: changes,
            testingFocus: testingFocus,
            knownIssues: knownIssues,
            technicalInfo: technicalInfo
        )
    }
    
    private func extractIcon(from title: String) -> String {
        // Извлекаем эмодзи из начала строки
        let emojis = ["✅", "🔧", "📱", "🐛", "📊", "🔍", "🎯", "⚠️", "🚀"]
        for emoji in emojis {
            if title.hasPrefix(emoji) {
                return emoji
            }
        }
        return "📌"
    }
} 