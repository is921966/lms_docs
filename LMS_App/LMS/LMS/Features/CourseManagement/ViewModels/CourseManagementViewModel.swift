import Foundation
import Combine

@MainActor
class CourseManagementViewModel: ObservableObject {
    @Published var courses: [ManagedCourse] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let courseService: CourseServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(courseService: CourseServiceProtocol = CourseService()) {
        self.courseService = courseService
    }
    
    func loadCourses() {
        isLoading = true
        error = nil
        
        Task {
            do {
                let loadedCourses = try await courseService.fetchCourses()
                self.courses = loadedCourses
                self.isLoading = false
            } catch {
                self.error = error.localizedDescription
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
    
    func createCourse(_ course: ManagedCourse) {
        Task {
            do {
                let newCourse = try await courseService.createCourse(course)
                self.courses.append(newCourse)
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
    
    func updateCourse(_ course: ManagedCourse) {
        Task {
            do {
                let updatedCourse = try await courseService.updateCourse(course)
                if let index = courses.firstIndex(where: { $0.id == updatedCourse.id }) {
                    self.courses[index] = updatedCourse
                }
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
    
    func deleteCourse(id: UUID) {
        Task {
            do {
                try await courseService.deleteCourse(id: id)
                self.courses.removeAll { $0.id == id }
            } catch {
                self.error = error.localizedDescription
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
                self.error = error.localizedDescription
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
                self.error = error.localizedDescription
            }
        }
    }
    
    func assignCourseToUsers(courseId: UUID, userIds: [UUID]) {
        Task {
            do {
                try await courseService.assignCourseToUsers(courseId: courseId, userIds: userIds)
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
} 