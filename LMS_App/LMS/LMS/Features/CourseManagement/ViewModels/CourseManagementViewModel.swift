import Foundation
import Combine

@MainActor
class CourseManagementViewModel: ObservableObject {
    @Published var courses: [ManagedCourse] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var searchText = ""
    @Published var successMessage: String?
    @Published var errorMessage: String?
    @Published var selectedCourseIds = Set<UUID>()
    @Published var isSelectionMode = false
    
    private let courseService: CourseServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(courseService: CourseServiceProtocol = CourseService()) {
        self.courseService = courseService
    }
    
    func loadCourses() {
        print("📚 CourseManagementViewModel: loadCourses() called")
        isLoading = true
        error = nil
        
        Task {
            do {
                print("📚 CourseManagementViewModel: Fetching courses...")
                let loadedCourses = try await courseService.fetchCourses()
                print("📚 CourseManagementViewModel: Loaded \(loadedCourses.count) courses")
                for (index, course) in loadedCourses.enumerated() {
                    print("   Course \(index + 1): \(course.title) (ID: \(course.id), Cmi5: \(course.cmi5PackageId != nil))")
                }
                self.courses = loadedCourses
                self.isLoading = false
            } catch {
                print("📚 CourseManagementViewModel: Error loading courses: \(error)")
                self.error = error
                self.isLoading = false
            }
        }
    }
    
    func filteredCourses(searchText: String) -> [ManagedCourse] {
        if searchText.isEmpty {
            return courses
        }
        
        return courses.filter { course in
            course.title.localizedCaseInsensitiveContains(searchText) ||
            course.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func createCourse(title: String, description: String, duration: Int) async throws -> ManagedCourse {
        let newCourse = ManagedCourse(
            title: title,
            description: description,
            duration: duration
        )
        
        do {
            let createdCourse = try await courseService.createCourse(newCourse)
            self.courses.append(createdCourse)
            return createdCourse
        } catch {
            self.error = error
            throw error
        }
    }
    
    func updateCourse(_ course: ManagedCourse) async throws -> ManagedCourse {
        do {
            let updatedCourse = try await courseService.updateCourse(course)
            if let index = courses.firstIndex(where: { $0.id == updatedCourse.id }) {
                self.courses[index] = updatedCourse
            }
            return updatedCourse
        } catch {
            self.error = error
            throw error
        }
    }
    
    func deleteCourse(id: UUID) {
        Task {
            do {
                try await courseService.deleteCourse(id: id)
                self.courses.removeAll { $0.id == id }
            } catch {
                self.error = error
            }
        }
    }
    
    func deleteCourses(ids: [UUID]) {
        Task {
            do {
                for id in ids {
                    try await courseService.deleteCourse(id: id)
                }
                self.courses.removeAll { ids.contains($0.id) }
            } catch {
                self.error = error
            }
        }
    }
    
    func archiveCourses(ids: [UUID]) {
        Task {
            do {
                for id in ids {
                    if let course = courses.first(where: { $0.id == id }) {
                        var updatedCourse = course
                        updatedCourse.status = .archived
                        let result = try await courseService.updateCourse(updatedCourse)
                        if let index = courses.firstIndex(where: { $0.id == result.id }) {
                            self.courses[index] = result
                        }
                    }
                }
            } catch {
                self.error = error
            }
        }
    }
    
    func duplicateCourse(_ id: UUID) async throws {
        do {
            let duplicatedCourse = try await courseService.duplicateCourse(id)
            self.courses.append(duplicatedCourse)
            self.successMessage = "Курс '\(duplicatedCourse.title)' успешно дублирован"
        } catch {
            self.error = error
            self.errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func assignCourseToUsers(courseId: UUID, userIds: [UUID]) {
        Task {
            do {
                try await courseService.assignCourseToUsers(courseId: courseId, userIds: userIds)
            } catch {
                self.error = error
            }
        }
    }
    
    // MARK: - Computed Properties
    
    var isBulkOperationAvailable: Bool {
        !selectedCourseIds.isEmpty
    }
    
    var selectionCount: Int {
        selectedCourseIds.count
    }
    
    // MARK: - Selection Methods
    
    func toggleSelectionMode() {
        isSelectionMode.toggle()
        if !isSelectionMode {
            deselectAllCourses()
        }
    }
    
    func toggleCourseSelection(_ id: UUID) {
        if selectedCourseIds.contains(id) {
            selectedCourseIds.remove(id)
        } else {
            selectedCourseIds.insert(id)
        }
    }
    
    func selectAllCourses() {
        selectedCourseIds = Set(courses.map { $0.id })
    }
    
    func deselectAllCourses() {
        selectedCourseIds.removeAll()
    }
    
    // MARK: - Bulk Operations
    
    func bulkDeleteSelectedCourses() async throws {
        guard !selectedCourseIds.isEmpty else {
            throw BulkOperationError.noSelection
        }
        
        for courseId in selectedCourseIds {
            try await courseService.deleteCourse(id: courseId)
            courses.removeAll { $0.id == courseId }
        }
        
        successMessage = "Удалено курсов: \(selectedCourseIds.count)"
        deselectAllCourses()
    }
    
    func bulkArchiveSelectedCourses() async throws {
        guard !selectedCourseIds.isEmpty else {
            throw BulkOperationError.noSelection
        }
        
        for courseId in selectedCourseIds {
            if let index = courses.firstIndex(where: { $0.id == courseId }) {
                var course = courses[index]
                course.status = .archived
                let updated = try await courseService.updateCourse(course)
                courses[index] = updated
            }
        }
        
        successMessage = "Архивировано курсов: \(selectedCourseIds.count)"
        deselectAllCourses()
    }
    
    func bulkPublishSelectedCourses() async throws {
        guard !selectedCourseIds.isEmpty else {
            throw BulkOperationError.noSelection
        }
        
        for courseId in selectedCourseIds {
            if let index = courses.firstIndex(where: { $0.id == courseId }) {
                var course = courses[index]
                if course.status == .draft {
                    course.status = .published
                    let updated = try await courseService.updateCourse(course)
                    courses[index] = updated
                }
            }
        }
        
        successMessage = "Опубликовано курсов: \(selectedCourseIds.count)"
        deselectAllCourses()
    }
    
    func bulkAssignSelectedCoursesToStudents(_ studentIds: [UUID]) async throws {
        guard !selectedCourseIds.isEmpty else {
            throw BulkOperationError.noSelection
        }
        
        for courseId in selectedCourseIds {
            try await courseService.assignCourseToUsers(courseId: courseId, userIds: studentIds)
        }
        
        successMessage = "\(selectedCourseIds.count) курсов назначено \(studentIds.count) студентам"
        deselectAllCourses()
    }
}

// MARK: - Errors

enum BulkOperationError: LocalizedError {
    case noSelection
    
    var errorDescription: String? {
        switch self {
        case .noSelection:
            return "Выберите курсы для удаления"
        }
    }
} 