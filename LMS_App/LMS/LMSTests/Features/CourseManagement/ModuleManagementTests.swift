//
//  ModuleManagementTests.swift
//  LMSTests
//
//  Testing module management functionality
//

import XCTest
@testable import LMS

final class ModuleManagementTests: XCTestCase {
    
    var sut: ModuleManagementViewModel!
    var mockModules: [ManagedCourseModule]!
    
    override func setUp() {
        super.setUp()
        mockModules = []
        sut = ModuleManagementViewModel(modules: mockModules)
    }
    
    override func tearDown() {
        sut = nil
        mockModules = nil
        super.tearDown()
    }
    
    // MARK: - Adding Modules
    
    func test_addModule_shouldAddNewModuleToList() {
        // Given
        let newModule = ManagedCourseModule(
            id: UUID(),
            title: "Test Module",
            description: "Test Description",
            order: 1,
            contentType: .video,
            contentUrl: nil,
            duration: 30
        )
        
        // When
        sut.addModule(newModule)
        
        // Then
        XCTAssertEqual(sut.modules.count, 1)
        XCTAssertEqual(sut.modules.first?.title, "Test Module")
    }
    
    func test_addModule_shouldAssignCorrectOrder() {
        // Given
        let module1 = createModule(title: "Module 1")
        let module2 = createModule(title: "Module 2")
        
        // When
        sut.addModule(module1)
        sut.addModule(module2)
        
        // Then
        XCTAssertEqual(sut.modules[0].order, 1)
        XCTAssertEqual(sut.modules[1].order, 2)
    }
    
    // MARK: - Editing Modules
    
    func test_updateModule_shouldUpdateExistingModule() {
        // Given
        let module = createModule(title: "Original")
        sut.addModule(module)
        
        var updatedModule = module
        updatedModule.title = "Updated"
        updatedModule.duration = 60
        
        // When
        sut.updateModule(updatedModule)
        
        // Then
        XCTAssertEqual(sut.modules.first?.title, "Updated")
        XCTAssertEqual(sut.modules.first?.duration, 60)
    }
    
    func test_updateModule_withNonExistentId_shouldNotCrash() {
        // Given
        let module = createModule(title: "Test")
        sut.addModule(module)
        
        let nonExistentModule = createModule(title: "Non-existent")
        
        // When
        sut.updateModule(nonExistentModule)
        
        // Then
        XCTAssertEqual(sut.modules.count, 1)
        XCTAssertEqual(sut.modules.first?.title, "Test")
    }
    
    // MARK: - Deleting Modules
    
    func test_deleteModule_shouldRemoveFromList() {
        // Given
        let module1 = createModule(title: "Module 1")
        let module2 = createModule(title: "Module 2")
        sut.addModule(module1)
        sut.addModule(module2)
        
        // When
        sut.deleteModule(module1)
        
        // Then
        XCTAssertEqual(sut.modules.count, 1)
        XCTAssertEqual(sut.modules.first?.title, "Module 2")
    }
    
    func test_deleteModule_shouldReorderRemainingModules() {
        // Given
        let module1 = createModule(title: "Module 1")
        let module2 = createModule(title: "Module 2")
        let module3 = createModule(title: "Module 3")
        sut.addModule(module1)
        sut.addModule(module2)
        sut.addModule(module3)
        
        // When
        sut.deleteModule(module2)
        
        // Then
        XCTAssertEqual(sut.modules[0].order, 1)
        XCTAssertEqual(sut.modules[1].order, 2)
    }
    
    // MARK: - Reordering Modules
    
    func test_moveModule_shouldChangeOrder() {
        // Given
        let module1 = createModule(title: "Module 1")
        let module2 = createModule(title: "Module 2")
        let module3 = createModule(title: "Module 3")
        sut.addModule(module1)
        sut.addModule(module2)
        sut.addModule(module3)
        
        // When
        sut.moveModule(from: IndexSet(integer: 0), to: 3)
        
        // Then
        XCTAssertEqual(sut.modules[0].title, "Module 2")
        XCTAssertEqual(sut.modules[1].title, "Module 3")
        XCTAssertEqual(sut.modules[2].title, "Module 1")
        
        // Check order numbers
        XCTAssertEqual(sut.modules[0].order, 1)
        XCTAssertEqual(sut.modules[1].order, 2)
        XCTAssertEqual(sut.modules[2].order, 3)
    }
    
    // MARK: - Content Type Validation
    
    func test_contentType_shouldHaveCorrectProperties() {
        // Given
        let videoModule = createModule(contentType: .video)
        let documentModule = createModule(contentType: .document)
        let quizModule = createModule(contentType: .quiz)
        let cmi5Module = createModule(contentType: .cmi5)
        
        // Then
        XCTAssertEqual(videoModule.contentType.icon, "play.circle.fill")
        XCTAssertEqual(documentModule.contentType.icon, "doc.text.fill")
        XCTAssertEqual(quizModule.contentType.icon, "questionmark.circle.fill")
        XCTAssertEqual(cmi5Module.contentType.icon, "cube.box.fill")
        
        XCTAssertEqual(videoModule.contentType.color, .red)
        XCTAssertEqual(documentModule.contentType.color, .blue)
        XCTAssertEqual(quizModule.contentType.color, .orange)
        XCTAssertEqual(cmi5Module.contentType.color, .purple)
    }
    
    // MARK: - Module Validation
    
    func test_validateModule_withEmptyTitle_shouldReturnError() {
        // Given
        let module = ManagedCourseModule(
            id: UUID(),
            title: "",
            description: "Description",
            order: 1,
            contentType: .video,
            contentUrl: nil,
            duration: 30
        )
        
        // When
        let validationResult = sut.validateModule(module)
        
        // Then
        XCTAssertFalse(validationResult.isValid)
        XCTAssertEqual(validationResult.error, "Название модуля не может быть пустым")
    }
    
    func test_validateModule_withInvalidDuration_shouldReturnError() {
        // Given
        let module = ManagedCourseModule(
            id: UUID(),
            title: "Test",
            description: "Description",
            order: 1,
            contentType: .video,
            contentUrl: nil,
            duration: 0
        )
        
        // When
        let validationResult = sut.validateModule(module)
        
        // Then
        XCTAssertFalse(validationResult.isValid)
        XCTAssertEqual(validationResult.error, "Длительность должна быть больше 0")
    }
    
    func test_validateModule_withValidData_shouldReturnSuccess() {
        // Given
        let module = createModule()
        
        // When
        let validationResult = sut.validateModule(module)
        
        // Then
        XCTAssertTrue(validationResult.isValid)
        XCTAssertNil(validationResult.error)
    }
    
    // MARK: - Helpers
    
    private func createModule(
        title: String = "Test Module",
        description: String = "Test Description",
        contentType: ManagedCourseModule.ContentType = .video,
        duration: Int = 30
    ) -> ManagedCourseModule {
        return ManagedCourseModule(
            id: UUID(),
            title: title,
            description: description,
            order: 1,
            contentType: contentType,
            contentUrl: nil,
            duration: duration
        )
    }
}

// MARK: - View Tests

final class ModuleManagementViewTests: XCTestCase {
    
    func test_emptyState_shouldShowWhenNoModules() {
        // Given
        let modules: [ManagedCourseModule] = []
        
        // When
        let view = ModuleManagementView(modules: .constant(modules))
        
        // Then
        // This would be tested with UI testing
        // Verify empty state is shown
    }
    
    func test_moduleList_shouldShowWhenModulesExist() {
        // Given
        let modules = [
            ManagedCourseModule(
                id: UUID(),
                title: "Module 1",
                description: "Description 1",
                order: 1,
                contentType: .video,
                contentUrl: nil,
                duration: 30
            )
        ]
        
        // When
        let view = ModuleManagementView(modules: .constant(modules))
        
        // Then
        // This would be tested with UI testing
        // Verify module list is shown
    }
} 