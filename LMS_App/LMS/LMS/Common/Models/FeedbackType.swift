import SwiftUI

/// Единый тип обращения для всей системы обратной связи
public enum FeedbackType: String, CaseIterable, Codable {
    case bug = "bug"
    case feature = "feature"
    case improvement = "improvement"
    case question = "question"
    
    /// Локализованное название на русском
    public var title: String {
        switch self {
        case .bug: return "Ошибка"
        case .feature: return "Предложение"
        case .improvement: return "Улучшение"
        case .question: return "Вопрос"
        }
    }
    
    /// Иконка SF Symbols
    public var icon: String {
        switch self {
        case .bug: return "ladybug"
        case .feature: return "lightbulb"
        case .improvement: return "wand.and.stars"
        case .question: return "questionmark.circle"
        }
    }
    
    /// Цвет для UI
    public var color: Color {
        switch self {
        case .bug: return .red
        case .feature: return .blue
        case .improvement: return .orange
        case .question: return .purple
        }
    }
    
    /// Label для GitHub Issues
    public var githubLabel: String {
        switch self {
        case .bug: return "bug"
        case .feature: return "enhancement"
        case .improvement: return "improvement"
        case .question: return "question"
        }
    }
    
    /// Emoji для отображения
    public var emoji: String {
        switch self {
        case .bug: return "🐛"
        case .feature: return "💡"
        case .improvement: return "✨"
        case .question: return "❓"
        }
    }
}
