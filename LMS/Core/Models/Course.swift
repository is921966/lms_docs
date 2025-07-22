import Foundation

struct Course: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let imageURL: String?
    let duration: Int // in minutes
    let level: CourseLevel
    let category: CourseCategory
    let instructor: Instructor
    let modules: [Module]
    let competencies: [String]
    let rating: Double
    let studentsCount: Int
    let price: Double
    let isEnrolled: Bool
    let progress: Double // 0.0 to 1.0
    let createdAt: Date
    let updatedAt: Date
    
    enum CourseLevel: String, Codable, CaseIterable {
        case beginner = "beginner"
        case intermediate = "intermediate"
        case advanced = "advanced"
        
        var displayName: String {
            switch self {
            case .beginner: return "Начальный"
            case .intermediate: return "Средний"
            case .advanced: return "Продвинутый"
            }
        }
    }
    
    enum CourseCategory: String, Codable, CaseIterable {
        case management = "management"
        case sales = "sales"
        case marketing = "marketing"
        case it = "it"
        case hr = "hr"
        case finance = "finance"
        case other = "other"
        
        var displayName: String {
            switch self {
            case .management: return "Управление"
            case .sales: return "Продажи"
            case .marketing: return "Маркетинг"
            case .it: return "IT"
            case .hr: return "HR"
            case .finance: return "Финансы"
            case .other: return "Другое"
            }
        }
    }
}

struct Module: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let orderIndex: Int
    let lessons: [Lesson]
    let duration: Int // in minutes
    let isCompleted: Bool
}

struct Lesson: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let videoURL: String?
    let content: String?
    let materials: [LessonMaterial]
    let duration: Int // in minutes
    let orderIndex: Int
    let isCompleted: Bool
}

struct LessonMaterial: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let type: MaterialType
    let url: String
    let size: Int64? // in bytes
    
    enum MaterialType: String, Codable {
        case pdf
        case video
        case audio
        case document
        case link
    }
}

struct Instructor: Codable, Hashable {
    let id: String
    let name: String
    let title: String
    let bio: String?
    let avatarURL: String?
} 