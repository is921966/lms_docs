//
//  CourseMockService.swift
//  LMS
//
//  Created on 19/01/2025.
//

import Foundation
import Combine

class CourseMockService: ObservableObject {
    @Published var courses: [Course] = []
    @Published var userProgress: [CourseProgress] = []
    
    private let currentUserId = "user123"
    
    init() {
        loadMockData()
    }
    
    private func loadMockData() {
        // Создаем курсы
        let swiftCourse = createSwiftCourse()
        let uiDesignCourse = createUIDesignCourse()
        let projectManagementCourse = createProjectManagementCourse()
        let dataAnalysisCourse = createDataAnalysisCourse()
        
        courses = [swiftCourse, uiDesignCourse, projectManagementCourse, dataAnalysisCourse]
        
        // Создаем прогресс для текущего пользователя
        userProgress = [
            CourseProgress(
                userId: currentUserId,
                courseId: swiftCourse.id.uuidString,
                status: .inProgress,
                startedAt: Date().addingTimeInterval(-7*24*60*60), // неделю назад
                overallProgress: 0.6,
                totalTimeSpent: 240
            ),
            CourseProgress(
                userId: currentUserId,
                courseId: uiDesignCourse.id.uuidString,
                status: .completed,
                startedAt: Date().addingTimeInterval(-30*24*60*60),
                completedAt: Date().addingTimeInterval(-5*24*60*60),
                overallProgress: 1.0,
                score: 92.5,
                totalTimeSpent: 480,
                certificateIssuedAt: Date().addingTimeInterval(-5*24*60*60),
                certificateId: "CERT-2025-001"
            )
        ]
    }
    
    private func createSwiftCourse() -> Course {
        let courseId = UUID()
        let lessons = [
            Lesson(
                courseId: courseId.uuidString,
                title: "Введение в Swift",
                description: "Основы языка программирования Swift",
                type: .video,
                orderIndex: 1,
                materials: [
                    LearningMaterial(
                        lessonId: "lesson1",
                        title: "Видео: Основы Swift",
                        type: .video,
                        url: "https://example.com/swift-basics.mp4",
                        duration: 1800
                    ),
                    LearningMaterial(
                        lessonId: "lesson1",
                        title: "Презентация: Swift Overview",
                        type: .pdf,
                        url: "https://example.com/swift-overview.pdf",
                        fileSize: 2048000
                    )
                ],
                duration: 45
            ),
            Lesson(
                courseId: courseId.uuidString,
                title: "Переменные и константы",
                description: "Работа с переменными, константами и типами данных",
                type: .interactive,
                orderIndex: 2,
                duration: 30,
                hasQuiz: true
            ),
            Lesson(
                courseId: courseId.uuidString,
                title: "Функции и замыкания",
                description: "Создание и использование функций",
                type: .text,
                orderIndex: 3,
                duration: 40,
                content: "# Функции в Swift\n\nФункции - это самодостаточные блоки кода..."
            ),
            Lesson(
                courseId: courseId.uuidString,
                title: "Практическое задание",
                description: "Создайте свое первое iOS приложение",
                type: .assignment,
                orderIndex: 4,
                duration: 120
            )
        ]
        
        return Course(
            id: courseId,
            title: "iOS разработка с Swift",
            description: "Полный курс по разработке iOS приложений с использованием Swift и SwiftUI. Научитесь создавать современные мобильные приложения с нуля.",
            shortDescription: "Научитесь создавать iOS приложения",
            status: .published,
            level: .intermediate,
            format: .blended,
            lessons: lessons,
            duration: 235,
            estimatedWeeks: 4,
            targetCompetencies: [
                CompetencyRequirement(
                    competencyId: "comp1",
                    competencyName: "iOS Development",
                    requiredLevel: 4,
                    isCritical: true
                ),
                CompetencyRequirement(
                    competencyId: "comp2",
                    competencyName: "Swift Programming",
                    requiredLevel: 4,
                    isCritical: true
                )
            ],
            category: "Разработка",
            tags: ["iOS", "Swift", "SwiftUI", "Mobile"],
            authorId: "author1",
            authorName: "Иван Петров",
            publishedAt: Date().addingTimeInterval(-60*24*60*60),
            enrolledCount: 342,
            completedCount: 128,
            averageRating: 4.7,
            reviewsCount: 89
        )
    }
    
    private func createUIDesignCourse() -> Course {
        let courseId = UUID()
        let lessons = [
            Lesson(
                courseId: courseId.uuidString,
                title: "Основы UI/UX дизайна",
                description: "Принципы хорошего дизайна интерфейсов",
                type: .video,
                orderIndex: 1,
                duration: 60
            ),
            Lesson(
                courseId: courseId.uuidString,
                title: "Работа в Figma",
                description: "Основные инструменты и техники",
                type: .interactive,
                orderIndex: 2,
                duration: 90
            ),
            Lesson(
                courseId: courseId.uuidString,
                title: "Дизайн-системы",
                description: "Создание и поддержка дизайн-систем",
                type: .presentation,
                orderIndex: 3,
                duration: 45
            )
        ]
        
        return Course(
            id: courseId,
            title: "UI/UX дизайн для разработчиков",
            description: "Научитесь создавать красивые и удобные интерфейсы. Курс специально адаптирован для разработчиков.",
            shortDescription: "Дизайн интерфейсов для разработчиков",
            status: .published,
            level: .beginner,
            format: .selfPaced,
            lessons: lessons,
            duration: 195,
            estimatedWeeks: 3,
            requiredCompetencies: [
                CompetencyRequirement(
                    competencyId: "comp3",
                    competencyName: "Basic Programming",
                    requiredLevel: 2
                )
            ],
            targetCompetencies: [
                CompetencyRequirement(
                    competencyId: "comp4",
                    competencyName: "UI/UX Design",
                    requiredLevel: 3
                )
            ],
            category: "Дизайн",
            tags: ["UI", "UX", "Figma", "Design"],
            authorId: "author2",
            authorName: "Мария Соколова",
            publishedAt: Date().addingTimeInterval(-30*24*60*60),
            enrolledCount: 567,
            completedCount: 234,
            averageRating: 4.8,
            reviewsCount: 156,
            certificateEnabled: true,
            passingScore: 80
        )
    }
    
    private func createProjectManagementCourse() -> Course {
        Course(
            title: "Agile и Scrum для команд",
            description: "Освойте современные методологии управления проектами. Научитесь эффективно организовывать работу команды.",
            shortDescription: "Современные методологии управления проектами",
            status: .published,
            level: .intermediate,
            format: .workshop,
            duration: 480,
            estimatedWeeks: 6,
            targetCompetencies: [
                CompetencyRequirement(
                    competencyId: "comp5",
                    competencyName: "Project Management",
                    requiredLevel: 4
                )
            ],
            category: "Менеджмент",
            tags: ["Agile", "Scrum", "Management", "Team"],
            authorId: "author3",
            authorName: "Алексей Волков",
            publishedAt: Date().addingTimeInterval(-45*24*60*60),
            enrolledCount: 234,
            completedCount: 89,
            averageRating: 4.5,
            reviewsCount: 67,
            isRequired: true,
            requiredForPositions: ["pos3", "pos7"] // Product Manager, Engineering Manager
        )
    }
    
    private func createDataAnalysisCourse() -> Course {
        Course(
            title: "Анализ данных с Python",
            description: "Научитесь анализировать данные с помощью Python, pandas и машинного обучения.",
            shortDescription: "Python для анализа данных",
            status: .draft,
            level: .advanced,
            format: .selfPaced,
            duration: 600,
            estimatedWeeks: 8,
            prerequisites: ["python-basics"],
            requiredCompetencies: [
                CompetencyRequirement(
                    competencyId: "comp6",
                    competencyName: "Python Programming",
                    requiredLevel: 3,
                    isCritical: true
                )
            ],
            targetCompetencies: [
                CompetencyRequirement(
                    competencyId: "comp7",
                    competencyName: "Data Analysis",
                    requiredLevel: 4
                )
            ],
            category: "Аналитика",
            tags: ["Python", "Data", "Analytics", "ML"],
            authorId: "author4",
            authorName: "Елена Николаева",
            enrolledCount: 0,
            completedCount: 0,
            averageRating: 0,
            reviewsCount: 0
        )
    }
    
    // MARK: - Course Management
    
    func enrollInCourse(_ courseId: String) {
        guard !isEnrolled(courseId) else { return }
        
        let progress = CourseProgress(
            userId: currentUserId,
            courseId: courseId,
            status: .enrolled
        )
        userProgress.append(progress)
    }
    
    func isEnrolled(_ courseId: String) -> Bool {
        userProgress.contains { $0.courseId == courseId && $0.userId == currentUserId }
    }
    
    func getProgress(for courseId: String) -> CourseProgress? {
        userProgress.first { $0.courseId == courseId && $0.userId == currentUserId }
    }
    
    func updateProgress(_ progress: CourseProgress) {
        if let index = userProgress.firstIndex(where: { $0.id == progress.id }) {
            userProgress[index] = progress
        }
    }
    
    func startLesson(_ lessonId: String, in courseId: String) {
        guard var progress = getProgress(for: courseId) else { return }
        
        if progress.startedAt == nil {
            progress.startedAt = Date()
            progress.status = .inProgress
        }
        
        progress.currentLessonId = lessonId
        progress.lastAccessedAt = Date()
        
        updateProgress(progress)
    }
    
    func completeLesson(_ lessonId: String, in courseId: String, score: Double? = nil) {
        guard var progress = getProgress(for: courseId),
              let course = courses.first(where: { $0.id.uuidString == courseId }) else { return }
        
        let lessonProgress = LessonProgress(
            lessonId: lessonId,
            isCompleted: true,
            completedAt: Date(),
            score: score,
            attempts: 1
        )
        
        progress.completedLessons.append(lessonProgress)
        
        // Обновляем общий прогресс
        let completedCount = progress.completedLessons.count
        let totalLessons = course.lessons.count
        progress.overallProgress = Double(completedCount) / Double(totalLessons)
        
        // Проверяем завершение курса
        if completedCount == totalLessons {
            progress.status = .completed
            progress.completedAt = Date()
            
            // Выдаем сертификат если курс пройден успешно
            if course.certificateEnabled {
                progress.certificateIssuedAt = Date()
                progress.certificateId = "CERT-\(Date().timeIntervalSince1970)"
            }
        }
        
        updateProgress(progress)
    }
} 