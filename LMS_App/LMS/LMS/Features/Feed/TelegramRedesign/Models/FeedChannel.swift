//
//  FeedChannel.swift
//  LMS
//
//  Sprint 50 - Модель канала новостей в стиле Telegram
//

import Foundation
import SwiftUI

enum ChannelAvatarType: Equatable {
    case icon(String, Color)
    case image(String)
    case text(String, Color)
}

enum ChannelPriority: String, CaseIterable {
    case critical = "critical"
    case high = "high"
    case normal = "normal"
    case low = "low"
    
    var sortOrder: Int {
        switch self {
        case .critical: return 0
        case .high: return 1
        case .normal: return 2
        case .low: return 3
        }
    }
    
    var displayName: String {
        switch self {
        case .critical: return "Критический"
        case .high: return "Высокий"
        case .normal: return "Обычный"
        case .low: return "Низкий"
        }
    }
}

struct FeedChannel: Identifiable, Equatable {
    let id: UUID
    let name: String
    let avatarType: ChannelAvatarType
    var lastMessage: FeedMessage
    var unreadCount: Int
    let category: NewsCategory
    let priority: ChannelPriority
    var isPinned: Bool = false
    var isMuted: Bool = false
    
    var hasUnread: Bool {
        unreadCount > 0
    }
    
    static var mock: FeedChannel {
        FeedChannel(
            id: UUID(),
            name: "Новости компании",
            avatarType: .icon("megaphone.fill", .blue),
            lastMessage: FeedMessage(
                id: UUID(),
                text: "Поздравляем с успешным завершением квартала!",
                timestamp: Date(),
                author: "HR Department",
                isRead: false
            ),
            unreadCount: 3,
            category: .announcement,
            priority: .high
        )
    }
}

/// Категория новостей
enum NewsCategory: String, Codable, CaseIterable {
    case announcement
    case learning
    case achievement
    case event
    case department
    
    var displayName: String {
        switch self {
        case .announcement: return "Объявления"
        case .learning: return "Обучение"
        case .achievement: return "Достижения"
        case .event: return "События"
        case .department: return "Департамент"
        }
    }
} 