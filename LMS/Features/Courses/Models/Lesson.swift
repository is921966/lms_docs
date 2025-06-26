//
//  Lesson.swift
//  LMS
//
//  Created on 19/01/2025.
//

import Foundation
import SwiftUI

enum LessonType: String, CaseIterable {
    case video = "Видео"
    case text = "Текст"
    case presentation = "Презентация"
    case interactive = "Интерактив"
    case quiz = "Тест"
    case assignment = "Задание"
    
    var icon: String {
        switch self {
        case .video: return "play.rectangle"
        case .text: return "doc.text"
        case .presentation: return "tv"
        case .interactive: return "hand.tap"
        case .quiz: return "questionmark.circle"
        case .assignment: return "pencil.and.outline"
        }
    }
    
    var color: Color {
        switch self {
        case .video: return .red
        case .text: return .blue
        case .presentation: return .orange
        case .interactive: return .purple
        case .quiz: return .green
        case .assignment: return .indigo
        }
    }
}

struct Lesson: Identifiable, Codable {
    let id: UUID
    var courseId: String
    var title: String
    var description: String
    var type: LessonType
    var orderIndex: Int
    
    // Content
    var materials: [LearningMaterial]
    var duration: Int // в минутах
    var content: String // Markdown или HTML контент для текстовых уроков
    
    // Progress tracking
    var isRequired: Bool
    var hasQuiz: Bool
    var quizId: String?
    var passingScore: Int? // Для уроков с тестами
    
    // Metadata
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        courseId: String,
        title: String,
        description: String,
        type: LessonType,
        orderIndex: Int,
        materials: [LearningMaterial] = [],
        duration: Int = 0,
        content: String = "",
        isRequired: Bool = true,
        hasQuiz: Bool = false,
        quizId: String? = nil,
        passingScore: Int? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.courseId = courseId
        self.title = title
        self.description = description
        self.type = type
        self.orderIndex = orderIndex
        self.materials = materials
        self.duration = duration
        self.content = content
        self.isRequired = isRequired
        self.hasQuiz = hasQuiz
        self.quizId = quizId
        self.passingScore = passingScore
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    var formattedDuration: String {
        "\(duration) мин"
    }
}

enum MaterialType: String, CaseIterable {
    case pdf = "PDF"
    case video = "Видео"
    case audio = "Аудио"
    case document = "Документ"
    case link = "Ссылка"
    case code = "Код"
    case archive = "Архив"
    
    var icon: String {
        switch self {
        case .pdf: return "doc.richtext"
        case .video: return "video"
        case .audio: return "speaker.wave.2"
        case .document: return "doc"
        case .link: return "link"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .archive: return "archivebox"
        }
    }
    
    var color: Color {
        switch self {
        case .pdf: return .red
        case .video: return .purple
        case .audio: return .green
        case .document: return .blue
        case .link: return .indigo
        case .code: return .orange
        case .archive: return .gray
        }
    }
}

struct LearningMaterial: Identifiable, Codable {
    let id: UUID
    var lessonId: String
    var title: String
    var description: String
    var type: MaterialType
    var url: String // URL или путь к файлу
    var fileSize: Int64? // в байтах
    var duration: Int? // для видео/аудио в секундах
    var orderIndex: Int
    var isRequired: Bool
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        lessonId: String,
        title: String,
        description: String = "",
        type: MaterialType,
        url: String,
        fileSize: Int64? = nil,
        duration: Int? = nil,
        orderIndex: Int = 0,
        isRequired: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.lessonId = lessonId
        self.title = title
        self.description = description
        self.type = type
        self.url = url
        self.fileSize = fileSize
        self.duration = duration
        self.orderIndex = orderIndex
        self.isRequired = isRequired
        self.createdAt = createdAt
    }
    
    var formattedFileSize: String? {
        guard let size = fileSize else { return nil }
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    var formattedDuration: String? {
        guard let seconds = duration else { return nil }
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
} 