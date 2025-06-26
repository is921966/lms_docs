//
//  OnboardingTemplate.swift
//  LMS
//
//  Created on 27/01/2025.
//

import Foundation
import SwiftUI

// MARK: - Onboarding Template
struct OnboardingTemplate: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let targetPosition: String
    let targetDepartment: String?
    let duration: Int // in days
    
    var stages: [OnboardingTemplateStage]
    var isActive: Bool = true
    let createdAt: Date
    var updatedAt: Date
    
    var icon: String {
        switch targetPosition.lowercased() {
        case let pos where pos.contains("продав"):
            return "cart.fill"
        case let pos where pos.contains("кассир"):
            return "banknote.fill"
        case let pos where pos.contains("менеджер"):
            return "person.3.fill"
        case let pos where pos.contains("мерчандайзер"):
            return "paintbrush.fill"
        default:
            return "person.fill.badge.plus"
        }
    }
    
    var color: Color {
        switch targetPosition.lowercased() {
        case let pos where pos.contains("продав"):
            return .blue
        case let pos where pos.contains("кассир"):
            return .green
        case let pos where pos.contains("менеджер"):
            return .purple
        case let pos where pos.contains("мерчандайзер"):
            return .orange
        default:
            return .gray
        }
    }
}

// MARK: - Template Stage
struct OnboardingTemplateStage: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var order: Int
    var duration: Int // in days
    var tasks: [OnboardingTemplateTask]
    
    init(id: UUID = UUID(), title: String, description: String, order: Int, duration: Int, tasks: [OnboardingTemplateTask] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.order = order
        self.duration = duration
        self.tasks = tasks
    }
}

// MARK: - Template Task
struct OnboardingTemplateTask: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var type: OnboardingTaskType
    var order: Int
    var assigneeType: AssigneeType
    var requiredDocuments: [String]
    var checklistItems: [String]
    
    // Optional links
    var courseId: UUID?
    var testId: UUID?
    var documentUrl: String?
    var documentTemplateId: UUID?
    
    init(id: UUID = UUID(), title: String, description: String, type: OnboardingTaskType, order: Int, assigneeType: AssigneeType, requiredDocuments: [String] = [], checklistItems: [String] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
        self.order = order
        self.assigneeType = assigneeType
        self.requiredDocuments = requiredDocuments
        self.checklistItems = checklistItems
    }
    
    init(title: String, description: String, type: OnboardingTaskType, order: Int, assigneeType: AssigneeType, requiredDocuments: [String] = [], checklistItems: [String] = []) {
        self.title = title
        self.description = description
        self.type = type
        self.order = order
        self.assigneeType = assigneeType
        self.requiredDocuments = requiredDocuments
        self.checklistItems = checklistItems
    }
    
    func apply(_ block: (inout OnboardingTemplateTask) -> Void) -> OnboardingTemplateTask {
        var task = self
        block(&task)
        return task
    }
}

// MARK: - Enums
enum OnboardingTaskType: String, Codable, CaseIterable {
    case course = "Курс"
    case test = "Тест"
    case document = "Документ"
    case meeting = "Встреча"
    case task = "Задача"
    case checklist = "Чек-лист"
    case feedback = "Обратная связь"
}

enum AssigneeType: String, Codable {
    case employee = "Сотрудник"
    case manager = "Руководитель"
    case mentor = "Наставник"
    case hr = "HR"
}

// MARK: - Stage Status
enum StageStatus: String, Codable, CaseIterable {
    case notStarted = "Не начат"
    case inProgress = "В процессе"
    case completed = "Завершен"
    case cancelled = "Отменен"
}

// MARK: - Helper Functions
extension OnboardingTemplateTask {
    static func course(title: String, description: String, order: Int, assigneeType: AssigneeType, courseId: UUID = UUID()) -> OnboardingTemplateTask {
        var task = OnboardingTemplateTask(title: title, description: description, type: .course, order: order, assigneeType: assigneeType)
        task.courseId = courseId
        return task
    }
    
    static func test(title: String, description: String, order: Int, assigneeType: AssigneeType, testId: UUID = UUID()) -> OnboardingTemplateTask {
        var task = OnboardingTemplateTask(title: title, description: description, type: .test, order: order, assigneeType: assigneeType)
        task.testId = testId
        return task
    }
    
    static func document(title: String, description: String, order: Int, assigneeType: AssigneeType, documentUrl: String) -> OnboardingTemplateTask {
        var task = OnboardingTemplateTask(title: title, description: description, type: .document, order: order, assigneeType: assigneeType)
        task.documentUrl = documentUrl
        return task
    }
    
    static func meeting(title: String, description: String, order: Int, assigneeType: AssigneeType) -> OnboardingTemplateTask {
        OnboardingTemplateTask(title: title, description: description, type: .meeting, order: order, assigneeType: assigneeType)
    }
    
    static func task(title: String, description: String, order: Int, assigneeType: AssigneeType) -> OnboardingTemplateTask {
        OnboardingTemplateTask(title: title, description: description, type: .task, order: order, assigneeType: assigneeType)
    }
}

// MARK: - Mock Templates
extension OnboardingTemplate {
    static let mockTemplates = [
        OnboardingTemplate(
            title: "Адаптация продавца-консультанта",
            description: "Стандартная программа для новых продавцов",
            targetPosition: "Продавец",
            targetDepartment: "Отдел продаж",
            duration: 30,
            stages: [
                OnboardingTemplateStage(
                    title: "Знакомство с компанией",
                    description: "Введение в корпоративную культуру",
                    order: 1,
                    duration: 3,
                    tasks: [
                        .meeting(
                            title: "Встреча с руководителем",
                            description: "Знакомство с непосредственным руководителем",
                            order: 1,
                            assigneeType: .manager
                        ),
                        .task(
                            title: "Экскурсия по магазину",
                            description: "Ознакомление с торговым пространством",
                            order: 2,
                            assigneeType: .mentor
                        ),
                        .course(
                            title: "Курс: Корпоративная культура",
                            description: "Изучение ценностей и принципов компании",
                            order: 3,
                            assigneeType: .employee
                        )
                    ]
                ),
                OnboardingTemplateStage(
                    title: "Изучение ассортимента",
                    description: "Знакомство с товарами и брендами",
                    order: 2,
                    duration: 7,
                    tasks: [
                        .course(
                            title: "Курс: Товароведение",
                            description: "Базовые знания об ассортименте",
                            order: 1,
                            assigneeType: .employee
                        ),
                        .test(
                            title: "Тест по товароведению",
                            description: "Проверка знаний ассортимента",
                            order: 2,
                            assigneeType: .employee
                        )
                    ]
                ),
                OnboardingTemplateStage(
                    title: "Навыки продаж",
                    description: "Развитие компетенций продавца",
                    order: 3,
                    duration: 14,
                    tasks: [
                        .course(
                            title: "Курс: Основы продаж",
                            description: "Техники эффективных продаж",
                            order: 1,
                            assigneeType: .employee
                        ),
                        .task(
                            title: "Практика с наставником",
                            description: "Работа в паре с опытным продавцом",
                            order: 2,
                            assigneeType: .mentor
                        )
                    ]
                )
            ],
            isActive: true,
            createdAt: Date().addingTimeInterval(-90*24*60*60),
            updatedAt: Date().addingTimeInterval(-30*24*60*60)
        ),
        
        OnboardingTemplate(
            title: "Адаптация кассира",
            description: "Программа для сотрудников кассовой зоны",
            targetPosition: "Кассир",
            targetDepartment: "Операционный отдел",
            duration: 21,
            stages: [
                OnboardingTemplateStage(
                    title: "Введение в должность",
                    description: "Первые шаги на новом месте",
                    order: 1,
                    duration: 2,
                    tasks: [
                        .meeting(
                            title: "Встреча с управляющим",
                            description: "Знакомство и постановка задач",
                            order: 1,
                            assigneeType: .manager
                        ),
                        .task(
                            title: "Изучение кассовой зоны",
                            description: "Знакомство с рабочим местом",
                            order: 2,
                            assigneeType: .mentor
                        )
                    ]
                ),
                OnboardingTemplateStage(
                    title: "Обучение кассовым операциям",
                    description: "Освоение функционала кассы",
                    order: 2,
                    duration: 7,
                    tasks: [
                        .course(
                            title: "Курс: Работа с кассой",
                            description: "Все виды кассовых операций",
                            order: 1,
                            assigneeType: .employee
                        ),
                        .task(
                            title: "Практика под контролем",
                            description: "Работа с наставником",
                            order: 2,
                            assigneeType: .mentor
                        ),
                        .test(
                            title: "Тест по кассовым операциям",
                            description: "Проверка навыков",
                            order: 3,
                            assigneeType: .employee
                        )
                    ]
                )
            ],
            isActive: true,
            createdAt: Date().addingTimeInterval(-60*24*60*60),
            updatedAt: Date().addingTimeInterval(-7*24*60*60)
        ),
        
        OnboardingTemplate(
            title: "Адаптация визуального мерчандайзера",
            description: "Специализированная программа для VM",
            targetPosition: "Визуальный мерчандайзер",
            targetDepartment: "Отдел маркетинга",
            duration: 30,
            stages: [
                OnboardingTemplateStage(
                    title: "Введение в визуальный мерчандайзинг",
                    description: "Основы профессии",
                    order: 1,
                    duration: 3,
                    tasks: [
                        .meeting(
                            title: "Встреча с руководителем VM",
                            description: "Обсуждение стандартов и требований",
                            order: 1,
                            assigneeType: .manager
                        ),
                        .document(
                            title: "Изучение brand book",
                            description: "Стандарты визуального оформления",
                            order: 2,
                            assigneeType: .employee,
                            documentUrl: "https://example.com/brandbook.pdf"
                        )
                    ]
                ),
                OnboardingTemplateStage(
                    title: "Практические навыки",
                    description: "Отработка техник VM",
                    order: 2,
                    duration: 14,
                    tasks: [
                        .course(
                            title: "Курс: Визуальный мерчандайзинг",
                            description: "Теория и практика VM",
                            order: 1,
                            assigneeType: .employee
                        ),
                        .task(
                            title: "Создание первой витрины",
                            description: "Самостоятельная работа под контролем",
                            order: 2,
                            assigneeType: .mentor
                        ),
                        .task(
                            title: "Анализ конкурентов",
                            description: "Изучение лучших практик",
                            order: 3,
                            assigneeType: .employee
                        )
                    ]
                )
            ],
            isActive: true,
            createdAt: Date().addingTimeInterval(-45*24*60*60),
            updatedAt: Date().addingTimeInterval(-14*24*60*60)
        ),
        
        OnboardingTemplate(
            title: "Адаптация руководителя отдела",
            description: "Программа для управленческих позиций",
            targetPosition: "Руководитель отдела",
            targetDepartment: nil,
            duration: 45,
            stages: [
                OnboardingTemplateStage(
                    title: "Управленческий онбординг",
                    description: "Введение в управленческую культуру",
                    order: 1,
                    duration: 5,
                    tasks: [
                        .meeting(
                            title: "Встреча с топ-менеджментом",
                            description: "Знакомство с руководством компании",
                            order: 1,
                            assigneeType: .manager
                        ),
                        .document(
                            title: "Изучение бизнес-процессов",
                            description: "Понимание операционной модели",
                            order: 2,
                            assigneeType: .employee,
                            documentUrl: "https://example.com/processes.pdf"
                        ),
                        .course(
                            title: "Курс: Лидерство в ЦУМ",
                            description: "Корпоративные стандарты управления",
                            order: 3,
                            assigneeType: .employee
                        )
                    ]
                )
            ],
            isActive: true,
            createdAt: Date().addingTimeInterval(-120*24*60*60),
            updatedAt: Date().addingTimeInterval(-60*24*60*60)
        )
    ]
} 