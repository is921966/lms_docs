import Foundation

struct ReleaseNote: Identifiable, Codable {
    let id: UUID
    let version: String?
    let buildNumber: Int?
    let date: Date
    let title: String
    let content: String
    let features: [String]
    let fixes: [String]
    let improvements: [String]
    
    init(
        id: UUID = UUID(),
        version: String? = nil,
        buildNumber: Int? = nil,
        date: Date,
        title: String,
        content: String,
        features: [String] = [],
        fixes: [String] = [],
        improvements: [String] = []
    ) {
        self.id = id
        self.version = version
        self.buildNumber = buildNumber
        self.date = date
        self.title = title
        self.content = content
        self.features = features
        self.fixes = fixes
        self.improvements = improvements
    }
    
    // Helper to format release notes as markdown
    var formattedContent: String {
        var result = content
        
        if !features.isEmpty {
            result += "\n\n### 🚀 Новые функции\n"
            result += features.map { "- \($0)" }.joined(separator: "\n")
        }
        
        if !fixes.isEmpty {
            result += "\n\n### 🐛 Исправления\n"
            result += fixes.map { "- \($0)" }.joined(separator: "\n")
        }
        
        if !improvements.isEmpty {
            result += "\n\n### 💡 Улучшения\n"
            result += improvements.map { "- \($0)" }.joined(separator: "\n")
        }
        
        return result
    }
} 