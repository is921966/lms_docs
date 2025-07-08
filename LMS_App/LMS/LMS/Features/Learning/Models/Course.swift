//
//  Course.swift
//  LMS
//
//  Created on 26/01/2025.
//

import Foundation
import SwiftUI

// MARK: - Course Status
enum CourseStatus: String, CaseIterable, Codable {
    case draft = "Черновик"
    case published = "Опубликован"
    case archived = "В архиве"

    var color: Color {
        switch self {
        case .draft: return .gray
        case .published: return .green
        case .archived: return .orange
        }
    }
}

// MARK: - Course Type
enum CourseType: String, CaseIterable, Codable {
    case mandatory = "Обязательный"
    case optional = "Дополнительный"
    case onboarding = "Онбординг"

    var icon: String {
        switch self {
        case .mandatory: return "exclamationmark.circle.fill"
        case .optional: return "questionmark.circle"
        case .onboarding: return "person.badge.plus"
        }
    }
}

// MARK: - Course Category
struct CourseCategory: Identifiable, Codable {
    let id = UUID()
    let name: String
    let colorName: String
    let icon: String

    var color: Color {
        switch colorName {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "red": return .red
        case "yellow": return .yellow
        default: return .gray
        }
    }

    static let categories = [
        CourseCategory(name: "Продажи", colorName: "blue", icon: "cart.fill"),
        CourseCategory(name: "Товароведение", colorName: "green", icon: "shippingbox.fill"),
        CourseCategory(name: "Сервис", colorName: "orange", icon: "person.2.fill"),
        CourseCategory(name: "Управление", colorName: "purple", icon: "person.3.fill"),
        CourseCategory(name: "IT", colorName: "red", icon: "desktopcomputer"),
        CourseCategory(name: "Soft Skills", colorName: "yellow", icon: "bubble.left.and.bubble.right.fill")
    ]
}

// MARK: - Course Material
struct CourseMaterial: Identifiable, Codable {
    let id = UUID()
    let title: String
    let type: MaterialType
    let url: String?
    let fileSize: Int64? // in bytes
    let duration: Int? // in minutes for video
    let uploadedAt: Date

    enum MaterialType: String, CaseIterable, Codable {
        case video = "Видео"
        case presentation = "Презентация"
        case document = "Документ"
        case link = "Ссылка"
        case archive = "Архив"

        var icon: String {
            switch self {
            case .video: return "play.circle.fill"
            case .presentation: return "doc.richtext"
            case .document: return "doc.text.fill"
            case .link: return "link"
            case .archive: return "archivebox.fill"
            }
        }

        var acceptedExtensions: [String] {
            switch self {
            case .video: return ["mp4", "mov", "avi"]
            case .presentation: return ["ppt", "pptx", "pdf"]
            case .document: return ["doc", "docx", "pdf", "txt"]
            case .link: return []
            case .archive: return ["zip", "rar", "7z"]
            }
        }
    }
}

// MARK: - Course Assignment
struct CourseAssignment: Identifiable, Codable {
    let id = UUID()
    let courseId: UUID
    let userId: UUID
    let assignedBy: UUID
    let assignedAt: Date
    let dueDate: Date?
    let completedAt: Date?
    let isMandatory: Bool

    var isOverdue: Bool {
        guard let due = dueDate, completedAt == nil else { return false }
        return Date() > due
    }

    var daysUntilDue: Int? {
        guard let due = dueDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: due).day
    }
}

// MARK: - Course Model
struct Course: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String
    var categoryId: UUID?
    var status: CourseStatus = .draft
    var type: CourseType = .optional

    // Content
    var modules: [Module] = []
    var materials: [CourseMaterial] = []
    var testId: UUID?

    // Requirements
    var competencyIds: [UUID] = []
    var positionIds: [UUID] = []
    var prerequisiteCourseIds: [UUID] = []

    // Settings
    var duration: String // e.g., "8 часов"
    var estimatedHours: Int = 0
    var passingScore: Int = 80
    var certificateTemplateId: UUID?
    var maxAttempts: Int?

    // Tracking
    var createdBy: UUID
    var createdAt = Date()
    var updatedAt = Date()
    var publishedAt: Date?

    // Calculated properties
    var totalLessons: Int {
        modules.reduce(0) { $0 + $1.lessons.count }
    }

    var totalDuration: Int {
        modules.reduce(0) { $0 + $1.lessons.reduce(0) { $0 + $1.duration } }
    }

    var isPublished: Bool {
        status == .published
    }

    var canBeTaken: Bool {
        isPublished && !modules.isEmpty
    }

    // UI properties (remove when real data available)
    var color: Color {
        CourseCategory.categories.first { $0.id == categoryId }?.color ?? .blue
    }

    var icon: String {
        CourseCategory.categories.first { $0.id == categoryId }?.icon ?? "book.fill"
    }

    var progress: Double {
        // This would be calculated based on user progress
        Double.random(in: 0...1)
    }
}

// MARK: - Module Model
struct Module: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String?
    var orderIndex: Int
    var lessons: [Lesson] = []
    var materials: [CourseMaterial] = []

    var duration: Int {
        lessons.reduce(0) { $0 + $1.duration }
    }

    var isCompleted: Bool {
        // This would be based on user progress
        false
    }

    var isLocked: Bool {
        // This would be based on prerequisites
        false
    }

    var progress: Double {
        // This would be calculated based on lesson completion
        0.0
    }
}

// MARK: - Lesson Model
struct Lesson: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String?
    var type: LessonType
    var orderIndex: Int
    var duration: Int // in minutes
    var content: LessonContent
    var materials: [CourseMaterial] = []

    enum LessonType: String, CaseIterable, Codable {
        case video = "Видео"
        case text = "Текст"
        case interactive = "Интерактив"
        case quiz = "Тест"
        case assignment = "Задание"
        case cmi5 = "Cmi5"

        var icon: String {
            switch self {
            case .video: return "play.circle.fill"
            case .text: return "doc.text.fill"
            case .interactive: return "hand.tap.fill"
            case .quiz: return "checkmark.circle.fill"
            case .assignment: return "pencil.circle.fill"
            case .cmi5: return "cube.box.fill"
            }
        }
    }

    enum LessonContent: Codable {
        case video(url: String, subtitlesUrl: String?)
        case text(html: String)
        case interactive(url: String)
        case quiz(questions: [CourseQuizQuestion])
        case assignment(instructions: String, dueDate: Date?)
        case cmi5(activityId: String, packageId: String)
    }

    var isCompleted: Bool {
        // This would be based on user progress
        false
    }
}

// MARK: - Quiz Question
struct CourseQuizQuestion: Identifiable, Codable {
    let id = UUID()
    var text: String
    var options: [String]
    var correctAnswerIndex: Int
    var explanation: String?
}

// MARK: - Mock Data Extension
extension Course {
    static var mockCourses: [Course] = []

    static func createMockCourses() -> [Course] {
        let salesCategory = CourseCategory.categories[0]
        let serviceCategory = CourseCategory.categories[2]

        return [
            Course(
                title: "Основы продаж в ЦУМ",
                description: "Базовый курс по техникам продаж",
                categoryId: salesCategory.id,
                status: .published,
                type: .mandatory,
                modules: createSalesModules(),
                duration: "8 часов",
                estimatedHours: 8,
                createdBy: UUID(),
                publishedAt: Date()
            ),
            Course(
                title: "Клиентский сервис VIP",
                description: "Работа с премиальными клиентами",
                categoryId: serviceCategory.id,
                status: .published,
                type: .optional,
                modules: createVIPModules(),
                duration: "12 часов",
                estimatedHours: 12,
                createdBy: UUID(),
                publishedAt: Date()
            ),
            Course(
                title: "Товароведение",
                description: "Знание ассортимента и характеристик товаров",
                categoryId: salesCategory.id,
                status: .draft,
                type: .mandatory,
                duration: "16 часов",
                estimatedHours: 16,
                createdBy: UUID()
            )
        ]
    }

    private static func createSalesModules() -> [Module] {
        [
            Module(
                title: "Введение в продажи",
                description: "Основные принципы и подходы",
                orderIndex: 1,
                lessons: [
                    Lesson(
                        title: "Что такое продажи?",
                        type: .video,
                        orderIndex: 1,
                        duration: 15,
                        content: .video(url: "https://example.com/video1.mp4", subtitlesUrl: nil)
                    ),
                    Lesson(
                        title: "Этапы продажи",
                        type: .text,
                        orderIndex: 2,
                        duration: 10,
                        content: .text(html: "<h1>Этапы продажи</h1><p>Контент урока...</p>")
                    )
                ]
            ),
            Module(
                title: "Работа с клиентом",
                description: "Выявление потребностей и презентация",
                orderIndex: 2,
                lessons: [
                    Lesson(
                        title: "Типы клиентов",
                        type: .interactive,
                        orderIndex: 1,
                        duration: 20,
                        content: .interactive(url: "https://example.com/interactive1")
                    ),
                    Lesson(
                        title: "Проверка знаний",
                        type: .quiz,
                        orderIndex: 2,
                        duration: 15,
                        content: .quiz(questions: [
                            CourseQuizQuestion(
                                text: "Какой первый этап продажи?",
                                options: ["Презентация", "Приветствие", "Закрытие сделки", "Выявление потребностей"],
                                correctAnswerIndex: 1,
                                explanation: "Продажа всегда начинается с приветствия клиента"
                            )
                        ])
                    )
                ]
            )
        ]
    }

    private static func createVIPModules() -> [Module] {
        [
            Module(
                title: "Психология VIP-клиента",
                orderIndex: 1,
                lessons: []
            ),
            Module(
                title: "Персональный подход",
                orderIndex: 2,
                lessons: []
            )
        ]
    }
}
