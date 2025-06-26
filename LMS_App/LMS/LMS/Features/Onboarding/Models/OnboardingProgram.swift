//
//  OnboardingProgram.swift
//  LMS
//
//  Created on 27/01/2025.
//

import Foundation
import SwiftUI

// MARK: - Onboarding Program
struct OnboardingProgram: Identifiable, Codable {
    let id = UUID()
    let templateId: UUID
    let employeeId: UUID
    let employeeName: String
    let employeePosition: String
    let employeeDepartment: String
    let managerId: UUID
    let managerName: String
    
    let title: String
    let description: String
    let startDate: Date
    let targetEndDate: Date
    var actualEndDate: Date?
    
    var stages: [OnboardingStage]
    let totalDuration: Int // in days
    
    var status: OnboardingStatus
    var overallProgress: Double {
        guard !stages.isEmpty else { return 0 }
        let totalProgress = stages.reduce(0) { $0 + $1.progress }
        return totalProgress / Double(stages.count)
    }
    
    var completedStages: Int {
        stages.filter { $0.status == .completed }.count
    }
    
    var currentStage: OnboardingStage? {
        stages.first { $0.status == .inProgress }
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: Date(), to: targetEndDate).day ?? 0
        return max(0, days)
    }
    
    var isOverdue: Bool {
        Date() > targetEndDate && status != .completed
    }
    
    var statusColor: Color {
        switch status {
        case .notStarted: return .gray
        case .inProgress: return .blue
        case .completed: return .green
        case .cancelled: return .red
        }
    }
}

// MARK: - Onboarding Status
enum OnboardingStatus: String, Codable, CaseIterable {
    case notStarted = "Не начат"
    case inProgress = "В процессе"
    case completed = "Завершен"
    case cancelled = "Отменен"
}

// MARK: - Onboarding Stage
struct OnboardingStage: Identifiable, Codable {
    let id = UUID()
    let orderIndex: Int
    let title: String
    let description: String
    let duration: Int // in days
    
    var tasks: [OnboardingTask]
    var status: OnboardingStatus
    var startDate: Date?
    var endDate: Date?
    
    var progress: Double {
        guard !tasks.isEmpty else { return 0 }
        let completedTasks = tasks.filter { $0.isCompleted }.count
        return Double(completedTasks) / Double(tasks.count)
    }
    
    var completedTasks: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    var icon: String {
        switch orderIndex {
        case 1: return "person.2.fill"
        case 2: return "book.fill"
        case 3: return "wrench.and.screwdriver.fill"
        case 4: return "star.fill"
        default: return "checkmark.circle.fill"
        }
    }
}

// MARK: - Onboarding Task
struct OnboardingTask: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let type: TaskType
    
    var isCompleted: Bool = false
    var completedAt: Date?
    var completedBy: UUID?
    
    // Links to other entities
    var courseId: UUID?
    var testId: UUID?
    var documentUrl: String?
    var meetingId: UUID?
    
    var dueDate: Date?
    var isRequired: Bool = true
    
    var icon: String {
        switch type {
        case .course: return "book.closed.fill"
        case .test: return "doc.text.fill"
        case .document: return "doc.fill"
        case .meeting: return "person.2.fill"
        case .task: return "checkmark.square.fill"
        case .feedback: return "bubble.left.and.bubble.right.fill"
        }
    }
    
    var iconColor: Color {
        switch type {
        case .course: return .blue
        case .test: return .purple
        case .document: return .orange
        case .meeting: return .green
        case .task: return .gray
        case .feedback: return .pink
        }
    }
}

// MARK: - Task Type
enum TaskType: String, Codable, CaseIterable {
    case course = "Курс"
    case test = "Тест"
    case document = "Документ"
    case meeting = "Встреча"
    case task = "Задача"
    case feedback = "Обратная связь"
}

// MARK: - Mock Data
extension OnboardingProgram {
    static func createMockPrograms() -> [OnboardingProgram] {
        [
            OnboardingProgram(
                templateId: UUID(),
                employeeId: UUID(),
                employeeName: "Иван Петров",
                employeePosition: "Junior продавец",
                employeeDepartment: "Отдел продаж",
                managerId: UUID(),
                managerName: "Анна Смирнова",
                title: "Адаптация продавца-консультанта",
                description: "Программа адаптации для новых сотрудников отдела продаж",
                startDate: Date().addingTimeInterval(-7*24*60*60), // 7 days ago
                targetEndDate: Date().addingTimeInterval(23*24*60*60), // 23 days from now
                stages: createMockStages(),
                totalDuration: 30,
                status: .inProgress
            ),
            OnboardingProgram(
                templateId: UUID(),
                employeeId: UUID(),
                employeeName: "Мария Иванова",
                employeePosition: "Кассир",
                employeeDepartment: "Операционный отдел",
                managerId: UUID(),
                managerName: "Елена Козлова",
                title: "Адаптация кассира",
                description: "Программа для новых сотрудников кассовой зоны",
                startDate: Date().addingTimeInterval(-2*24*60*60), // 2 days ago
                targetEndDate: Date().addingTimeInterval(19*24*60*60), // 19 days from now
                stages: createMockStagesForCashier(),
                totalDuration: 21,
                status: .inProgress
            ),
            OnboardingProgram(
                templateId: UUID(),
                employeeId: UUID(),
                employeeName: "Алексей Сидоров",
                employeePosition: "Визуальный мерчандайзер",
                employeeDepartment: "Отдел маркетинга",
                managerId: UUID(),
                managerName: "Ольга Белова",
                title: "Адаптация мерчандайзера",
                description: "Специализированная программа для визуальных мерчандайзеров",
                startDate: Date().addingTimeInterval(-14*24*60*60), // 14 days ago
                targetEndDate: Date().addingTimeInterval(16*24*60*60), // 16 days from now
                actualEndDate: nil,
                stages: createCompletedStages(),
                totalDuration: 30,
                status: .inProgress
            )
        ]
    }
    
    static func createMockStages() -> [OnboardingStage] {
        [
            OnboardingStage(
                orderIndex: 1,
                title: "Знакомство с компанией",
                description: "Первые шаги в компании",
                duration: 3,
                tasks: [
                    OnboardingTask(
                        title: "Встреча с руководителем",
                        description: "Знакомство с непосредственным руководителем и командой",
                        type: .meeting,
                        isCompleted: true,
                        completedAt: Date().addingTimeInterval(-6*24*60*60)
                    ),
                    OnboardingTask(
                        title: "Экскурсия по офису",
                        description: "Ознакомление с рабочим пространством",
                        type: .task,
                        isCompleted: true,
                        completedAt: Date().addingTimeInterval(-6*24*60*60)
                    ),
                    OnboardingTask(
                        title: "Получение пропуска и оборудования",
                        description: "Оформление доступов и получение рабочих инструментов",
                        type: .task,
                        isCompleted: true,
                        completedAt: Date().addingTimeInterval(-5*24*60*60)
                    ),
                    OnboardingTask(
                        title: "Изучение корпоративной культуры",
                        description: "Курс о ценностях и принципах компании",
                        type: .course,
                        isCompleted: true,
                        completedAt: Date().addingTimeInterval(-4*24*60*60),
                        courseId: UUID()
                    )
                ],
                status: .completed,
                startDate: Date().addingTimeInterval(-7*24*60*60),
                endDate: Date().addingTimeInterval(-4*24*60*60)
            ),
            OnboardingStage(
                orderIndex: 2,
                title: "Обучение продуктам",
                description: "Изучение ассортимента и особенностей товаров",
                duration: 7,
                tasks: [
                    OnboardingTask(
                        title: "Курс: Товароведение",
                        description: "Базовые знания об ассортименте магазина",
                        type: .course,
                        isCompleted: true,
                        completedAt: Date().addingTimeInterval(-2*24*60*60),
                        courseId: UUID()
                    ),
                    OnboardingTask(
                        title: "Тест по товароведению",
                        description: "Проверка знаний ассортимента",
                        type: .test,
                        isCompleted: false,
                        testId: UUID(),
                        dueDate: Date().addingTimeInterval(2*24*60*60)
                    ),
                    OnboardingTask(
                        title: "Практика в торговом зале",
                        description: "Работа с наставником в отделе",
                        type: .task,
                        isCompleted: false
                    )
                ],
                status: .inProgress,
                startDate: Date().addingTimeInterval(-3*24*60*60)
            ),
            OnboardingStage(
                orderIndex: 3,
                title: "Навыки продаж",
                description: "Развитие компетенций в области продаж",
                duration: 10,
                tasks: [
                    OnboardingTask(
                        title: "Курс: Основы продаж",
                        description: "Техники продаж и работа с клиентами",
                        type: .course,
                        courseId: UUID()
                    ),
                    OnboardingTask(
                        title: "Курс: Работа с возражениями",
                        description: "Преодоление возражений клиентов",
                        type: .course,
                        courseId: UUID()
                    ),
                    OnboardingTask(
                        title: "Ролевые игры с наставником",
                        description: "Практическая отработка навыков",
                        type: .meeting
                    ),
                    OnboardingTask(
                        title: "Самостоятельная работа с клиентами",
                        description: "Первые продажи под контролем наставника",
                        type: .task
                    )
                ],
                status: .notStarted
            ),
            OnboardingStage(
                orderIndex: 4,
                title: "Финальная оценка",
                description: "Завершение адаптационного периода",
                duration: 3,
                tasks: [
                    OnboardingTask(
                        title: "Итоговый тест",
                        description: "Комплексная проверка всех знаний",
                        type: .test,
                        testId: UUID()
                    ),
                    OnboardingTask(
                        title: "Обратная связь от наставника",
                        description: "Оценка прогресса и рекомендации",
                        type: .feedback
                    ),
                    OnboardingTask(
                        title: "Встреча с HR",
                        description: "Обсуждение результатов адаптации",
                        type: .meeting
                    ),
                    OnboardingTask(
                        title: "План развития на испытательный срок",
                        description: "Постановка целей на следующий период",
                        type: .document
                    )
                ],
                status: .notStarted
            )
        ]
    }
    
    static func createMockStagesForCashier() -> [OnboardingStage] {
        [
            OnboardingStage(
                orderIndex: 1,
                title: "Введение в работу",
                description: "Знакомство с компанией и рабочим местом",
                duration: 2,
                tasks: [
                    OnboardingTask(
                        title: "Встреча с управляющим",
                        description: "Приветствие и введение в должность",
                        type: .meeting,
                        isCompleted: true,
                        completedAt: Date().addingTimeInterval(-1*24*60*60)
                    ),
                    OnboardingTask(
                        title: "Знакомство с кассовой зоной",
                        description: "Изучение рабочего места",
                        type: .task,
                        isCompleted: true,
                        completedAt: Date().addingTimeInterval(-1*24*60*60)
                    )
                ],
                status: .completed,
                startDate: Date().addingTimeInterval(-2*24*60*60),
                endDate: Date().addingTimeInterval(-1*24*60*60)
            ),
            OnboardingStage(
                orderIndex: 2,
                title: "Обучение кассовым операциям",
                description: "Освоение работы с кассой",
                duration: 5,
                tasks: [
                    OnboardingTask(
                        title: "Курс: Работа с кассой",
                        description: "Базовые операции и процедуры",
                        type: .course,
                        isCompleted: false,
                        courseId: UUID()
                    ),
                    OnboardingTask(
                        title: "Практика с наставником",
                        description: "Отработка операций на кассе",
                        type: .task
                    )
                ],
                status: .inProgress,
                startDate: Date()
            )
        ]
    }
    
    static func createCompletedStages() -> [OnboardingStage] {
        var stages = createMockStages()
        // Mark most tasks as completed
        for i in 0..<3 {
            stages[i].status = .completed
            for j in 0..<stages[i].tasks.count {
                stages[i].tasks[j].isCompleted = true
                stages[i].tasks[j].completedAt = Date().addingTimeInterval(Double(-10 + i*3 + j)*24*60*60)
            }
        }
        stages[3].status = .inProgress
        stages[3].tasks[0].isCompleted = true
        stages[3].tasks[0].completedAt = Date().addingTimeInterval(-1*24*60*60)
        
        return stages
    }
} 