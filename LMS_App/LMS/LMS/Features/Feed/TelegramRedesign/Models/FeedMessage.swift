import Foundation

struct FeedMessage: Identifiable, Equatable {
    let id: UUID
    let text: String
    let timestamp: Date
    let author: String
    var isRead: Bool
    
    static var mock: FeedMessage {
        FeedMessage(
            id: UUID(),
            text: "Новое сообщение в канале",
            timestamp: Date(),
            author: "System",
            isRead: false
        )
    }
} 