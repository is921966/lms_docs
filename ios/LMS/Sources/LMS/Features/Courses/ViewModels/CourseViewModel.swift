import Foundation
import SwiftUI

// MARK: - Course Model
struct Course: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let instructor: String
    let category: Category
    let duration: Int // in minutes
    let lessonsCount: Int
    let enrolledCount: Int
    let rating: Double
    let imageURL: String?
    let price: Double
    let isEnrolled: Bool
    let progress: Double // 0.0 to 1.0
    let isFeatured: Bool
    let difficulty: Difficulty
    
    enum Category: String, CaseIterable {
        case development = "Development"
        case business = "Business"
        case design = "Design"
        case marketing = "Marketing"
        case personalDevelopment = "Personal Development"
        case photography = "Photography"
        case music = "Music"
        
        var icon: String {
            switch self {
            case .development: return "chevron.left.forwardslash.chevron.right"
            case .business: return "briefcase.fill"
            case .design: return "paintbrush.fill"
            case .marketing: return "megaphone.fill"
            case .personalDevelopment: return "person.fill.checkmark"
            case .photography: return "camera.fill"
            case .music: return "music.note"
            }
        }
        
        var color: Color {
            switch self {
            case .development: return .blue
            case .business: return .green
            case .design: return .purple
            case .marketing: return .orange
            case .personalDevelopment: return .pink
            case .photography: return .indigo
            case .music: return .red
            }
        }
    }
    
    enum Difficulty: String, CaseIterable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        
        var color: Color {
            switch self {
            case .beginner: return .green
            case .intermediate: return .orange
            case .advanced: return .red
            }
        }
    }
}

// MARK: - CourseViewModel
@MainActor
class CourseViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var courses: [Course] = []
    @Published var filteredCourses: [Course] = []
    @Published var featuredCourses: [Course] = []
    @Published var searchText = ""
    @Published var selectedCategory: Course.Category?
    @Published var selectedDifficulty: Course.Difficulty?
    @Published var showEnrolledOnly = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Sorting
    @Published var sortOption: SortOption = .relevance
    
    enum SortOption: String, CaseIterable {
        case relevance = "Relevance"
        case newest = "Newest"
        case rating = "Highest Rated"
        case popular = "Most Popular"
        case price = "Price"
    }
    
    // MARK: - Dependencies
    private let courseService: CourseServiceProtocol
    
    // MARK: - Initialization
    init(courseService: CourseServiceProtocol? = nil) {
        self.courseService = courseService ?? MockCourseService()
        setupFilters()
    }
    
    // MARK: - Methods
    func loadCourses() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Simulate network delay
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            courses = try await courseService.fetchCourses()
            featuredCourses = courses.filter { $0.isFeatured }
            applyFilters()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func enrollInCourse(_ course: Course) async {
        isLoading = true
        
        do {
            try await courseService.enroll(in: course.id)
            // Update local state
            if let index = courses.firstIndex(where: { $0.id == course.id }) {
                var updatedCourse = courses[index]
                // In real app, create a mutable copy
                // updatedCourse.isEnrolled = true
                courses[index] = updatedCourse
                applyFilters()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Private Methods
    private func setupFilters() {
        // Combine publishers for reactive filtering
        $searchText
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.applyFilters()
            }
            .store(in: &cancellables)
        
        $selectedCategory
            .sink { [weak self] _ in
                self?.applyFilters()
            }
            .store(in: &cancellables)
        
        $selectedDifficulty
            .sink { [weak self] _ in
                self?.applyFilters()
            }
            .store(in: &cancellables)
        
        $showEnrolledOnly
            .sink { [weak self] _ in
                self?.applyFilters()
            }
            .store(in: &cancellables)
        
        $sortOption
            .sink { [weak self] _ in
                self?.applyFilters()
            }
            .store(in: &cancellables)
    }
    
    private func applyFilters() {
        var filtered = courses
        
        // Search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { course in
                course.title.localizedCaseInsensitiveContains(searchText) ||
                course.description.localizedCaseInsensitiveContains(searchText) ||
                course.instructor.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Category filter
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Difficulty filter
        if let difficulty = selectedDifficulty {
            filtered = filtered.filter { $0.difficulty == difficulty }
        }
        
        // Enrolled filter
        if showEnrolledOnly {
            filtered = filtered.filter { $0.isEnrolled }
        }
        
        // Sorting
        switch sortOption {
        case .relevance:
            // Default order
            break
        case .newest:
            // In real app, sort by creation date
            filtered = filtered.reversed()
        case .rating:
            filtered = filtered.sorted { $0.rating > $1.rating }
        case .popular:
            filtered = filtered.sorted { $0.enrolledCount > $1.enrolledCount }
        case .price:
            filtered = filtered.sorted { $0.price < $1.price }
        }
        
        filteredCourses = filtered
    }
    
    private var cancellables = Set<AnyCancellable>()
}

// MARK: - Course Service Protocol
protocol CourseServiceProtocol {
    func fetchCourses() async throws -> [Course]
    func fetchCourse(id: UUID) async throws -> Course
    func enroll(in courseId: UUID) async throws
    func unenroll(from courseId: UUID) async throws
}

// MARK: - Mock Service
class MockCourseService: CourseServiceProtocol {
    private let mockCourses: [Course] = [
        Course(
            id: UUID(),
            title: "iOS Development with SwiftUI",
            description: "Learn to build beautiful iOS apps with SwiftUI",
            instructor: "John Doe",
            category: .development,
            duration: 1200,
            lessonsCount: 45,
            enrolledCount: 1234,
            rating: 4.8,
            imageURL: nil,
            price: 99.99,
            isEnrolled: true,
            progress: 0.65,
            isFeatured: true,
            difficulty: .intermediate
        ),
        Course(
            id: UUID(),
            title: "Business Strategy Fundamentals",
            description: "Master the basics of business strategy",
            instructor: "Jane Smith",
            category: .business,
            duration: 800,
            lessonsCount: 30,
            enrolledCount: 856,
            rating: 4.6,
            imageURL: nil,
            price: 79.99,
            isEnrolled: false,
            progress: 0.0,
            isFeatured: true,
            difficulty: .beginner
        ),
        Course(
            id: UUID(),
            title: "Advanced UI/UX Design",
            description: "Create stunning user interfaces",
            instructor: "Alex Johnson",
            category: .design,
            duration: 1500,
            lessonsCount: 60,
            enrolledCount: 2100,
            rating: 4.9,
            imageURL: nil,
            price: 149.99,
            isEnrolled: true,
            progress: 0.25,
            isFeatured: false,
            difficulty: .advanced
        ),
        Course(
            id: UUID(),
            title: "Digital Marketing Mastery",
            description: "Complete guide to digital marketing",
            instructor: "Sarah Wilson",
            category: .marketing,
            duration: 900,
            lessonsCount: 35,
            enrolledCount: 1567,
            rating: 4.7,
            imageURL: nil,
            price: 89.99,
            isEnrolled: false,
            progress: 0.0,
            isFeatured: true,
            difficulty: .intermediate
        )
    ]
    
    func fetchCourses() async throws -> [Course] {
        return mockCourses
    }
    
    func fetchCourse(id: UUID) async throws -> Course {
        guard let course = mockCourses.first(where: { $0.id == id }) else {
            throw CourseError.notFound
        }
        return course
    }
    
    func enroll(in courseId: UUID) async throws {
        // In real app, make API call
    }
    
    func unenroll(from courseId: UUID) async throws {
        // In real app, make API call
    }
}

enum CourseError: LocalizedError {
    case notFound
    case enrollmentFailed
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .notFound: return "Course not found"
        case .enrollmentFailed: return "Failed to enroll in course"
        case .unauthorized: return "You are not authorized to access this course"
        }
    }
}

// Add missing import
import Combine 