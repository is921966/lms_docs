import Foundation
import SwiftUI

extension NewsCategory {
    var title: String {
        switch self {
        case .announcement:
            return "Объявления"
        case .learning:
            return "Обучение"
        case .achievement:
            return "Достижения"
        case .event:
            return "События"
        case .department:
            return "Департаменты"
        }
    }
    
    var icon: String {
        switch self {
        case .announcement:
            return "megaphone"
        case .learning:
            return "graduationcap"
        case .achievement:
            return "star.fill"
        case .event:
            return "calendar"
        case .department:
            return "building.2"
        }
    }
    
    var color: Color {
        switch self {
        case .announcement:
            return .red
        case .learning:
            return .blue
        case .achievement:
            return .yellow
        case .event:
            return .green
        case .department:
            return .purple
        }
    }
    
    static var supportedPriorities: [ChannelPriority] {
        return [.normal, .high, .critical]
    }
}

extension ChannelPriority {
    var title: String {
        switch self {
        case .critical:
            return "Критический"
        case .high:
            return "Высокий"
        case .normal:
            return "Обычный"
        case .low:
            return "Низкий"
        }
    }
} 