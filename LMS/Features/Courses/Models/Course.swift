//
//  Course.swift
//  LMS
//
//  Created on 19/01/2025.
//

import Foundation
import SwiftUI

enum CourseStatus: String, CaseIterable {
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
    
    var icon: String {
        switch self {
        case .draft: return "doc.text"
        case .published: return "checkmark.circle.fill"
        case .archived: return "archivebox"
        }
    }
}

enum CourseLevel: String, CaseIterable {
    case beginner = "Начальный"
    case intermediate = "Средний"
    case advanced = "Продвинутый"
    case expert = "Экспертный"
    
    var color: Color {
        switch self {
        case .beginner: return .green
        case .intermediate: return .blue
        case .advanced: return .orange
        case .expert: return .purple
        }
    }
    
    var icon: String {
        switch self {
        case .beginner: return "1.circle"
        case .intermediate: return "2.circle"
        case .advanced: return "3.circle"
        case .expert: return "star.circle"
        }
    }
}

enum CourseFormat: String, CaseIterable {
    case selfPaced = "Самостоятельное изучение"
    case instructor = "С инструктором"
    case blended = "Смешанный формат"
    case workshop = "Воркшоп"
    
    var icon: String {
        switch self {
        case .selfPaced: return "book"
        case .instructor: return "person.fill"
        case .blended: return "book.and.wrench"
        case .workshop: return "person.3.fill"
        }
    }
}

struct Course: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var shortDescription: String
    var status: CourseStatus
    var level: CourseLevel
    var format: CourseFormat
    
    // Content
    var lessons: [Lesson]
    var duration: Int // в минутах
    var estimatedWeeks: Int // недели для завершения
    
    // Requirements
    var prerequisites: [String] // ID других курсов
    var requiredCompetencies: [CompetencyRequirement]
    var targetCompetencies: [CompetencyRequirement] // Какие компетенции развивает
    
    // Metadata
    var category: String
    var tags: [String]
    var imageURL: String?
    var authorId: String
    var authorName: String
    var createdAt: Date
    var updatedAt: Date
    var publishedAt: Date?
    
    // Statistics
    var enrolledCount: Int
    var completedCount: Int
    var averageRating: Double
    var reviewsCount: Int
    
    // Settings
    var isRequired: Bool // Обязательный для определенных должностей
    var requiredForPositions: [String] // ID должностей
    var certificateEnabled: Bool
    var passingScore: Int // Проходной балл в процентах
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        shortDescription: String,
        status: CourseStatus = .draft,
        level: CourseLevel = .beginner,
        format: CourseFormat = .selfPaced,
        lessons: [Lesson] = [],
        duration: Int = 0,
        estimatedWeeks: Int = 1,
        prerequisites: [String] = [],
        requiredCompetencies: [CompetencyRequirement] = [],
        targetCompetencies: [CompetencyRequirement] = [],
        category: String = "",
        tags: [String] = [],
        imageURL: String? = nil,
        authorId: String,
        authorName: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        publishedAt: Date? = nil,
        enrolledCount: Int = 0,
        completedCount: Int = 0,
        averageRating: Double = 0.0,
        reviewsCount: Int = 0,
        isRequired: Bool = false,
        requiredForPositions: [String] = [],
        certificateEnabled: Bool = true,
        passingScore: Int = 80
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.shortDescription = shortDescription
        self.status = status
        self.level = level
        self.format = format
        self.lessons = lessons
        self.duration = duration
        self.estimatedWeeks = estimatedWeeks
        self.prerequisites = prerequisites
        self.requiredCompetencies = requiredCompetencies
        self.targetCompetencies = targetCompetencies
        self.category = category
        self.tags = tags
        self.imageURL = imageURL
        self.authorId = authorId
        self.authorName = authorName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.publishedAt = publishedAt
        self.enrolledCount = enrolledCount
        self.completedCount = completedCount
        self.averageRating = averageRating
        self.reviewsCount = reviewsCount
        self.isRequired = isRequired
        self.requiredForPositions = requiredForPositions
        self.certificateEnabled = certificateEnabled
        self.passingScore = passingScore
    }
    
    // Computed properties
    var completionRate: Double {
        guard enrolledCount > 0 else { return 0 }
        return Double(completedCount) / Double(enrolledCount) * 100
    }
    
    var totalLessons: Int {
        lessons.count
    }
    
    var formattedDuration: String {
        let hours = duration / 60
        let minutes = duration % 60
        if hours > 0 {
            return "\(hours)ч \(minutes)м"
        } else {
            return "\(minutes)м"
        }
    }
    
    var isActive: Bool {
        status == .published
    }
}

struct CompetencyRequirement: Identifiable, Codable {
    let id: UUID
    var competencyId: String
    var competencyName: String
    var requiredLevel: Int // 1-5
    var isCritical: Bool
    
    init(
        id: UUID = UUID(),
        competencyId: String,
        competencyName: String,
        requiredLevel: Int,
        isCritical: Bool = false
    ) {
        self.id = id
        self.competencyId = competencyId
        self.competencyName = competencyName
        self.requiredLevel = requiredLevel
        self.isCritical = isCritical
    }
} 