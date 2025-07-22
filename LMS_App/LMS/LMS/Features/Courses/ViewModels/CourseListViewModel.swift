import Foundation
import Combine

class CourseListViewModel: ObservableObject {
    @Published var courses: [Course] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadCourses()
    }
    
    func loadCourses() {
        isLoading = true
        // Simulate loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.courses = Course.mockCourses
            self?.isLoading = false
        }
    }
    
    func refresh() {
        loadCourses()
    }
} 