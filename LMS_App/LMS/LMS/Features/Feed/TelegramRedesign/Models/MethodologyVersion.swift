import Foundation

struct MethodologyVersion: Identifiable, Codable {
    let id: UUID
    let version: String
    let date: Date
    let title: String
    let changes: [String]
    let breakingChanges: [String]
    let improvements: [String]
    
    init(
        id: UUID = UUID(),
        version: String,
        date: Date,
        title: String,
        changes: [String] = [],
        breakingChanges: [String] = [],
        improvements: [String] = []
    ) {
        self.id = id
        self.version = version
        self.date = date
        self.title = title
        self.changes = changes
        self.breakingChanges = breakingChanges
        self.improvements = improvements
    }
    
    var formattedMessage: String {
        var message = "**Методология \(version)**\n"
        message += "\(title)\n\n"
        
        if !breakingChanges.isEmpty {
            message += "🚨 Критические изменения:\n"
            breakingChanges.forEach { message += "• \($0)\n" }
            message += "\n"
        }
        
        if !improvements.isEmpty {
            message += "✨ Улучшения:\n"
            improvements.forEach { message += "• \($0)\n" }
            message += "\n"
        }
        
        if !changes.isEmpty {
            message += "📝 Изменения:\n"
            changes.forEach { message += "• \($0)\n" }
        }
        
        return message
    }
} 