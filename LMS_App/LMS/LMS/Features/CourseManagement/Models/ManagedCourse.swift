import Foundation
import SwiftUI

struct ManagedCourse: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var description: String
    var duration: Int // в часах
    var status: ManagedCourseStatus
    var competencies: [UUID]
    var modules: [ManagedCourseModule]
    var createdAt: Date
    var updatedAt: Date
    var cmi5PackageId: UUID? // Связь с Cmi5 пакетом
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        duration: Int,
        status: ManagedCourseStatus = .draft,
        competencies: [UUID] = [],
        modules: [ManagedCourseModule] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        cmi5PackageId: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.duration = duration
        self.status = status
        self.competencies = competencies
        self.modules = modules
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.cmi5PackageId = cmi5PackageId
    }
}

enum ManagedCourseStatus: String, Codable, CaseIterable {
    case draft = "draft"
    case published = "published"
    case archived = "archived"
    
    var displayName: String {
        switch self {
        case .draft: return "Черновик"
        case .published: return "Опубликован"
        case .archived: return "В архиве"
        }
    }
    
    var color: Color {
        switch self {
        case .draft: return .orange
        case .published: return .green
        case .archived: return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .draft: return "pencil.circle"
        case .published: return "checkmark.circle"  
        case .archived: return "archivebox"
        }
    }
}

struct ManagedCourseModule: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var description: String
    var order: Int
    var contentType: ContentType
    var contentUrl: String?
    var duration: Int // в минутах
    
    enum ContentType: String, Codable {
        case video = "video"
        case document = "document"
        case quiz = "quiz"
        case cmi5 = "cmi5"
    }
} 