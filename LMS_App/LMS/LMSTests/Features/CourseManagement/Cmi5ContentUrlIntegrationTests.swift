import XCTest
@testable import LMS

/// Integration tests for Cmi5 contentUrl and module loading
final class Cmi5ContentUrlIntegrationTests: XCTestCase {
    
    var cmi5Service: Cmi5Service!
    var courseService: CourseService!
    var converter: Cmi5CourseConverter!
    
    override func setUp() {
        super.setUp()
        cmi5Service = Cmi5Service()
        courseService = CourseService()
        converter = Cmi5CourseConverter()
    }
    
    override func tearDown() {
        cmi5Service = nil
        courseService = nil
        converter = nil
        super.tearDown()
    }
    
    // MARK: - ContentUrl Population Tests
    
    func test_cmi5Converter_shouldPopulateContentUrl_forBlockActivities() {
        // Arrange
        let packageId = UUID()
        let activityId = "activity-123"
        
        let activity = Cmi5Activity(
            id: UUID(),
            packageId: packageId,
            activityId: activityId,
            title: "Test Activity",
            description: "Test Description",
            launchUrl: "content/index.html",
            launchMethod: .ownWindow,
            moveOn: .completedOrPassed,
            masteryScore: 0.8,
            activityType: "http://adlnet.gov/expapi/activities/lesson",
            duration: nil
        )
        
        let block = Cmi5Block(
            id: "block-1",
            title: [Cmi5LangString(lang: "en", value: "Test Block")],
            description: nil,
            objectives: [],
            activities: [activity],
            blocks: []
        )
        
        let course = Cmi5Course(
            id: "course-1",
            title: [Cmi5LangString(lang: "en", value: "Test Course")],
            description: nil
        )
        
        let manifest = Cmi5Manifest(course: course, rootBlock: block)
        let package = Cmi5Package(
            id: packageId,
            manifest: manifest,
            archivePath: URL(fileURLWithPath: "/tmp/test.zip"),
            extractedPath: URL(fileURLWithPath: "/tmp/test"),
            fileSize: 1024
        )
        
        // Act
        let managedCourse = converter.convertToManagedCourse(package: package)
        
        // Assert
        XCTAssertEqual(managedCourse.modules.count, 1)
        
        let module = managedCourse.modules.first!
        XCTAssertNotNil(module.contentUrl)
        XCTAssertEqual(module.contentUrl, activityId)
        XCTAssertEqual(module.contentType, .cmi5)
    }
    
    func test_cmi5Converter_shouldHandleNestedBlocks() {
        // Arrange
        let packageId = UUID()
        let activity1Id = "activity-1"
        let activity2Id = "activity-2"
        
        let activity1 = createActivity(id: activity1Id, packageId: packageId, title: "Activity 1")
        let activity2 = createActivity(id: activity2Id, packageId: packageId, title: "Activity 2")
        
        let childBlock = Cmi5Block(
            id: "child-block",
            title: [Cmi5LangString(lang: "en", value: "Child Block")],
            description: nil,
            objectives: [],
            activities: [activity2],
            blocks: []
        )
        
        let rootBlock = Cmi5Block(
            id: "root-block",
            title: [Cmi5LangString(lang: "en", value: "Root Block")],
            description: nil,
            objectives: [],
            activities: [activity1],
            blocks: [childBlock]
        )
        
        let package = createPackage(id: packageId, rootBlock: rootBlock)
        
        // Act
        let managedCourse = converter.convertToManagedCourse(package: package)
        
        // Assert
        XCTAssertEqual(managedCourse.modules.count, 2)
        
        let module1 = managedCourse.modules[0]
        XCTAssertEqual(module1.contentUrl, activity1Id)
        XCTAssertEqual(module1.title, "Test Block")
        
        let module2 = managedCourse.modules[1]
        XCTAssertEqual(module2.contentUrl, activity2Id)
        XCTAssertEqual(module2.title, "Child Block")
    }
    
    func test_cmi5Converter_shouldHandleEmptyBlocks() {
        // Arrange
        let packageId = UUID()
        
        let emptyBlock = Cmi5Block(
            id: "empty-block",
            title: [Cmi5LangString(lang: "en", value: "Empty Block")],
            description: nil,
            objectives: [],
            activities: [],
            blocks: []
        )
        
        let package = createPackage(id: packageId, rootBlock: emptyBlock)
        
        // Act
        let managedCourse = converter.convertToManagedCourse(package: package)
        
        // Assert
        XCTAssertEqual(managedCourse.modules.count, 0)
    }
    
    // MARK: - Module Preview Tests
    
    func test_modulePreview_shouldFindActivity_withContentUrl() {
        // Arrange
        let packageId = UUID()
        let activityId = "test-activity-123"
        
        let activity = createActivity(id: activityId, packageId: packageId, title: "Test Activity")
        let block = Cmi5Block(
            id: "block-1",
            title: [Cmi5LangString(lang: "en", value: "Test Block")],
            description: nil,
            objectives: [],
            activities: [activity],
            blocks: []
        )
        
        let package = createPackage(id: packageId, rootBlock: block)
        
        // Simulate package loaded in service
        cmi5Service.packages.append(package)
        
        // Create module with contentUrl
        let module = ManagedCourseModule(
            id: UUID(),
            title: "Test Module",
            description: "Test Description",
            order: 0,
            contentType: .cmi5,
            contentUrl: activityId,
            duration: 30
        )
        
        // Act - Simulate what ModuleContentPreviews does
        let foundActivity = findActivity(
            contentUrl: module.contentUrl,
            packageId: packageId,
            in: cmi5Service.packages
        )
        
        // Assert
        XCTAssertNotNil(foundActivity)
        XCTAssertEqual(foundActivity?.activityId, activityId)
        XCTAssertEqual(foundActivity?.title, "Test Activity")
    }
    
    func test_modulePreview_shouldFallbackToFirstActivity_whenContentUrlNil() {
        // Arrange
        let packageId = UUID()
        let activityId = "fallback-activity"
        
        let activity = createActivity(id: activityId, packageId: packageId, title: "Fallback Activity")
        let block = Cmi5Block(
            id: "block-1",
            title: [Cmi5LangString(lang: "en", value: "Test Block")],
            description: nil,
            objectives: [],
            activities: [activity],
            blocks: []
        )
        
        let package = createPackage(id: packageId, rootBlock: block)
        cmi5Service.packages.append(package)
        
        // Create module WITHOUT contentUrl
        let module = ManagedCourseModule(
            id: UUID(),
            title: "Test Module",
            description: "Test Description",
            order: 0,
            contentType: .cmi5,
            contentUrl: nil, // This is the problem case
            duration: 30
        )
        
        // Act - Simulate fallback logic
        let foundActivity = findActivityWithFallback(
            module: module,
            packageId: packageId,
            in: cmi5Service.packages
        )
        
        // Assert
        XCTAssertNotNil(foundActivity)
        XCTAssertEqual(foundActivity?.activityId, activityId)
    }
    
    // MARK: - Helper Methods
    
    private func createActivity(id: String, packageId: UUID, title: String) -> Cmi5Activity {
        return Cmi5Activity(
            id: UUID(),
            packageId: packageId,
            activityId: id,
            title: title,
            description: nil,
            launchUrl: "content/\(id)/index.html",
            launchMethod: .ownWindow,
            moveOn: .completedOrPassed,
            masteryScore: 0.8,
            activityType: "http://adlnet.gov/expapi/activities/lesson",
            duration: nil
        )
    }
    
    private func createPackage(id: UUID, rootBlock: Cmi5Block?) -> Cmi5Package {
        let course = Cmi5Course(
            id: "course-1",
            title: [Cmi5LangString(lang: "en", value: "Test Course")],
            description: nil
        )
        
        let manifest = Cmi5Manifest(course: course, rootBlock: rootBlock)
        
        return Cmi5Package(
            id: id,
            manifest: manifest,
            archivePath: URL(fileURLWithPath: "/tmp/test.zip"),
            extractedPath: URL(fileURLWithPath: "/tmp/test"),
            fileSize: 1024
        )
    }
    
    private func findActivity(contentUrl: String?, packageId: UUID, in packages: [Cmi5Package]) -> Cmi5Activity? {
        guard let contentUrl = contentUrl else { return nil }
        
        for package in packages where package.id == packageId {
            if let rootBlock = package.manifest.rootBlock {
                return findActivityInBlock(activityId: contentUrl, in: rootBlock)
            }
        }
        
        return nil
    }
    
    private func findActivityInBlock(activityId: String, in block: Cmi5Block) -> Cmi5Activity? {
        // Check activities in this block
        if let activity = block.activities.first(where: { $0.activityId == activityId }) {
            return activity
        }
        
        // Check child blocks
        for childBlock in block.blocks {
            if let activity = findActivityInBlock(activityId: activityId, in: childBlock) {
                return activity
            }
        }
        
        return nil
    }
    
    private func findActivityWithFallback(module: ManagedCourseModule, packageId: UUID, in packages: [Cmi5Package]) -> Cmi5Activity? {
        // Try to find by contentUrl first
        if let activity = findActivity(contentUrl: module.contentUrl, packageId: packageId, in: packages) {
            return activity
        }
        
        // Fallback to first activity in package
        for package in packages where package.id == packageId {
            if let rootBlock = package.manifest.rootBlock {
                return findFirstActivityInBlock(in: rootBlock)
            }
        }
        
        return nil
    }
    
    private func findFirstActivityInBlock(in block: Cmi5Block) -> Cmi5Activity? {
        if let firstActivity = block.activities.first {
            return firstActivity
        }
        
        for childBlock in block.blocks {
            if let activity = findFirstActivityInBlock(in: childBlock) {
                return activity
            }
        }
        
        return nil
    }
} 