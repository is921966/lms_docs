import Foundation

protocol CourseServiceProtocol {
    func fetchCourses() async throws -> [ManagedCourse]
    func fetchCourse(id: UUID) async throws -> ManagedCourse
    func createCourse(_ course: ManagedCourse) async throws -> ManagedCourse
    func updateCourse(_ course: ManagedCourse) async throws -> ManagedCourse
    func deleteCourse(id: UUID) async throws
    func assignCourseToUsers(courseId: UUID, userIds: [UUID]) async throws
}

class CourseService: CourseServiceProtocol {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    func fetchCourses() async throws -> [ManagedCourse] {
        // В реальном приложении здесь будет вызов API
        // Для демо возвращаем моковые данные
        return ManagedCourse.mockCourses
    }
    
    func fetchCourse(id: UUID) async throws -> ManagedCourse {
        let courses = try await fetchCourses()
        guard let course = courses.first(where: { $0.id == id }) else {
            throw CourseError.notFound
        }
        return course
    }
    
    func createCourse(_ course: ManagedCourse) async throws -> ManagedCourse {
        // В реальном приложении здесь будет вызов API
        return course
    }
    
    func updateCourse(_ course: ManagedCourse) async throws -> ManagedCourse {
        // В реальном приложении здесь будет вызов API
        return course
    }
    
    func deleteCourse(id: UUID) async throws {
        // В реальном приложении здесь будет вызов API
    }
    
    func assignCourseToUsers(courseId: UUID, userIds: [UUID]) async throws {
        // В реальном приложении здесь будет вызов API
    }
}

enum CourseError: LocalizedError {
    case notFound
    case invalidData
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Курс не найден"
        case .invalidData:
            return "Неверные данные курса"
        case .networkError:
            return "Ошибка сети"
        }
    }
}

// Mock data
extension ManagedCourse {
    static let mockCourses: [ManagedCourse] = [
        ManagedCourse(
            title: "Основы Swift",
            description: "Изучите основы языка программирования Swift",
            duration: 40,
            status: .published,
            competencies: [UUID()],
            modules: [
                ManagedCourseModule(
                    id: UUID(),
                    title: "Введение в Swift",
                    description: "Основные концепции языка",
                    order: 1,
                    contentType: .video,
                    duration: 60
                ),
                ManagedCourseModule(
                    id: UUID(),
                    title: "Переменные и константы",
                    description: "Работа с данными",
                    order: 2,
                    contentType: .document,
                    duration: 30
                )
            ]
        ),
        ManagedCourse(
            title: "SwiftUI для начинающих",
            description: "Создание пользовательских интерфейсов с SwiftUI",
            duration: 60,
            status: .published,
            competencies: [UUID(), UUID()],
            modules: []
        ),
        ManagedCourse(
            title: "Архитектура iOS приложений",
            description: "Паттерны проектирования и архитектурные подходы",
            duration: 80,
            status: .draft,
            competencies: [],
            modules: []
        )
    ]
} 