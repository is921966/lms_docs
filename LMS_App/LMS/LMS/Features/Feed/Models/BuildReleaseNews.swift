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
        <div style="font-family: -apple-system, system-ui; padding: 10px;">
            <h1 style="font-size: 24px; margin-bottom: 15px;">
                🚀 Новая версия \(version) <span style="color: #666; font-size: 18px;">(Build \(buildNumber))</span>
            </h1>
        """
        
        // Добавляем основные изменения
        for category in mainChanges {
            content += """
            
            <div style="margin-top: 20px;">
                <h2 style="font-size: 20px; color: #333; margin-bottom: 10px;">
                    \(category.icon) \(category.title)
                </h2>
                <ul style="margin: 0; padding-left: 20px;">
            """
            
            for change in category.changes {
                content += """
                    <li style="margin-bottom: 5px; color: #555; line-height: 1.5;">\(change)</li>
                """
            }
            
            content += """
                </ul>
            </div>
            """
        }
        
        // Добавляем фокус тестирования
        if !testingFocus.isEmpty {
            content += """
            
            <div style="margin-top: 20px;">
                <h2 style="font-size: 20px; color: #333; margin-bottom: 10px;">
                    🔍 Что протестировать
                </h2>
                <ul style="margin: 0; padding-left: 20px;">
            """
            
            for focus in testingFocus {
                content += """
                    <li style="margin-bottom: 5px; color: #555; line-height: 1.5;">\(focus)</li>
                """
            }
            
            content += """
                </ul>
            </div>
            """
        }
        
        // Добавляем известные проблемы
        if !knownIssues.isEmpty {
            content += """
            
            <div style="margin-top: 20px;">
                <h2 style="font-size: 20px; color: #FF6B6B; margin-bottom: 10px;">
                    ⚠️ Известные проблемы
                </h2>
                <ul style="margin: 0; padding-left: 20px;">
            """
            
            for issue in knownIssues {
                content += """
                    <li style="margin-bottom: 5px; color: #FF6B6B; line-height: 1.5;">\(issue)</li>
                """
            }
            
            content += """
                </ul>
            </div>
            """
        }
        
        // Добавляем техническую информацию
        content += """
        
        <div style="margin-top: 25px; padding: 15px; background-color: #f5f5f5; border-radius: 8px;">
            <h3 style="font-size: 16px; color: #666; margin-bottom: 8px;">📱 Техническая информация</h3>
            <p style="margin: 3px 0; color: #888; font-size: 14px;">
                Минимальная версия iOS: \(technicalInfo.minIOSVersion)<br>
                Рекомендуемая версия iOS: \(technicalInfo.recommendedIOSVersion)<br>
                Размер приложения: \(technicalInfo.appSize)
            </p>
        </div>
        
        </div>
        """
        
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
                "type": "app_release",
                "contentType": "html"
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