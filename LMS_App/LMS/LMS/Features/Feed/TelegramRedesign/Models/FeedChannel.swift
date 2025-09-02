//
//  FeedChannel.swift
//  LMS
//
//  Модель канала для Telegram-style feed
//

import Foundation
import SwiftUI

/// Типы каналов
enum ChannelType: String, CaseIterable {
    case releases = "releases"          // Релизные заметки
    case sprints = "sprints"           // Отчеты о спринтах  
    case methodology = "methodology"    // Методология
    case courses = "courses"           // Новости о курсах
    case admin = "admin"               // Администрация
    case hr = "hr"                     // HR новости
    case myCourses = "my_courses"      // Мои курсы
    case userPosts = "user_posts"      // Посты пользователей
    
    var name: String {
        switch self {
        case .releases: return "📱 Релизы и обновления"
        case .sprints: return "🚀 Спринты разработки"
        case .methodology: return "📚 Методология"
        case .courses: return "🎓 Новые курсы"
        case .admin: return "🛡 Администрация"
        case .hr: return "👥 HR и команда"
        case .myCourses: return "📖 Мои курсы"
        case .userPosts: return "💬 Сообщество"
        }
    }
    
    var icon: String {
        switch self {
        case .releases: return "app.badge"
        case .sprints: return "chart.line.uptrend.xyaxis"
        case .methodology: return "book.closed"
        case .courses: return "graduationcap"
        case .admin: return "shield"
        case .hr: return "person.3"
        case .myCourses: return "books.vertical"
        case .userPosts: return "bubble.left.and.bubble.right"
        }
    }
    
    var color: Color {
        switch self {
        case .releases: return .blue
        case .sprints: return .green
        case .methodology: return .purple
        case .courses: return .orange
        case .admin: return .red
        case .hr: return .teal
        case .myCourses: return .indigo
        case .userPosts: return .pink
        }
    }
    
    var sourcePattern: String? {
        switch self {
        case .releases: return "docs/releases/"
        case .sprints: return "reports/sprints/"
        case .methodology: return "methodology/"
        default: return nil
        }
    }
}

/// Модель канала ленты
struct FeedChannel: Identifiable, Equatable {
    let id: String
    let type: ChannelType
    let name: String
    let avatar: FeedChannelAvatar
    let description: String
    let lastMessage: FeedMessage
    let unreadCount: Int
    let isPinned: Bool
    let isMuted: Bool
    let members: Int
    let isVerified: Bool
    let customData: [String: Any]?
    
    init(
        id: String = UUID().uuidString,
        type: ChannelType,
        name: String? = nil,
        avatar: FeedChannelAvatar? = nil,
        description: String = "",
        lastMessage: FeedMessage,
        unreadCount: Int = 0,
        isPinned: Bool = false,
        isMuted: Bool = false,
        members: Int = 0,
        isVerified: Bool = false,
        customData: [String: Any]? = nil
    ) {
        self.id = id
        self.type = type
        self.name = name ?? type.name
        self.avatar = avatar ?? FeedChannelAvatar(
            type: .icon(type.icon),
            backgroundColor: type.color
        )
        self.description = description
        self.lastMessage = lastMessage
        self.unreadCount = unreadCount
        self.isPinned = isPinned
        self.isMuted = isMuted
        self.members = members
        self.isVerified = isVerified
        self.customData = customData
    }
    
    static func == (lhs: FeedChannel, rhs: FeedChannel) -> Bool {
        lhs.id == rhs.id
    }
    
    var hasUnread: Bool {
        return unreadCount > 0
    }
}

/// Аватар канала
struct FeedChannelAvatar: Equatable {
    enum AvatarType: Equatable {
        case image(String)
        case icon(String)
        case text(String)
    }
    
    let type: AvatarType
    let backgroundColor: Color
    
    static func == (lhs: FeedChannelAvatar, rhs: FeedChannelAvatar) -> Bool {
        lhs.type == rhs.type && lhs.backgroundColor == rhs.backgroundColor
    }
}

/// Сообщение в канале
struct FeedMessage: Identifiable, Equatable {
    let id: String
    let content: String
    let author: String
    let date: Date
    let isRead: Bool
    
    init(
        id: String = UUID().uuidString,
        content: String,
        author: String,
        date: Date = Date(),
        isRead: Bool = false
    ) {
        self.id = id
        self.content = content
        self.author = author
        self.date = date
        self.isRead = isRead
    }
    
    static func == (lhs: FeedMessage, rhs: FeedMessage) -> Bool {
        lhs.id == rhs.id
    }
    
    var timestamp: Date {
        return date
    }
}

/// Фильтры для каналов
enum FeedFilter: String, CaseIterable {
    case all = "all"
    case unread = "unread"
    case personal = "personal"
    case channels = "channels"
    case groups = "groups"
    case bots = "bots"
    
    var title: String {
        switch self {
        case .all: return "Все"
        case .unread: return "Непрочитанные"
        case .personal: return "Личные"
        case .channels: return "Каналы"
        case .groups: return "Группы"
        case .bots: return "Боты"
        }
    }
}

/// Создание каналов из постов
extension FeedChannel {
    static func fromPosts(_ posts: [FeedPost], type: ChannelType) -> FeedChannel? {
        guard let lastPost = posts.first else { return nil }
        
        let unreadCount = posts.filter { post in
            // Считаем непрочитанными посты за последние 24 часа
            Date().timeIntervalSince(post.createdAt) < 86400
        }.count
        
        let lastMessage = FeedMessage(
            content: lastPost.content.prefix(100) + "...",
            author: lastPost.author.name,
            date: lastPost.createdAt,
            isRead: unreadCount == 0
        )
        
        // Используем стабильный ID основанный на типе канала
        let channelId = "channel-\(type.rawValue)"
        
        return FeedChannel(
            id: channelId,
            type: type,
            description: "Последние обновления",
            lastMessage: lastMessage,
            unreadCount: unreadCount,
            isPinned: type == .releases || type == .admin,
            members: posts.map { $0.author.id }.unique().count,
            isVerified: true
        )
    }
}

// Helper extension for unique array elements
extension Array where Element: Hashable {
    func unique() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

// Standard channel instances
extension FeedChannel {
    static let releasesChannel = FeedChannel(
        id: "channel-releases",
        type: .releases,
        description: "Обновления приложения и новые функции",
        lastMessage: FeedMessage(content: "Загрузка...", author: "Система", date: Date()),
        isPinned: true,
        isVerified: true
    )
    
    static let sprintsChannel = FeedChannel(
        id: "channel-sprints",
        type: .sprints,
        description: "Отчеты о ходе разработки",
        lastMessage: FeedMessage(content: "Загрузка...", author: "Система", date: Date()),
        isVerified: true
    )
    
    static let methodologyChannel = FeedChannel(
        id: "channel-methodology",
        type: .methodology,
        description: "Обновления методологии разработки",
        lastMessage: FeedMessage(content: "Загрузка...", author: "Система", date: Date()),
        isVerified: true
    )
    
    static let coursesChannel = FeedChannel(
        id: "channel-courses",
        type: .courses,
        description: "Новые курсы и образовательные программы",
        lastMessage: FeedMessage(content: "Загрузка...", author: "Система", date: Date()),
        isVerified: true
    )
    
    static let adminChannel = FeedChannel(
        id: "channel-admin",
        type: .admin,
        description: "Важные объявления от администрации",
        lastMessage: FeedMessage(content: "Загрузка...", author: "Система", date: Date()),
        isPinned: true,
        isVerified: true
    )
    
    static let hrChannel = FeedChannel(
        id: "channel-hr",
        type: .hr,
        description: "Новости от HR отдела",
        lastMessage: FeedMessage(content: "Загрузка...", author: "Система", date: Date()),
        isVerified: true
    )
    
    static let myCoursesChannel = FeedChannel(
        id: "channel-my_courses",
        type: .myCourses,
        description: "Ваши назначенные курсы",
        lastMessage: FeedMessage(content: "Загрузка...", author: "Система", date: Date()),
        isVerified: true
    )
    
    static let userPostsChannel = FeedChannel(
        id: "channel-user_posts",
        type: .userPosts,
        description: "Обсуждения сообщества",
        lastMessage: FeedMessage(content: "Загрузка...", author: "Система", date: Date()),
        isVerified: true
    )
} 