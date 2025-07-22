//
//  FeedItem.swift
//  LMS
//
//  Модель элемента ленты новостей
//

import Foundation

/// Элемент ленты новостей
struct FeedItem: Identifiable, Codable, Equatable {
    let id: UUID
    let type: FeedItemType
    let title: String
    let content: String
    let author: String
    let publishedAt: Date
    let imageURL: String?
    let tags: [String]
    let priority: Priority
    let metadata: [String: String]
    var isRead: Bool
    
    init(
        id: UUID = UUID(),
        type: FeedItemType,
        title: String,
        content: String,
        author: String,
        publishedAt: Date = Date(),
        imageURL: String? = nil,
        tags: [String] = [],
        priority: Priority = .normal,
        metadata: [String: String] = [:],
        isRead: Bool = false
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.content = content
        self.author = author
        self.publishedAt = publishedAt
        self.imageURL = imageURL
        self.tags = tags
        self.priority = priority
        self.metadata = metadata
        self.isRead = isRead
    }
}

// MARK: - Feed Item Type

extension FeedItem {
    /// Тип элемента ленты
    enum FeedItemType: String, Codable, CaseIterable {
        case news = "news"
        case announcement = "announcement"
        case update = "update"
        case event = "event"
        case achievement = "achievement"
        case course = "course"
        case release = "release"
        
        var localizedName: String {
            switch self {
            case .news: return "Новость"
            case .announcement: return "Объявление"
            case .update: return "Обновление"
            case .event: return "Событие"
            case .achievement: return "Достижение"
            case .course: return "Курс"
            case .release: return "Релиз"
            }
        }
        
        var icon: String {
            switch self {
            case .news: return "newspaper"
            case .announcement: return "megaphone"
            case .update: return "arrow.clockwise.circle"
            case .event: return "calendar"
            case .achievement: return "trophy"
            case .course: return "book"
            case .release: return "app.badge"
            }
        }
        
        var color: String {
            switch self {
            case .news: return "blue"
            case .announcement: return "orange"
            case .update: return "green"
            case .event: return "purple"
            case .achievement: return "yellow"
            case .course: return "teal"
            case .release: return "red"
            }
        }
    }
}

// MARK: - Priority

extension FeedItem {
    /// Приоритет элемента
    enum Priority: String, Codable, Comparable {
        case low = "low"
        case normal = "normal"
        case high = "high"
        case urgent = "urgent"
        
        var sortOrder: Int {
            switch self {
            case .low: return 0
            case .normal: return 1
            case .high: return 2
            case .urgent: return 3
            }
        }
        
        static func < (lhs: Priority, rhs: Priority) -> Bool {
            return lhs.sortOrder < rhs.sortOrder
        }
    }
}

// MARK: - Helper Methods

extension FeedItem {
    /// Форматированная дата публикации
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        
        let calendar = Calendar.current
        if calendar.isDateInToday(publishedAt) {
            formatter.dateFormat = "Сегодня в HH:mm"
        } else if calendar.isDateInYesterday(publishedAt) {
            formatter.dateFormat = "Вчера в HH:mm"
        } else if calendar.isDate(publishedAt, equalTo: Date(), toGranularity: .year) {
            formatter.dateFormat = "d MMMM в HH:mm"
        } else {
            formatter.dateFormat = "d MMMM yyyy"
        }
        
        return formatter.string(from: publishedAt)
    }
    
    /// Краткое содержание
    var summary: String {
        let maxLength = 150
        if content.count <= maxLength {
            return content
        }
        
        let index = content.index(content.startIndex, offsetBy: maxLength)
        return String(content[..<index]) + "..."
    }
    
    /// Проверка, является ли новость важной
    var isImportant: Bool {
        return priority == .high || priority == .urgent || type == .announcement || type == .release
    }
}

// MARK: - Mock Data

extension FeedItem {
    static var mockItems: [FeedItem] {
        [
            FeedItem(
                type: .announcement,
                title: "Доступна новая версия 2.1.1",
                content: """
                <div style="font-family: -apple-system, system-ui; padding: 10px;">
                    <h1 style="font-size: 24px; margin-bottom: 15px;">
                        🚀 Новая версия 2.1.1 <span style="color: #666; font-size: 18px;">(Build 206)</span>
                    </h1>
                    
                    <div style="margin-top: 20px;">
                        <h2 style="font-size: 20px; color: #333; margin-bottom: 10px;">
                            ✅ Исправлена тестовая инфраструктура
                        </h2>
                        <ul style="margin: 0; padding-left: 20px;">
                            <li style="margin-bottom: 5px; color: #555; line-height: 1.5;">Удалены дубликаты файлов тестов</li>
                            <li style="margin-bottom: 5px; color: #555; line-height: 1.5;">Исправлены все ошибки компиляции UI тестов</li>
                            <li style="margin-bottom: 5px; color: #555; line-height: 1.5;">Обновлена инфраструктура для 43 UI тестов</li>
                        </ul>
                    </div>
                    
                    <div style="margin-top: 20px;">
                        <h2 style="font-size: 20px; color: #333; margin-bottom: 10px;">
                            🔧 Технические улучшения
                        </h2>
                        <ul style="margin: 0; padding-left: 20px;">
                            <li style="margin-bottom: 5px; color: #555; line-height: 1.5;">Оптимизирована навигация в тестах</li>
                            <li style="margin-bottom: 5px; color: #555; line-height: 1.5;">Добавлена поддержка разных UI структур</li>
                        </ul>
                    </div>
                    
                    <div style="margin-top: 25px; padding: 15px; background-color: #f5f5f5; border-radius: 8px;">
                        <h3 style="font-size: 16px; color: #666; margin-bottom: 8px;">📱 Техническая информация</h3>
                        <p style="margin: 3px 0; color: #888; font-size: 14px;">
                            Минимальная версия iOS: 17.0<br>
                            Рекомендуемая версия iOS: 18.5<br>
                            Размер приложения: ~45 MB
                        </p>
                    </div>
                </div>
                """,
                author: "Команда разработки",
                tags: ["release", "update", "testflight"],
                priority: .high,
                metadata: [
                    "type": "app_release",
                    "contentType": "html",
                    "version": "2.1.1",
                    "build": "206"
                ]
            ),
            FeedItem(
                type: .news,
                title: "Новый курс по машинному обучению",
                content: "Запущен новый курс по основам машинного обучения. Курс включает практические задания и проекты.",
                author: "Учебный отдел",
                publishedAt: Date().addingTimeInterval(-86400),
                tags: ["курсы", "ML", "обучение"],
                priority: .normal
            ),
            FeedItem(
                type: .event,
                title: "Вебинар по Swift UI",
                content: "Приглашаем на вебинар по разработке приложений с использованием SwiftUI. Начало в 15:00.",
                author: "HR отдел",
                publishedAt: Date().addingTimeInterval(-172800),
                tags: ["вебинар", "iOS", "SwiftUI"],
                priority: .normal
            )
        ]
    }
} 