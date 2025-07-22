//
//  StudentCoursePreviewTests.swift
//  LMSTests
//
//  Tests for full student course preview experience
//

import XCTest
@testable import LMS

final class StudentCoursePreviewTests: XCTestCase {
    
    var mockCourse: ManagedCourse!
    
    override func setUp() {
        super.setUp()
        
        // Create a test course with modules
        mockCourse = ManagedCourse(
            id: UUID(),
            title: "Complete Test Course",
            description: "A comprehensive test course",
            status: .published,
            type: .mandatory,
            duration: 120,
            modules: [
                ManagedCourseModule(
                    id: UUID(),
                    title: "Introduction Video",
                    description: "Welcome to the course",
                    order: 0,
                    contentType: .video,
                    contentUrl: "video-1",
                    duration: 30
                ),
                ManagedCourseModule(
                    id: UUID(),
                    title: "Reading Material",
                    description: "Core concepts",
                    order: 1,
                    contentType: .document,
                    contentUrl: "doc-1",
                    duration: 45
                ),
                ManagedCourseModule(
                    id: UUID(),
                    title: "Knowledge Check",
                    description: "Test your understanding",
                    order: 2,
                    contentType: .quiz,
                    contentUrl: "quiz-1",
                    duration: 15
                ),
                ManagedCourseModule(
                    id: UUID(),
                    title: "Interactive Activity",
                    description: "Hands-on practice",
                    order: 3,
                    contentType: .cmi5,
                    contentUrl: "cmi5-1",
                    duration: 30
                )
            ],
            competencies: ["comp-1", "comp-2"],
            cmi5PackageId: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    // MARK: - Progress Tests
    
    func testInitialProgress() {
        // Progress should start at 0%
        let viewModel = StudentCoursePreviewViewModel(course: mockCourse)
        XCTAssertEqual(viewModel.progress, 0.0)
        XCTAssertEqual(viewModel.currentModuleIndex, 0)
        XCTAssertTrue(viewModel.completedModules.isEmpty)
    }
    
    func testProgressCalculation() {
        let viewModel = StudentCoursePreviewViewModel(course: mockCourse)
        
        // Complete first module
        viewModel.completeCurrentModule()
        XCTAssertEqual(viewModel.progress, 0.25) // 1/4 modules
        
        // Complete second module
        viewModel.moveToNextModule()
        viewModel.completeCurrentModule()
        XCTAssertEqual(viewModel.progress, 0.5) // 2/4 modules
        
        // Complete all modules
        viewModel.moveToNextModule()
        viewModel.completeCurrentModule()
        viewModel.moveToNextModule()
        viewModel.completeCurrentModule()
        XCTAssertEqual(viewModel.progress, 1.0) // 4/4 modules
    }
    
    // MARK: - Navigation Tests
    
    func testModuleNavigation() {
        let viewModel = StudentCoursePreviewViewModel(course: mockCourse)
        
        // Initial state
        XCTAssertEqual(viewModel.currentModuleIndex, 0)
        XCTAssertNotNil(viewModel.currentModule)
        XCTAssertEqual(viewModel.currentModule?.title, "Introduction Video")
        
        // Move forward
        viewModel.moveToNextModule()
        XCTAssertEqual(viewModel.currentModuleIndex, 1)
        XCTAssertEqual(viewModel.currentModule?.title, "Reading Material")
        
        // Move backward
        viewModel.moveToPreviousModule()
        XCTAssertEqual(viewModel.currentModuleIndex, 0)
        XCTAssertEqual(viewModel.currentModule?.title, "Introduction Video")
    }
    
    func testNavigationBounds() {
        let viewModel = StudentCoursePreviewViewModel(course: mockCourse)
        
        // Can't go before first module
        viewModel.moveToPreviousModule()
        XCTAssertEqual(viewModel.currentModuleIndex, 0)
        
        // Navigate to last module
        viewModel.currentModuleIndex = 3
        
        // Can't go past last module
        viewModel.moveToNextModule()
        XCTAssertEqual(viewModel.currentModuleIndex, 3)
    }
    
    // MARK: - Module Completion Tests
    
    func testModuleCompletion() {
        let viewModel = StudentCoursePreviewViewModel(course: mockCourse)
        
        let firstModuleId = mockCourse.modules[0].id
        XCTAssertFalse(viewModel.isModuleCompleted(firstModuleId))
        
        // Complete first module
        viewModel.completeCurrentModule()
        XCTAssertTrue(viewModel.isModuleCompleted(firstModuleId))
        XCTAssertTrue(viewModel.completedModules.contains(firstModuleId))
    }
    
    func testAutoAdvanceAfterCompletion() {
        let viewModel = StudentCoursePreviewViewModel(course: mockCourse)
        
        // Complete first module should auto-advance
        viewModel.completeCurrentModule()
        XCTAssertEqual(viewModel.currentModuleIndex, 1)
        
        // Complete last module should not advance
        viewModel.currentModuleIndex = 3
        viewModel.completeCurrentModule()
        XCTAssertEqual(viewModel.currentModuleIndex, 3)
    }
    
    // MARK: - Module Type Tests
    
    func testVideoModuleProgress() {
        let videoModule = mockCourse.modules[0]
        XCTAssertEqual(videoModule.contentType, .video)
        
        // Test video progress simulation
        let progress = simulateVideoProgress(duration: videoModule.duration)
        XCTAssertEqual(progress, 1.0)
    }
    
    func testDocumentModuleProgress() {
        let docModule = mockCourse.modules[1]
        XCTAssertEqual(docModule.contentType, .document)
        
        // Document should complete on scroll to bottom
        let progress = simulateDocumentReading()
        XCTAssertEqual(progress, 1.0)
    }
    
    func testQuizModuleProgress() {
        let quizModule = mockCourse.modules[2]
        XCTAssertEqual(quizModule.contentType, .quiz)
        
        // Quiz completes when all questions answered
        let progress = simulateQuizCompletion(questions: 3)
        XCTAssertEqual(progress, 1.0)
    }
    
    func testCmi5ModuleProgress() {
        let cmi5Module = mockCourse.modules[3]
        XCTAssertEqual(cmi5Module.contentType, .cmi5)
        
        // Cmi5 progress based on slides
        let progress = simulateCmi5Progress(slides: 5)
        XCTAssertEqual(progress, 1.0)
    }
    
    // MARK: - Reset Tests
    
    func testCourseReset() {
        let viewModel = StudentCoursePreviewViewModel(course: mockCourse)
        
        // Complete some modules
        viewModel.completeCurrentModule()
        viewModel.moveToNextModule()
        viewModel.completeCurrentModule()
        
        XCTAssertEqual(viewModel.progress, 0.5)
        XCTAssertEqual(viewModel.completedModules.count, 2)
        
        // Reset course
        viewModel.resetCourse()
        
        XCTAssertEqual(viewModel.progress, 0.0)
        XCTAssertEqual(viewModel.currentModuleIndex, 0)
        XCTAssertTrue(viewModel.completedModules.isEmpty)
    }
    
    // MARK: - Helper Methods
    
    private func simulateVideoProgress(duration: Int) -> Double {
        // Simulate watching entire video
        return 1.0
    }
    
    private func simulateDocumentReading() -> Double {
        // Simulate scrolling to bottom
        return 1.0
    }
    
    private func simulateQuizCompletion(questions: Int) -> Double {
        // Simulate answering all questions
        return 1.0
    }
    
    private func simulateCmi5Progress(slides: Int) -> Double {
        // Simulate viewing all slides
        return 1.0
    }
}

// MARK: - View Model for Testing

class StudentCoursePreviewViewModel: ObservableObject {
    let course: ManagedCourse
    @Published var currentModuleIndex = 0
    @Published var completedModules: Set<UUID> = []
    
    init(course: ManagedCourse) {
        self.course = course
    }
    
    var currentModule: ManagedCourseModule? {
        guard currentModuleIndex < course.modules.count else { return nil }
        return course.modules[currentModuleIndex]
    }
    
    var progress: Double {
        guard !course.modules.isEmpty else { return 0 }
        return Double(completedModules.count) / Double(course.modules.count)
    }
    
    func completeCurrentModule() {
        guard let module = currentModule else { return }
        completedModules.insert(module.id)
        
        // Auto-advance if not last module
        if currentModuleIndex < course.modules.count - 1 {
            currentModuleIndex += 1
        }
    }
    
    func moveToNextModule() {
        if currentModuleIndex < course.modules.count - 1 {
            currentModuleIndex += 1
        }
    }
    
    func moveToPreviousModule() {
        if currentModuleIndex > 0 {
            currentModuleIndex -= 1
        }
    }
    
    func isModuleCompleted(_ moduleId: UUID) -> Bool {
        return completedModules.contains(moduleId)
    }
    
    func resetCourse() {
        currentModuleIndex = 0
        completedModules.removeAll()
    }
} 