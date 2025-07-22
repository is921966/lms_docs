import Foundation

protocol CourseServiceProtocol {
    func fetchCourses() async throws -> [ManagedCourse]
    func fetchCourse(id: UUID) async throws -> ManagedCourse
    func createCourse(_ course: ManagedCourse) async throws -> ManagedCourse
    func updateCourse(_ course: ManagedCourse) async throws -> ManagedCourse
    func deleteCourse(id: UUID) async throws
    func assignCourseToUsers(courseId: UUID, userIds: [UUID]) async throws
    func duplicateCourse(_ id: UUID) async throws -> ManagedCourse
}

class CourseService: CourseServiceProtocol {
    private let apiClient: APIClient
    
    // Временное хранилище курсов в памяти
    @MainActor
    private static var storedCourses: [ManagedCourse] = ManagedCourse.mockCourses
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    func fetchCourses() async throws -> [ManagedCourse] {
        // В реальном приложении здесь будет вызов API
        // Возвращаем все курсы из временного хранилища
        return await MainActor.run {
            print("📚 CourseService.fetchCourses: Returning \(Self.storedCourses.count) courses")
            return Self.storedCourses
        }
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
        // Добавляем курс в временное хранилище
        await MainActor.run {
            print("📚 CourseService.createCourse: Before adding - \(Self.storedCourses.count) courses")
            Self.storedCourses.append(course)
            print("📚 CourseService.createCourse: After adding - \(Self.storedCourses.count) courses")
        }
        print("📚 CourseService: Created course '\(course.title)' (ID: \(course.id))")
        if course.cmi5PackageId != nil {
            print("   - This course was created from Cmi5 package")
        }
        return course
    }
    
    func updateCourse(_ course: ManagedCourse) async throws -> ManagedCourse {
        // В реальном приложении здесь будет вызов API
        await MainActor.run {
            if let index = Self.storedCourses.firstIndex(where: { $0.id == course.id }) {
                Self.storedCourses[index] = course
            }
        }
        return course
    }
    
    func deleteCourse(id: UUID) async throws {
        // В реальном приложении здесь будет вызов API
        await MainActor.run {
            Self.storedCourses.removeAll { $0.id == id }
        }
    }
    
    func assignCourseToUsers(courseId: UUID, userIds: [UUID]) async throws {
        // В реальном приложении здесь будет вызов API
        print("📚 CourseService: Assigning course \(courseId) to \(userIds.count) users")
    }
    
    func duplicateCourse(_ id: UUID) async throws -> ManagedCourse {
        let course = try await fetchCourse(id: id)
        let newCourse = try await createCourse(course)
        return newCourse
    }
}

enum CourseError: LocalizedError {
    case notFound
    case invalidData
    case networkError
    case courseNotFound
    case invalidCourse
    case duplicateFailed
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .notFound, .courseNotFound:
            return "Курс не найден"
        case .invalidData, .invalidCourse:
            return "Неверные данные курса"
        case .networkError:
            return "Ошибка сети"
        case .duplicateFailed:
            return "Не удалось дублировать курс"
        case .permissionDenied:
            return "Недостаточно прав для выполнения операции"
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
            title: "AI Fluency Course",
            description: "Comprehensive AI education course with Cmi5 modules",
            duration: 60,
            status: .published,
            competencies: [UUID()],
            modules: [
                ManagedCourseModule(
                    id: UUID(),
                    title: "Introduction to AI",
                    description: "Learn the basics of artificial intelligence",
                    order: 1,
                    contentType: .cmi5,
                    contentUrl: "intro_to_ai", // Соответствует activityId в Cmi5Repository
                    duration: 30
                ),
                ManagedCourseModule(
                    id: UUID(),
                    title: "AI Applications",
                    description: "Explore real-world AI applications",
                    order: 2,
                    contentType: .cmi5,
                    contentUrl: "ai_applications", // Соответствует activityId в Cmi5Repository
                    duration: 45
                )
            ],
            cmi5PackageId: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440000") // Соответствует Cmi5Repository.aiFlencyPackageId
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