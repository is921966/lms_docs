//
//  CourseViewModel.swift
//  LMS
//
//  Created on 19/01/2025.
//

import Foundation
import Combine

class CourseViewModel: ObservableObject {
    @Published var courses: [Course] = []
    @Published var userProgress: [CourseProgress] = []
    @Published var filteredCourses: [Course] = []
    @Published var searchText = ""
    @Published var selectedCategory: String = "Все"
    @Published var selectedLevel: CourseLevel?
    @Published var selectedFormat: CourseFormat?
    @Published var showOnlyEnrolled = false
    @Published var sortOption: SortOption = .popular
    
    private var cancellables = Set<AnyCancellable>()
    private let courseService: CourseMockService
    
    enum SortOption: String, CaseIterable {
        case popular = "Популярные"
        case newest = "Новые"
        case rating = "По рейтингу"
        case duration = "По длительности"
    }
    
    init(courseService: CourseMockService = CourseMockService()) {
        self.courseService = courseService
        setupBindings()
        loadData()
    }
    
    private func setupBindings() {
        // Подписываемся на изменения в сервисе
        courseService.$courses
            .assign(to: &$courses)
        
        courseService.$userProgress
            .assign(to: &$userProgress)
        
        // Фильтрация курсов
        Publishers.CombineLatest4($searchText, $selectedCategory, $selectedLevel, $selectedFormat)
            .combineLatest($showOnlyEnrolled, $sortOption, $courses, $userProgress)
            .map { (filters, showEnrolled, sort, courses, progress) in
                let (search, category, level, format) = filters
                
                var filtered = courses
                
                // Поиск
                if !search.isEmpty {
                    filtered = filtered.filter { course in
                        course.title.localizedCaseInsensitiveContains(search) ||
                        course.description.localizedCaseInsensitiveContains(search) ||
                        course.tags.contains { $0.localizedCaseInsensitiveContains(search) }
                    }
                }
                
                // Категория
                if category != "Все" {
                    filtered = filtered.filter { $0.category == category }
                }
                
                // Уровень
                if let level = level {
                    filtered = filtered.filter { $0.level == level }
                }
                
                // Формат
                if let format = format {
                    filtered = filtered.filter { $0.format == format }
                }
                
                // Только записанные курсы
                if showEnrolled {
                    let enrolledIds = progress.map { $0.courseId }
                    filtered = filtered.filter { enrolledIds.contains($0.id.uuidString) }
                }
                
                // Сортировка
                switch sort {
                case .popular:
                    filtered.sort { $0.enrolledCount > $1.enrolledCount }
                case .newest:
                    filtered.sort { $0.publishedAt ?? Date() > $1.publishedAt ?? Date() }
                case .rating:
                    filtered.sort { $0.averageRating > $1.averageRating }
                case .duration:
                    filtered.sort { $0.duration < $1.duration }
                }
                
                return filtered
            }
            .assign(to: &$filteredCourses)
    }
    
    private func loadData() {
        // Данные загружаются автоматически при инициализации сервиса
    }
    
    // MARK: - Computed Properties
    
    var categories: [String] {
        let allCategories = courses.map { $0.category }
        let uniqueCategories = Array(Set(allCategories)).sorted()
        return ["Все"] + uniqueCategories
    }
    
    var totalCourses: Int {
        courses.count
    }
    
    var enrolledCoursesCount: Int {
        userProgress.count
    }
    
    var completedCoursesCount: Int {
        userProgress.filter { $0.status == .completed }.count
    }
    
    var totalLearningTime: Int {
        userProgress.reduce(0) { $0 + $1.totalTimeSpent }
    }
    
    var formattedTotalTime: String {
        let hours = totalLearningTime / 60
        let minutes = totalLearningTime % 60
        if hours > 0 {
            return "\(hours)ч \(minutes)м"
        } else {
            return "\(minutes)м"
        }
    }
    
    // MARK: - Course Actions
    
    func enrollInCourse(_ course: Course) {
        courseService.enrollInCourse(course.id.uuidString)
    }
    
    func isEnrolled(_ course: Course) -> Bool {
        courseService.isEnrolled(course.id.uuidString)
    }
    
    func getProgress(for course: Course) -> CourseProgress? {
        courseService.getProgress(for: course.id.uuidString)
    }
    
    func getEnrollmentStatus(for course: Course) -> EnrollmentStatus? {
        getProgress(for: course)?.status
    }
    
    func getProgressPercentage(for course: Course) -> Int {
        getProgress(for: course)?.progressPercentage ?? 0
    }
    
    // MARK: - Recommendations
    
    func getRecommendedCourses(for userId: String, limit: Int = 3) -> [Course] {
        // Простая логика рекомендаций на основе незаписанных курсов
        let enrolledIds = userProgress.map { $0.courseId }
        let notEnrolled = courses.filter { !enrolledIds.contains($0.id.uuidString) && $0.status == .published }
        
        // Сортируем по рейтингу и популярности
        return Array(notEnrolled.sorted {
            ($0.averageRating * Double($0.enrolledCount)) > ($1.averageRating * Double($1.enrolledCount))
        }.prefix(limit))
    }
    
    func getCoursesByCompetency(_ competencyId: String) -> [Course] {
        courses.filter { course in
            course.targetCompetencies.contains { $0.competencyId == competencyId }
        }
    }
    
    func getRequiredCoursesForPosition(_ positionId: String) -> [Course] {
        courses.filter { course in
            course.isRequired && course.requiredForPositions.contains(positionId)
        }
    }
} 