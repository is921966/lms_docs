//
//  OnboardingTests.swift
//  LMSTests
//
//  Created on 27/01/2025.
//

@testable import LMS
import XCTest

final class OnboardingTests: XCTestCase {
    private var onboardingService: OnboardingMockService!

    override func setUp() {
        super.setUp()
        onboardingService = OnboardingMockService.shared
        onboardingService.resetData()
    }

    override func tearDown() {
        onboardingService = nil
        super.tearDown()
    }

    // MARK: - OnboardingProgram Tests

    func testOnboardingProgramCreation() {
        // Given
        let program = OnboardingProgram(
            templateId: UUID(),
            employeeId: UUID(),
            employeeName: "Иван Петров",
            employeePosition: "Продавец",
            employeeDepartment: "Отдел продаж",
            managerId: UUID(),
            managerName: "Анна Смирнова",
            title: "Адаптация продавца",
            description: "Программа для новых продавцов",
            startDate: Date(),
            targetEndDate: Date().addingTimeInterval(30 * 24 * 60 * 60),
            stages: [],
            totalDuration: 30,
            status: .notStarted
        )

        // Then
        XCTAssertNotNil(program)
        XCTAssertEqual(program.employeeName, "Иван Петров")
        XCTAssertEqual(program.status, .notStarted)
        XCTAssertEqual(program.overallProgress, 0.0)
    }

    func testProgramProgressCalculation() {
        // Given
        let stages = [
            OnboardingStage(
                id: UUID(),
                templateStageId: nil,
                title: "Этап 1",
                description: "Описание",
                order: 1,
                duration: 5,
                startDate: nil,
                endDate: nil,
                status: StageStatus.completed,
                completionPercentage: 1.0,
                tasks: [
                    OnboardingTask(title: "Задача 1", description: "", type: .task, isCompleted: true),
                    OnboardingTask(title: "Задача 2", description: "", type: .task, isCompleted: true)
                ]
            ),
            OnboardingStage(
                id: UUID(),
                templateStageId: nil,
                title: "Этап 2",
                description: "Описание",
                order: 2,
                duration: 5,
                startDate: nil,
                endDate: nil,
                status: StageStatus.inProgress,
                completionPercentage: 0.5,
                tasks: [
                    OnboardingTask(title: "Задача 3", description: "", type: .task, isCompleted: true),
                    OnboardingTask(title: "Задача 4", description: "", type: .task, isCompleted: false)
                ]
            )
        ]

        let program = OnboardingProgram(
            templateId: UUID(),
            employeeId: UUID(),
            employeeName: "Тест",
            employeePosition: "Тест",
            employeeDepartment: "Тест",
            managerId: UUID(),
            managerName: "Тест",
            title: "Тест",
            description: "Тест",
            startDate: Date(),
            targetEndDate: Date().addingTimeInterval(10 * 24 * 60 * 60),
            stages: stages,
            totalDuration: 10,
            status: .inProgress
        )

        // Then
        XCTAssertEqual(program.completedStages, 1)
        XCTAssertEqual(program.overallProgress, 0.75) // 3 из 4 задач выполнено
    }

    func testProgramOverdueStatus() {
        // Given
        let program = OnboardingProgram(
            templateId: UUID(),
            employeeId: UUID(),
            employeeName: "Тест",
            employeePosition: "Тест",
            employeeDepartment: "Тест",
            managerId: UUID(),
            managerName: "Тест",
            title: "Тест",
            description: "Тест",
            startDate: Date().addingTimeInterval(-20 * 24 * 60 * 60),
            targetEndDate: Date().addingTimeInterval(-5 * 24 * 60 * 60), // 5 дней назад
            stages: [],
            totalDuration: 15,
            status: .inProgress
        )

        // Then
        XCTAssertTrue(program.isOverdue)
        XCTAssertLessThan(program.daysRemaining, 0)
    }

    // MARK: - OnboardingStage Tests

    func testStageProgressCalculation() {
        // Given
        let tasks = [
            OnboardingTask(title: "Задача 1", description: "", type: .task, isCompleted: true),
            OnboardingTask(title: "Задача 2", description: "", type: .task, isCompleted: true),
            OnboardingTask(title: "Задача 3", description: "", type: .task, isCompleted: false),
            OnboardingTask(title: "Задача 4", description: "", type: .task, isCompleted: false)
        ]

        let stage = OnboardingStage(
            id: UUID(),
            templateStageId: nil,
            title: "Тестовый этап",
            description: "Описание",
            order: 1,
            duration: 5,
            startDate: nil,
            endDate: nil,
            status: StageStatus.inProgress,
            completionPercentage: 0.5,
            tasks: tasks
        )

        // Then
        XCTAssertEqual(stage.progress, 0.5) // 2 из 4 задач выполнено
        XCTAssertEqual(stage.completedTasks, 2)
    }

    // MARK: - OnboardingTask Tests

    func testTaskIconAndColor() {
        // Given
        let courseTask = OnboardingTask(title: "Курс", description: "", type: .course)
        let testTask = OnboardingTask(title: "Тест", description: "", type: .test)
        let meetingTask = OnboardingTask(title: "Встреча", description: "", type: .meeting)

        // Then
        XCTAssertEqual(courseTask.icon, "book.closed.fill")
        XCTAssertEqual(testTask.icon, "doc.text.fill")
        XCTAssertEqual(meetingTask.icon, "person.2.fill")
    }

    // MARK: - OnboardingService Tests

    func testCreateProgramFromTemplate() {
        // Given
        let template = OnboardingTemplate.mockTemplates.first!

        // When
        let program = onboardingService.createProgramFromTemplate(
            templateId: template.id,
            employeeName: "Новый сотрудник",
            position: "Должность",
            startDate: Date()
        )

        // Then
        XCTAssertNotNil(program)
        XCTAssertEqual(program?.templateId, template.id)
        XCTAssertEqual(program?.employeeName, "Новый сотрудник")
        XCTAssertEqual(program?.employeePosition, "Должность")
        XCTAssertEqual(program?.stages.count, template.stages.count)
        if let program = program {
            XCTAssertTrue(onboardingService.programs.contains { $0.id == program.id })
        }
    }

    func testGetProgramsForUser() {
        // Given
        let userId = UUID()
        // Сначала создаем программу
        let program1 = onboardingService.createProgramFromTemplate(
            templateId: OnboardingTemplate.mockTemplates.first!.id,
            employeeName: "Сотрудник",
            position: "Должность",
            startDate: Date()
        )

        // Привязываем программу к пользователю через employeeId
        if let program1 = program1 {
            var updatedProgram = program1
            updatedProgram.employeeId = userId
            // Обновляем программу в сервисе
            if let index = onboardingService.programs.firstIndex(where: { $0.id == program1.id }) {
                onboardingService.programs[index] = updatedProgram
            }
        }

        // When
        let userPrograms = onboardingService.getProgramsForUser(userId)

        // Then
        XCTAssertEqual(userPrograms.count, 1)
        XCTAssertEqual(userPrograms.first?.id, program1?.id)
    }

    func testUpdateTaskStatus() {
        // Given
        let program = onboardingService.programs.first!
        let stage = program.stages.first!
        let task = stage.tasks.first!

        // When
        onboardingService.updateTaskStatus(
            programId: program.id,
            taskId: task.id,
            isCompleted: true
        )

        // Then
        let updatedProgram = onboardingService.programs.first { $0.id == program.id }
        let updatedTask = updatedProgram?.stages.first?.tasks.first
        XCTAssertTrue(updatedTask?.isCompleted ?? false)
    }

    // MARK: - Template Tests

    func testTemplateCreation() {
        // Given
        let template = OnboardingTemplate(
            title: "Тестовый шаблон",
            description: "Описание",
            targetPosition: "Должность",
            targetDepartment: "Отдел",
            duration: 30,
            stages: [],
            isActive: true,
            createdAt: Date(),
            updatedAt: Date()
        )

        // Then
        XCTAssertNotNil(template)
        XCTAssertEqual(template.title, "Тестовый шаблон")
        XCTAssertEqual(template.duration, 30)
    }

    func testMockTemplatesExist() {
        // Given
        let templates = OnboardingTemplate.mockTemplates

        // Then
        XCTAssertGreaterThan(templates.count, 0)
        XCTAssertTrue(templates.allSatisfy { !$0.stages.isEmpty })
    }
}

// MARK: - UI Tests
final class OnboardingUITests: XCTestCase {
    func testOnboardingDashboardFiltering() {
        // Given
        let dashboard = OnboardingDashboard()
        let allFilter = OnboardingDashboard.FilterType.all
        let inProgressFilter = OnboardingDashboard.FilterType.inProgress

        // Then
        XCTAssertNotNil(dashboard)
        XCTAssertEqual(allFilter.rawValue, "Все")
        XCTAssertEqual(inProgressFilter.rawValue, "В процессе")
    }

    func testStatusBadgeColors() {
        // Given
        let notStartedStatus = OnboardingStatus.notStarted
        let inProgressStatus = OnboardingStatus.inProgress
        let completedStatus = OnboardingStatus.completed

        // Then
        XCTAssertEqual(notStartedStatus.rawValue, "Не начат")
        XCTAssertEqual(inProgressStatus.rawValue, "В процессе")
        XCTAssertEqual(completedStatus.rawValue, "Завершен")
    }
}
