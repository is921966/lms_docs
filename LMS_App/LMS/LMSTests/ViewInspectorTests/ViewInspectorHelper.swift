import SwiftUI
import ViewInspector
import XCTest
@testable import LMS

// MARK: - Base Test Class

@MainActor
class ViewInspectorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Общая настройка для всех ViewInspector тестов
    }
    
    override func tearDown() {
        super.tearDown()
        // Очистка после тестов
    }
}

// MARK: - Test Data Helpers

extension ViewInspectorTests {
    /// Создаем тестовые курсы
    static func mockCourses(count: Int = 5) -> [Course] {
        (1...count).map { index in
            Course(
                title: "Курс \(index)",
                description: "Описание курса \(index)",
                categoryId: CourseCategory.categories.first?.id,
                status: .published,
                type: .optional,
                modules: [],
                materials: [],
                testId: nil,
                competencyIds: [],
                positionIds: [],
                prerequisiteCourseIds: [],
                duration: "8 часов",
                estimatedHours: 8,
                passingScore: 80,
                certificateTemplateId: nil,
                maxAttempts: nil,
                createdBy: UUID(),
                createdAt: Date(),
                updatedAt: Date(),
                publishedAt: Date()
            )
        }
    }
    
    /// Создаем тестового пользователя
    static func mockUser(role: UserRole = .student) -> UserResponse {
        // Используем TestUserResponseFactory
        switch role {
        case .student:
            return TestUserResponseFactory.createStudent(
                id: "test-user",
                name: "Тест Пользователь"
            )
        case .instructor:
            return TestUserResponseFactory.createInstructor(
                id: "test-user",
                name: "Тест Инструктор"
            )
        case .admin:
            return TestUserResponseFactory.createAdmin(
                id: "test-user",
                name: "Тест Админ"
            )
        case .manager:
            return TestUserResponseFactory.createManager(
                id: "test-user",
                name: "Тест Менеджер"
            )
        case .superAdmin:
            return TestUserResponseFactory.createUser(
                id: "test-user",
                email: "superadmin@test.com",
                name: "Тест СуперАдмин",
                role: .superAdmin
            )
        }
    }
} 