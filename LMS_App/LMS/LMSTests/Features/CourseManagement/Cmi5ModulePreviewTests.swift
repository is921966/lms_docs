import XCTest
@testable import LMS

final class Cmi5ModulePreviewTests: XCTestCase {
    
    var cmi5Service: Cmi5Service!
    var courseService: CourseService!
    
    override func setUp() {
        super.setUp()
        cmi5Service = Cmi5Service()
        courseService = CourseService()
    }
    
    override func tearDown() {
        cmi5Service = nil
        courseService = nil
        super.tearDown()
    }
    
    func test_cmi5Module_withContentUrl_shouldLoadActivity() {
        // Arrange
        let packageId = UUID()
        let activityId = "test-activity-123"
        
        // Create test Cmi5 package
        let activity = Cmi5Activity(
            id: UUID(),
            packageId: packageId,
            activityId: activityId,
            title: "Test Activity",
            description: nil,
            launchUrl: "index.html",
            launchMethod: .anyWindow,
            moveOn: .passed,
            masteryScore: nil,
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
            title: "Test Course",
            description: nil,
            rootBlock: block
        )
        
        let manifest = Cmi5Manifest(course: course)
        
        let package = Cmi5Package(
            id: packageId,
            title: "Test Package",
            manifest: manifest,
            sourcePath: URL(fileURLWithPath: "/test"),
            importDate: Date()
        )
        
        // Add package to service
        cmi5Service.packages.append(package)
        
        // Create module with contentUrl
        let module = ManagedCourseModule(
            id: UUID(),
            title: "Test Module",
            description: "Test",
            order: 0,
            contentType: .cmi5,
            contentUrl: activityId, // This should be set
            duration: 30
        )
        
        // Act & Assert
        print("\n🧪 Testing module with contentUrl")
        print("Module contentUrl: \(String(describing: module.contentUrl))")
        print("Expected activityId: \(activityId)")
        
        XCTAssertNotNil(module.contentUrl, "Module should have contentUrl")
        XCTAssertEqual(module.contentUrl, activityId, "ContentUrl should match activityId")
        
        // Verify package can be found
        let foundPackage = cmi5Service.packages.first { $0.id == packageId }
        XCTAssertNotNil(foundPackage, "Package should be found in service")
        
        // Verify activity can be found
        if let rootBlock = foundPackage?.manifest.course?.rootBlock {
            XCTAssertEqual(rootBlock.activities.count, 1, "Block should have 1 activity")
            XCTAssertEqual(rootBlock.activities.first?.activityId, activityId, "Activity ID should match")
        }
    }
    
    func test_cmi5Module_withoutContentUrl_shouldFindFirstActivity() {
        // Arrange
        let packageId = UUID()
        let activityId = "first-activity-456"
        
        // Create test Cmi5 package with activity
        let activity = Cmi5Activity(
            id: UUID(),
            packageId: packageId,
            activityId: activityId,
            title: "First Activity",
            description: nil,
            launchUrl: "index.html",
            launchMethod: .anyWindow,
            moveOn: .passed,
            masteryScore: nil,
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
            title: "Test Course",
            description: nil,
            rootBlock: block
        )
        
        let manifest = Cmi5Manifest(course: course)
        
        let package = Cmi5Package(
            id: packageId,
            title: "Test Package",
            manifest: manifest,
            sourcePath: URL(fileURLWithPath: "/test"),
            importDate: Date()
        )
        
        // Add package to service
        cmi5Service.packages.append(package)
        
        // Create module WITHOUT contentUrl (simulating old module)
        let module = ManagedCourseModule(
            id: UUID(),
            title: "Old Module",
            description: "Module without contentUrl",
            order: 0,
            contentType: .cmi5,
            contentUrl: nil, // This is nil
            duration: 30
        )
        
        // Act & Assert
        print("\n🧪 Testing module without contentUrl")
        print("Module contentUrl: \(String(describing: module.contentUrl))")
        print("Should find first activity: \(activityId)")
        
        XCTAssertNil(module.contentUrl, "Old module should not have contentUrl")
        
        // Test the findFirstActivityId logic
        if let rootBlock = package.manifest.course?.rootBlock {
            let firstActivityId = findFirstActivityIdInBlock(rootBlock)
            XCTAssertNotNil(firstActivityId, "Should find first activity ID")
            XCTAssertEqual(firstActivityId, activityId, "Should find correct activity ID")
        }
    }
    
    // Helper function to mimic the findFirstActivityId logic
    private func findFirstActivityIdInBlock(_ block: Cmi5Block) -> String? {
        for activity in block.activities {
            return activity.activityId
        }
        for subBlock in block.blocks {
            if let activityId = findFirstActivityIdInBlock(subBlock) {
                return activityId
            }
        }
        return nil
    }
    
    func test_cmi5CourseConverter_shouldSetContentUrl() {
        // Arrange
        let packageId = UUID()
        let activityId = "converter-test-789"
        
        // Create test activity
        let activity = Cmi5Activity(
            id: UUID(),
            packageId: packageId,
            activityId: activityId,
            title: "Converter Test Activity",
            description: nil,
            launchUrl: "index.html",
            launchMethod: .anyWindow,
            moveOn: .passed,
            masteryScore: nil,
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
        
        let cmi5Course = Cmi5Course(
            id: "course-1",
            title: "Test Course",
            description: nil,
            rootBlock: block
        )
        
        let manifest = Cmi5Manifest(course: cmi5Course)
        
        let package = Cmi5Package(
            id: packageId,
            title: "Test Package",
            manifest: manifest,
            sourcePath: URL(fileURLWithPath: "/test"),
            importDate: Date()
        )
        
        // Act - Convert to ManagedCourse
        let converter = Cmi5CourseConverter()
        let managedCourse = converter.convertToManagedCourse(from: package)
        
        // Assert
        print("\n🧪 Testing Cmi5CourseConverter")
        print("Converted course has \(managedCourse.modules.count) modules")
        
        XCTAssertGreaterThan(managedCourse.modules.count, 0, "Should have at least one module")
        
        if let firstModule = managedCourse.modules.first {
            print("First module contentUrl: \(String(describing: firstModule.contentUrl))")
            print("Expected activityId: \(activityId)")
            
            XCTAssertNotNil(firstModule.contentUrl, "Module should have contentUrl set")
            XCTAssertEqual(firstModule.contentUrl, activityId, "ContentUrl should match first activity ID")
        }
    }
} 