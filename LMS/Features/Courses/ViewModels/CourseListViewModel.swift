import Foundation
import Combine

@MainActor
final class CourseListViewModel: ObservableObject {
    @Published var courses: [Course] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage: String?
    
    private let fetchCoursesUseCase: FetchCoursesUseCaseProtocol
    private let enrollCourseUseCase: EnrollCourseUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        fetchCoursesUseCase: FetchCoursesUseCaseProtocol,
        enrollCourseUseCase: EnrollCourseUseCaseProtocol
    ) {
        self.fetchCoursesUseCase = fetchCoursesUseCase
        self.enrollCourseUseCase = enrollCourseUseCase
    }
    
    func loadCourses() async {
        isLoading = true
        showError = false
        errorMessage = nil
        
        do {
            let fetchedCourses = try await fetchCoursesUseCase.execute()
            courses = fetchedCourses
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    func enrollInCourse(_ courseId: String) async {
        do {
            try await enrollCourseUseCase.execute(courseId: courseId)
            // Update the local course to show enrolled status
            if let index = courses.firstIndex(where: { $0.id == courseId }) {
                var updatedCourse = courses[index]
                // Create a new course with enrolled status
                // This is a simplified version - in real app, you'd have a proper copy method
                await loadCourses() // Reload to get updated data
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

// MARK: - Use Case Protocols

protocol FetchCoursesUseCaseProtocol {
    func execute() async throws -> [Course]
}

protocol EnrollCourseUseCaseProtocol {
    func execute(courseId: String) async throws
}

// MARK: - Mock Use Cases for Preview

struct MockFetchCoursesUseCase: FetchCoursesUseCaseProtocol {
    func execute() async throws -> [Course] {
        // Return mock courses
        return [
            Course(
                id: "1",
                title: "Основы управления персоналом",
                description: "Изучите ключевые принципы эффективного управления командой",
                imageURL: nil,
                duration: 120,
                level: .beginner,
                category: .management,
                instructor: Instructor(
                    id: "1",
                    name: "Иван Петров",
                    title: "HR Director",
                    bio: nil,
                    avatarURL: nil
                ),
                modules: [],
                competencies: ["Управление", "Коммуникация"],
                rating: 4.5,
                studentsCount: 150,
                price: 0,
                isEnrolled: true,
                progress: 0.65,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Course(
                id: "2",
                title: "Продажи B2B",
                description: "Освойте современные техники продаж корпоративным клиентам",
                imageURL: nil,
                duration: 180,
                level: .intermediate,
                category: .sales,
                instructor: Instructor(
                    id: "2",
                    name: "Елена Смирнова",
                    title: "Sales Director",
                    bio: nil,
                    avatarURL: nil
                ),
                modules: [],
                competencies: ["Продажи", "Переговоры"],
                rating: 4.8,
                studentsCount: 230,
                price: 0,
                isEnrolled: false,
                progress: 0,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
    }
}

struct MockEnrollCourseUseCase: EnrollCourseUseCaseProtocol {
    func execute(courseId: String) async throws {
        // Mock enrollment
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }
} 