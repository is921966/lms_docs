import Foundation

// MARK: - Module

struct Module: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let lessons: [Lesson]
    let duration: Int // в минутах
    let order: Int
    
    init(id: String = UUID().uuidString, 
         title: String, 
         description: String, 
         lessons: [Lesson] = [], 
         duration: Int = 0,
         order: Int = 0) {
        self.id = id
        self.title = title
        self.description = description
        self.lessons = lessons
        self.duration = duration
        self.order = order
    }
}

// MARK: - Lesson

struct Lesson: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let type: LessonType
    let duration: Int // в минутах
    let content: LessonContent
    let order: Int
    
    init(id: String = UUID().uuidString,
         title: String,
         description: String,
         type: LessonType,
         duration: Int = 0,
         content: LessonContent,
         order: Int = 0) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
        self.duration = duration
        self.content = content
        self.order = order
    }
}

// MARK: - LessonType

enum LessonType: String, Codable, CaseIterable {
    case video = "video"
    case text = "text"
    case quiz = "quiz"
    case interactive = "interactive"
    case pdf = "pdf"
    case assignment = "assignment"
    case cmi5 = "cmi5"
    
    var icon: String {
        switch self {
        case .video: return "play.circle.fill"
        case .text: return "doc.text.fill"
        case .quiz: return "questionmark.circle.fill"
        case .interactive: return "hand.tap.fill"
        case .pdf: return "doc.fill"
        case .assignment: return "doc.badge.plus"
        case .cmi5: return "desktopcomputer"
        }
    }
    
    var displayName: String {
        switch self {
        case .video: return "Видео"
        case .text: return "Текст"
        case .quiz: return "Тест"
        case .interactive: return "Интерактив"
        case .pdf: return "PDF"
        case .assignment: return "Задание"
        case .cmi5: return "CMI5 курс"
        }
    }
}

// MARK: - LessonContent

enum LessonContent: Codable {
    case video(url: String, subtitlesUrl: String?)
    case text(html: String)
    case quiz(questions: [QuizQuestion])
    case interactive(url: String)
    case pdf(url: String)
    case assignment(description: String, dueDate: Date?)
    case cmi5(packageUrl: String, launchUrl: String)
    
    enum CodingKeys: String, CodingKey {
        case type
        case url
        case html
        case subtitlesUrl
        case questions
        case description
        case dueDate
        case packageUrl
        case launchUrl
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "video":
            let url = try container.decode(String.self, forKey: .url)
            let subtitlesUrl = try container.decodeIfPresent(String.self, forKey: .subtitlesUrl)
            self = .video(url: url, subtitlesUrl: subtitlesUrl)
        case "text":
            let html = try container.decode(String.self, forKey: .html)
            self = .text(html: html)
        case "quiz":
            let questions = try container.decode([QuizQuestion].self, forKey: .questions)
            self = .quiz(questions: questions)
        case "interactive":
            let url = try container.decode(String.self, forKey: .url)
            self = .interactive(url: url)
        case "pdf":
            let url = try container.decode(String.self, forKey: .url)
            self = .pdf(url: url)
        case "assignment":
            let description = try container.decode(String.self, forKey: .description)
            let dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
            self = .assignment(description: description, dueDate: dueDate)
        case "cmi5":
            let packageUrl = try container.decode(String.self, forKey: .packageUrl)
            let launchUrl = try container.decode(String.self, forKey: .launchUrl)
            self = .cmi5(packageUrl: packageUrl, launchUrl: launchUrl)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown lesson type")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .video(let url, let subtitlesUrl):
            try container.encode("video", forKey: .type)
            try container.encode(url, forKey: .url)
            try container.encodeIfPresent(subtitlesUrl, forKey: .subtitlesUrl)
        case .text(let html):
            try container.encode("text", forKey: .type)
            try container.encode(html, forKey: .html)
        case .quiz(let questions):
            try container.encode("quiz", forKey: .type)
            try container.encode(questions, forKey: .questions)
        case .interactive(let url):
            try container.encode("interactive", forKey: .type)
            try container.encode(url, forKey: .url)
        case .pdf(let url):
            try container.encode("pdf", forKey: .type)
            try container.encode(url, forKey: .url)
        case .assignment(let description, let dueDate):
            try container.encode("assignment", forKey: .type)
            try container.encode(description, forKey: .description)
            try container.encodeIfPresent(dueDate, forKey: .dueDate)
        case .cmi5(let packageUrl, let launchUrl):
            try container.encode("cmi5", forKey: .type)
            try container.encode(packageUrl, forKey: .packageUrl)
            try container.encode(launchUrl, forKey: .launchUrl)
        }
    }
}

// MARK: - CourseAssignment

struct CourseAssignment: Identifiable {
    let id: String
    let courseId: String
    let courseName: String
    let assignedDate: Date
    let dueDate: Date?
    let completionStatus: CompletionStatus
    
    enum CompletionStatus: String {
        case notStarted = "not_started"
        case inProgress = "in_progress"
        case completed = "completed"
        
        var displayName: String {
            switch self {
            case .notStarted: return "Не начат"
            case .inProgress: return "В процессе"
            case .completed: return "Завершен"
            }
        }
    }
} 