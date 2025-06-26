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

// MARK: - Task Template
struct OnboardingTaskTemplate: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let type: TaskType
    
    // Optional links to predefined content
    var courseId: UUID?
    var testId: UUID?
    var documentTemplateId: UUID?
    
    var isRequired: Bool = true
    var estimatedDuration: Int? // in minutes
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
                    orderIndex: 1,
                    title: "Знакомство с компанией",
                    description: "Введение в корпоративную культуру",
                    duration: 3,
                    taskTemplates: [
                        OnboardingTaskTemplate(
                            title: "Встреча с руководителем",
                            description: "Знакомство с непосредственным руководителем",
                            type: .meeting,
                            estimatedDuration: 60
                        ),
                        OnboardingTaskTemplate(
                            title: "Экскурсия по магазину",
                            description: "Ознакомление с торговым пространством",
                            type: .task,
                            estimatedDuration: 90
                        ),
                        OnboardingTaskTemplate(
                            title: "Курс: Корпоративная культура",
                            description: "Изучение ценностей и принципов компании",
                            type: .course,
                            courseId: UUID(),
                            estimatedDuration: 120
                        )
                    ]
                ),
                OnboardingTemplateStage(
                    orderIndex: 2,
                    title: "Изучение ассортимента",
                    description: "Знакомство с товарами и брендами",
                    duration: 7,
                    taskTemplates: [
                        OnboardingTaskTemplate(
                            title: "Курс: Товароведение",
                            description: "Базовые знания об ассортименте",
                            type: .course,
                            courseId: UUID(),
                            estimatedDuration: 480
                        ),
                        OnboardingTaskTemplate(
                            title: "Тест по товароведению",
                            description: "Проверка знаний ассортимента",
                            type: .test,
                            testId: UUID(),
                            estimatedDuration: 60
                        )
                    ]
                ),
                OnboardingTemplateStage(
                    orderIndex: 3,
                    title: "Навыки продаж",
                    description: "Развитие компетенций продавца",
                    duration: 14,
                    taskTemplates: [
                        OnboardingTaskTemplate(
                            title: "Курс: Основы продаж",
                            description: "Техники эффективных продаж",
                            type: .course,
                            courseId: UUID(),
                            estimatedDuration: 360
                        ),
                        OnboardingTaskTemplate(
                            title: "Практика с наставником",
                            description: "Работа в паре с опытным продавцом",
                            type: .task,
                            estimatedDuration: 2400
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
                    orderIndex: 1,
                    title: "Введение в должность",
                    description: "Первые шаги на новом месте",
                    duration: 2,
                    taskTemplates: [
                        OnboardingTaskTemplate(
                            title: "Встреча с управляющим",
                            description: "Знакомство и постановка задач",
                            type: .meeting,
                            estimatedDuration: 30
                        ),
                        OnboardingTaskTemplate(
                            title: "Изучение кассовой зоны",
                            description: "Знакомство с рабочим местом",
                            type: .task,
                            estimatedDuration: 60
                        )
                    ]
                ),
                OnboardingTemplateStage(
                    orderIndex: 2,
                    title: "Обучение кассовым операциям",
                    description: "Освоение функционала кассы",
                    duration: 7,
                    taskTemplates: [
                        OnboardingTaskTemplate(
                            title: "Курс: Работа с кассой",
                            description: "Все виды кассовых операций",
                            type: .course,
                            courseId: UUID(),
                            estimatedDuration: 480
                        ),
                        OnboardingTaskTemplate(
                            title: "Практика под контролем",
                            description: "Работа с наставником",
                            type: .task,
                            estimatedDuration: 1200
                        ),
                        OnboardingTaskTemplate(
                            title: "Тест по кассовым операциям",
                            description: "Проверка навыков",
                            type: .test,
                            testId: UUID(),
                            estimatedDuration: 45
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
                    orderIndex: 1,
                    title: "Введение в визуальный мерчандайзинг",
                    description: "Основы профессии",
                    duration: 3,
                    taskTemplates: [
                        OnboardingTaskTemplate(
                            title: "Встреча с руководителем VM",
                            description: "Обсуждение стандартов и требований",
                            type: .meeting,
                            estimatedDuration: 90
                        ),
                        OnboardingTaskTemplate(
                            title: "Изучение brand book",
                            description: "Стандарты визуального оформления",
                            type: .document,
                            documentTemplateId: UUID(),
                            estimatedDuration: 180
                        )
                    ]
                ),
                OnboardingTemplateStage(
                    orderIndex: 2,
                    title: "Практические навыки",
                    description: "Отработка техник VM",
                    duration: 14,
                    taskTemplates: [
                        OnboardingTaskTemplate(
                            title: "Курс: Визуальный мерчандайзинг",
                            description: "Теория и практика VM",
                            type: .course,
                            courseId: UUID(),
                            estimatedDuration: 600
                        ),
                        OnboardingTaskTemplate(
                            title: "Создание первой витрины",
                            description: "Самостоятельная работа под контролем",
                            type: .task,
                            estimatedDuration: 480
                        ),
                        OnboardingTaskTemplate(
                            title: "Анализ конкурентов",
                            description: "Изучение лучших практик",
                            type: .task,
                            estimatedDuration: 240
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
                    orderIndex: 1,
                    title: "Управленческий онбординг",
                    description: "Введение в управленческую культуру",
                    duration: 5,
                    taskTemplates: [
                        OnboardingTaskTemplate(
                            title: "Встреча с топ-менеджментом",
                            description: "Знакомство с руководством компании",
                            type: .meeting,
                            estimatedDuration: 120
                        ),
                        OnboardingTaskTemplate(
                            title: "Изучение бизнес-процессов",
                            description: "Понимание операционной модели",
                            type: .document,
                            documentTemplateId: UUID(),
                            estimatedDuration: 480
                        ),
                        OnboardingTaskTemplate(
                            title: "Курс: Лидерство в ЦУМ",
                            description: "Корпоративные стандарты управления",
                            type: .course,
                            courseId: UUID(),
                            estimatedDuration: 360
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