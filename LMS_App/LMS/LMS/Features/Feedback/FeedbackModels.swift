import Foundation

/// Модель элемента фидбэка в ленте
struct FeedbackItem: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let type: FeedbackType
    let status: FeedbackStatus
    let author: String
    let authorId: String
    let createdAt: Date
    let updatedAt: Date
    let screenshot: String?
    let reactions: FeedbackReactions
    let comments: [FeedbackComment]
    let userReaction: ReactionType?
    let isOwnFeedback: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        type: FeedbackType,
        status: FeedbackStatus = .open,
        author: String,
        authorId: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        screenshot: String? = nil,
        reactions: FeedbackReactions = FeedbackReactions(),
        comments: [FeedbackComment] = [],
        userReaction: ReactionType? = nil,
        isOwnFeedback: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
        self.status = status
        self.author = author
        self.authorId = authorId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.screenshot = screenshot
        self.reactions = reactions
        self.comments = comments
        self.userReaction = userReaction
        self.isOwnFeedback = isOwnFeedback
    }
}

/// Типы фидбэков
enum FeedbackType: String, CaseIterable, Codable {
    case bug = "bug"
    case feature = "feature"
    case improvement = "improvement"
    case question = "question"
    
    var title: String {
        switch self {
        case .bug: return "Ошибка"
        case .feature: return "Функция"
        case .improvement: return "Улучшение"
        case .question: return "Вопрос"
        }
    }
    
    var icon: String {
        switch self {
        case .bug: return "ladybug"
        case .feature: return "star"
        case .improvement: return "arrow.up.circle"
        case .question: return "questionmark.circle"
        }
    }
    
    var color: String {
        switch self {
        case .bug: return "red"
        case .feature: return "blue"
        case .improvement: return "green"
        case .question: return "orange"
        }
    }
}

/// Статус фидбэка
enum FeedbackStatus: String, CaseIterable, Codable {
    case open = "open"
    case inProgress = "in_progress"
    case resolved = "resolved"
    case closed = "closed"
    
    var title: String {
        switch self {
        case .open: return "Открыт"
        case .inProgress: return "В работе"
        case .resolved: return "Решён"
        case .closed: return "Закрыт"
        }
    }
    
    var color: String {
        switch self {
        case .open: return "blue"
        case .inProgress: return "orange"
        case .resolved: return "green"
        case .closed: return "gray"
        }
    }
}

/// Типы реакций
enum ReactionType: String, CaseIterable, Codable {
    case like = "like"
    case dislike = "dislike"
    case heart = "heart"
    case fire = "fire"
    
    var emoji: String {
        switch self {
        case .like: return "👍"
        case .dislike: return "👎"
        case .heart: return "❤️"
        case .fire: return "🔥"
        }
    }
}

/// Количество реакций на фидбэк
struct FeedbackReactions: Codable {
    var like: Int
    var dislike: Int
    var heart: Int
    var fire: Int
    
    init(like: Int = 0, dislike: Int = 0, heart: Int = 0, fire: Int = 0) {
        self.like = like
        self.dislike = dislike
        self.heart = heart
        self.fire = fire
    }
}

/// Комментарий к фидбэку
struct FeedbackComment: Identifiable, Codable {
    let id: UUID
    let text: String
    let author: String
    let authorId: String
    let createdAt: Date
    let isAdmin: Bool
    
    init(
        id: UUID = UUID(),
        text: String,
        author: String,
        authorId: String,
        createdAt: Date = Date(),
        isAdmin: Bool = false
    ) {
        self.id = id
        self.text = text
        self.author = author
        self.authorId = authorId
        self.createdAt = createdAt
        self.isAdmin = isAdmin
    }
}
