import Foundation

struct SprintReport: Identifiable, Codable {
    let id: UUID
    let sprintNumber: String
    let date: Date
    let title: String
    let content: String
    let status: SprintStatus
    let achievements: [String]
    let challenges: [String]
    let nextSteps: [String]
    
    enum SprintStatus: String, Codable {
        case completed = "completed"
        case inProgress = "in_progress"
        case planned = "planned"
    }
    
    init(
        id: UUID = UUID(),
        sprintNumber: String,
        date: Date,
        title: String,
        content: String,
        status: SprintStatus = .completed,
        achievements: [String] = [],
        challenges: [String] = [],
        nextSteps: [String] = []
    ) {
        self.id = id
        self.sprintNumber = sprintNumber
        self.date = date
        self.title = title
        self.content = content
        self.status = status
        self.achievements = achievements
        self.challenges = challenges
        self.nextSteps = nextSteps
    }
    
    var formattedMessage: String {
        var message = "**Sprint \(sprintNumber)**\n"
        message += "\(title)\n\n"
        
        if !achievements.isEmpty {
            message += "✅ Достижения:\n"
            achievements.forEach { message += "• \($0)\n" }
            message += "\n"
        }
        
        if !challenges.isEmpty {
            message += "⚠️ Проблемы:\n"
            challenges.forEach { message += "• \($0)\n" }
            message += "\n"
        }
        
        if !nextSteps.isEmpty {
            message += "➡️ Следующие шаги:\n"
            nextSteps.forEach { message += "• \($0)\n" }
        }
        
        return message
    }
} 