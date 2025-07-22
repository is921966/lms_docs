import Foundation
import SwiftUI

struct MethodologyChannel {
    static func createChannel() -> FeedChannel {
        let latestUpdate = getLatestMethodologyUpdate()
        
        return FeedChannel(
            id: UUID(uuidString: "F69E5C7D-2B4F-4C8E-D935-9F1D3B6E7C8A")!,
            name: "📚 TDD Методология",
            avatarType: .icon("doc.text.fill", .orange),
            lastMessage: FeedMessage(
                id: UUID(),
                text: latestUpdate.summary,
                timestamp: latestUpdate.date,
                author: "Methodology Bot",
                isRead: false
            ),
            unreadCount: 1,
            category: .learning,
            priority: .normal
        )
    }
    
    private static func getLatestMethodologyUpdate() -> MethodologyUpdate {
        // В реальном приложении загружаем из файлов проекта
        return MethodologyUpdate(
            version: "2.0.0",
            date: Date(timeIntervalSinceNow: -86400), // Вчера
            summary: "Методология v2.0: Модульный подход к планированию спринтов. Каждый спринт = готовый production модуль."
        )
    }
    
    struct MethodologyUpdate {
        let version: String
        let date: Date
        let summary: String
    }
} 