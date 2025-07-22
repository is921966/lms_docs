import Foundation
import SwiftUI

struct SprintReportsChannel {
    static func createChannel() -> FeedChannel {
        let latestReport = getLatestSprintReport()
        
        return FeedChannel(
            id: UUID(uuidString: "E58F4D5C-1A3E-4B7D-C834-8F9E2B4C5E6F")!,
            name: "📊 Sprint Отчеты",
            avatarType: .icon("chart.line.uptrend.xyaxis", .green),
            lastMessage: FeedMessage(
                id: UUID(),
                text: latestReport.summary,
                timestamp: latestReport.date,
                author: "Sprint Bot",
                isRead: false
            ),
            unreadCount: 1,
            category: .announcement,
            priority: .normal
        )
    }
    
    private static func getLatestSprintReport() -> SprintReport {
        // В реальном приложении загружаем из файлов проекта
        // Сейчас возвращаем данные о последнем спринте
        return SprintReport(
            sprintNumber: 50,
            date: Date(),
            summary: "Sprint 50: Telegram-style Feed - Завершено 85%. Реализован новый дизайн ленты, интеграция с MainTabView, поддержка markdown."
        )
    }
    
    struct SprintReport {
        let sprintNumber: Int
        let date: Date
        let summary: String
    }
} 