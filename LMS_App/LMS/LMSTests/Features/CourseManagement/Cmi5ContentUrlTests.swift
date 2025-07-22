import XCTest
@testable import LMS

final class Cmi5ContentUrlTests: XCTestCase {
    
    func test_cmi5CourseConverter_shouldSetContentUrl() {
        // Arrange
        let activityId = "activity-123"
        let activity = Cmi5Activity(
            id: UUID(),
            packageId: UUID(),
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
            blocks: [],
            activities: [activity]
        )
        
        let manifest = Cmi5Manifest(
            id: "manifest-1",
            rootBlock: block,
            course: Cmi5Course(
                id: "course-1",
                title: [Cmi5LangString(lang: "en", value: "Test Course")],
                description: nil
            )
        )
        
        let package = Cmi5Package(
            id: UUID(),
            title: "Test Package",
            description: nil,
            version: "1.0",
            uploadedAt: Date(),
            uploadedBy: UUID(),
            manifest: manifest,
            activities: [activity]
        )
        
        // Act
        let managedCourse = Cmi5CourseConverter.convertToManagedCourse(from: package)
        
        // Assert
        XCTAssertFalse(managedCourse.modules.isEmpty, "Course should have modules")
        
        let firstModule = managedCourse.modules.first!
        XCTAssertEqual(firstModule.contentType, .cmi5, "Module should be Cmi5 type")
        XCTAssertNotNil(firstModule.contentUrl, "Module should have contentUrl")
        XCTAssertEqual(firstModule.contentUrl, activityId, "Module contentUrl should match activity ID")
    }
    
    func test_cmi5CourseConverter_withNoActivities_shouldHaveNilContentUrl() {
        // Arrange
        let block = Cmi5Block(
            id: "block-1",
            title: [Cmi5LangString(lang: "en", value: "Empty Block")],
            description: nil,
            blocks: [],
            activities: [] // No activities
        )
        
        let manifest = Cmi5Manifest(
            id: "manifest-1",
            rootBlock: block,
            course: Cmi5Course(
                id: "course-1",
                title: [Cmi5LangString(lang: "en", value: "Empty Course")],
                description: nil
            )
        )
        
        let package = Cmi5Package(
            id: UUID(),
            title: "Empty Package",
            description: nil,
            version: "1.0",
            uploadedAt: Date(),
            uploadedBy: UUID(),
            manifest: manifest,
            activities: []
        )
        
        // Act
        let managedCourse = Cmi5CourseConverter.convertToManagedCourse(from: package)
        
        // Assert
        XCTAssertFalse(managedCourse.modules.isEmpty, "Course should have at least one module")
        
        let firstModule = managedCourse.modules.first!
        XCTAssertEqual(firstModule.contentType, .cmi5, "Module should be Cmi5 type")
        XCTAssertNil(firstModule.contentUrl, "Module should have nil contentUrl when no activities")
    }
} 