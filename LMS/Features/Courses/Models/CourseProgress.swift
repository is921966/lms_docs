//
//  CourseProgress.swift
//  LMS
//
//  Created on 19/01/2025.
//

import Foundation
import SwiftUI

enum EnrollmentStatus: String, CaseIterable {
    case enrolled = "Записан"
    case inProgress = "В процессе"
    case completed = "Завершен"
    case failed = "Не сдан"
    case abandoned = "Прерван"
    
    var color: Color {
        switch self {
        case .enrolled: return .blue
        case .inProgress: return .orange
        case .completed: return .green
        case .failed: return .red
        case .abandoned: return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .enrolled: return "person.badge.plus"
        case .inProgress: return "timer"
        case .completed: return "checkmark.seal.fill"
        case .failed: return "xmark.seal.fill"
        case .abandoned: return "stop.circle"
        }
    }
}

struct CourseProgress: Identifiable, Codable {
    let id: UUID
    let userId: String
    let courseId: String
    var status: EnrollmentStatus
    var enrolledAt: Date
    var startedAt: Date?
    var completedAt: Date?
    var lastAccessedAt: Date
    
    // Progress details
    var completedLessons: [LessonProgress]
    var currentLessonId: String?
    var overallProgress: Double // 0.0 - 1.0
    var score: Double? // Итоговый балл
    
    // Time tracking
    var totalTimeSpent: Int // в минутах
    var estimatedTimeToComplete: Int? // в минутах
    
    // Certificate
    var certificateIssuedAt: Date?
    var certificateId: String?
    
    init(
        id: UUID = UUID(),
        userId: String,
        courseId: String,
        status: EnrollmentStatus = .enrolled,
        enrolledAt: Date = Date(),
        startedAt: Date? = nil,
        completedAt: Date? = nil,
        lastAccessedAt: Date = Date(),
        completedLessons: [LessonProgress] = [],
        currentLessonId: String? = nil,
        overallProgress: Double = 0.0,
        score: Double? = nil,
        totalTimeSpent: Int = 0,
        estimatedTimeToComplete: Int? = nil,
        certificateIssuedAt: Date? = nil,
        certificateId: String? = nil
    ) {
        self.id = id
        self.userId = userId
        self.courseId = courseId
        self.status = status
        self.enrolledAt = enrolledAt
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.lastAccessedAt = lastAccessedAt
        self.completedLessons = completedLessons
        self.currentLessonId = currentLessonId
        self.overallProgress = overallProgress
        self.score = score
        self.totalTimeSpent = totalTimeSpent
        self.estimatedTimeToComplete = estimatedTimeToComplete
        self.certificateIssuedAt = certificateIssuedAt
        self.certificateId = certificateId
    }
    
    var progressPercentage: Int {
        Int(overallProgress * 100)
    }
    
    var formattedTimeSpent: String {
        let hours = totalTimeSpent / 60
        let minutes = totalTimeSpent % 60
        if hours > 0 {
            return "\(hours)ч \(minutes)м"
        } else {
            return "\(minutes)м"
        }
    }
    
    var isActive: Bool {
        status == .enrolled || status == .inProgress
    }
    
    var hasCertificate: Bool {
        certificateId != nil
    }
}

struct LessonProgress: Identifiable, Codable {
    let id: UUID
    let lessonId: String
    var isCompleted: Bool
    var completedAt: Date?
    var timeSpent: Int // в минутах
    var score: Double? // Для уроков с тестами
    var attempts: Int
    var lastAttemptAt: Date?
    
    // Material progress
    var viewedMaterials: Set<String> // ID просмотренных материалов
    var downloadedMaterials: Set<String> // ID скачанных материалов
    
    init(
        id: UUID = UUID(),
        lessonId: String,
        isCompleted: Bool = false,
        completedAt: Date? = nil,
        timeSpent: Int = 0,
        score: Double? = nil,
        attempts: Int = 0,
        lastAttemptAt: Date? = nil,
        viewedMaterials: Set<String> = [],
        downloadedMaterials: Set<String> = []
    ) {
        self.id = id
        self.lessonId = lessonId
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.timeSpent = timeSpent
        self.score = score
        self.attempts = attempts
        self.lastAttemptAt = lastAttemptAt
        self.viewedMaterials = viewedMaterials
        self.downloadedMaterials = downloadedMaterials
    }
    
    var progressPercentage: Double {
        isCompleted ? 100.0 : 0.0
    }
} 