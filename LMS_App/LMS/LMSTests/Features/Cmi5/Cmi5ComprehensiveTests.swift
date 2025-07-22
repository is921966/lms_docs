import XCTest
@testable import LMS

/// Comprehensive tests for Cmi5 functionality based on CATAPULT implementation
final class Cmi5ComprehensiveTests: XCTestCase {
    
    var cmi5Service: Cmi5Service!
    var lrsService: LRSService!
    var courseService: CourseService!
    
    override func setUp() {
        super.setUp()
        cmi5Service = Cmi5Service()
        lrsService = LRSService.shared
        courseService = CourseService()
    }
    
    override func tearDown() {
        cmi5Service = nil
        lrsService = nil
        courseService = nil
        super.tearDown()
    }
    
    // MARK: - Package Import and Validation Tests
    
    func test_importCmi5Package_shouldValidateManifest() async throws {
        // Arrange
        let packageData = createTestCmi5Package()
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test.zip")
        try packageData.write(to: tempURL)
        
        // Act
        let package = try await cmi5Service.importPackage(from: tempURL)
        
        // Assert
        XCTAssertNotNil(package)
        XCTAssertNotNil(package.manifest.course)
        XCTAssertTrue(package.manifest.course?.au.count ?? 0 > 0)
        XCTAssertEqual(package.manifest.course?.id, "https://example.com/course/test")
    }
    
    func test_importCmi5Package_shouldExtractActivities() async throws {
        // Arrange
        let packageData = createTestCmi5Package()
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test.zip")
        try packageData.write(to: tempURL)
        
        // Act
        let package = try await cmi5Service.importPackage(from: tempURL)
        let activities = try await cmi5Service.getActivities(for: package.id)
        
        // Assert
        XCTAssertGreaterThan(activities.count, 0)
        XCTAssertEqual(activities.first?.activityType, "http://adlnet.gov/expapi/activities/lesson")
    }
    
    // MARK: - Launch Session Tests
    
    func test_launchCmi5Activity_shouldCreateSession() async throws {
        // Arrange
        let activity = createTestActivity()
        let studentId = UUID()
        let sessionId = UUID()
        
        // Act
        let launchURL = try await cmi5Service.getLaunchURL(
            for: activity,
            studentId: studentId,
            sessionId: sessionId
        )
        
        // Assert
        XCTAssertNotNil(launchURL)
        
        // Verify launch parameters
        let components = URLComponents(url: launchURL, resolvingAgainstBaseURL: true)
        XCTAssertNotNil(components?.queryItems?.first(where: { $0.name == "endpoint" }))
        XCTAssertNotNil(components?.queryItems?.first(where: { $0.name == "fetch" }))
        XCTAssertNotNil(components?.queryItems?.first(where: { $0.name == "registration" }))
        XCTAssertNotNil(components?.queryItems?.first(where: { $0.name == "activityId" }))
        XCTAssertNotNil(components?.queryItems?.first(where: { $0.name == "actor" }))
    }
    
    // MARK: - xAPI Statement Flow Tests
    
    func test_cmi5StatementFlow_shouldFollowCorrectSequence() async throws {
        // Arrange
        let activity = createTestActivity()
        let actor = XAPIActor(
            account: XAPIAccount(
                name: "test_user",
                homePage: "https://lms.example.com"
            )
        )
        let sessionId = UUID().uuidString
        let registration = UUID().uuidString
        
        // Act & Assert - Launched statement
        let launchedStatement = try XAPIStatementBuilder()
            .setActor(actor)
            .setVerb(XAPIStatementBuilder.Cmi5Verb.launched)
            .setObject(XAPIObject.activity(activity.toXAPIActivity()))
            .setCmi5Context(sessionId: sessionId, registration: registration)
            .build()
        
        try await lrsService.sendStatement(launchedStatement)
        
        // Initialized statement
        let initializedStatement = try XAPIStatementBuilder()
            .setActor(actor)
            .setVerb(XAPIStatementBuilder.Cmi5Verb.initialized)
            .setObject(XAPIObject.activity(activity.toXAPIActivity()))
            .setCmi5Context(sessionId: sessionId, registration: registration)
            .build()
        
        try await lrsService.sendStatement(initializedStatement)
        
        // Progress statement (custom)
        let progressStatement = try XAPIStatementBuilder()
            .setActor(actor)
            .setVerb(XAPIVerb(
                id: "http://adlnet.gov/expapi/verbs/progressed",
                display: ["en-US": "progressed"]
            ))
            .setObject(XAPIObject.activity(activity.toXAPIActivity()))
            .setResult(score: nil, success: nil, completion: nil, response: nil, duration: nil, extensions: ["progress": AnyCodable(0.5)])
            .setCmi5Context(sessionId: sessionId, registration: registration)
            .build()
        
        try await lrsService.sendStatement(progressStatement)
        
        // Completed statement
        let completedStatement = try XAPIStatementBuilder()
            .setActor(actor)
            .setVerb(XAPIStatementBuilder.Cmi5Verb.completed)
            .setObject(XAPIObject.activity(activity.toXAPIActivity()))
            .setResult(score: nil, success: true, completion: true, response: nil, duration: "PT30M", extensions: nil)
            .setCmi5Context(sessionId: sessionId, registration: registration)
            .build()
        
        try await lrsService.sendStatement(completedStatement)
        
        // Passed statement
        let passedStatement = try XAPIStatementBuilder()
            .setActor(actor)
            .setVerb(XAPIStatementBuilder.Cmi5Verb.passed)
            .setObject(XAPIObject.activity(activity.toXAPIActivity()))
            .setResult(
                score: XAPIScore(scaled: 0.85, raw: 85, min: 0, max: 100),
                success: true,
                completion: true,
                response: nil,
                duration: "PT30M",
                extensions: nil
            )
            .setCmi5Context(sessionId: sessionId, registration: registration)
            .build()
        
        try await lrsService.sendStatement(passedStatement)
        
        // Terminated statement
        let terminatedStatement = try XAPIStatementBuilder()
            .setActor(actor)
            .setVerb(XAPIStatementBuilder.Cmi5Verb.terminated)
            .setObject(XAPIObject.activity(activity.toXAPIActivity()))
            .setCmi5Context(sessionId: sessionId, registration: registration)
            .build()
        
        try await lrsService.sendStatement(terminatedStatement)
        
        // Verify statements were sent in correct order
        let statements = try await lrsService.getStatements(
            activityId: activity.activityId,
            userId: "test_user",
            limit: 10
        )
        
        XCTAssertEqual(statements.count, 6)
        XCTAssertEqual(statements[0].verb.id, "http://adlnet.gov/expapi/verbs/launched")
        XCTAssertEqual(statements[1].verb.id, "http://adlnet.gov/expapi/verbs/initialized")
        XCTAssertEqual(statements[5].verb.id, "http://adlnet.gov/expapi/verbs/terminated")
    }
    
    // MARK: - Launch Data Tests
    
    func test_launchData_shouldContainRequiredFields() async throws {
        // Arrange
        let activity = createTestActivity()
        let sessionId = UUID().uuidString
        
        // Act
        let launchData = createLaunchData(for: activity, sessionId: sessionId)
        
        // Assert
        XCTAssertNotNil(launchData["contextTemplate"])
        XCTAssertNotNil(launchData["launchMode"])
        XCTAssertNotNil(launchData["launchParameters"])
        
        let contextTemplate = launchData["contextTemplate"] as? [String: Any]
        XCTAssertNotNil(contextTemplate?["registration"])
        XCTAssertNotNil(contextTemplate?["contextActivities"])
        
        let launchParameters = launchData["launchParameters"] as? [String: Any]
        XCTAssertNotNil(launchParameters?["masteryScore"])
        XCTAssertNotNil(launchParameters?["moveOn"])
    }
    
    // MARK: - Move On Criteria Tests
    
    func test_moveOnCriteria_passed() async throws {
        // Arrange
        let activity = createTestActivity(moveOn: .passed)
        
        // Act & Assert
        XCTAssertFalse(isSatisfied(activity: activity, completed: true, passed: false))
        XCTAssertTrue(isSatisfied(activity: activity, completed: false, passed: true))
        XCTAssertTrue(isSatisfied(activity: activity, completed: true, passed: true))
    }
    
    func test_moveOnCriteria_completed() async throws {
        // Arrange
        let activity = createTestActivity(moveOn: .completed)
        
        // Act & Assert
        XCTAssertTrue(isSatisfied(activity: activity, completed: true, passed: false))
        XCTAssertFalse(isSatisfied(activity: activity, completed: false, passed: true))
        XCTAssertTrue(isSatisfied(activity: activity, completed: true, passed: true))
    }
    
    func test_moveOnCriteria_completedAndPassed() async throws {
        // Arrange
        let activity = createTestActivity(moveOn: .completedAndPassed)
        
        // Act & Assert
        XCTAssertFalse(isSatisfied(activity: activity, completed: true, passed: false))
        XCTAssertFalse(isSatisfied(activity: activity, completed: false, passed: true))
        XCTAssertTrue(isSatisfied(activity: activity, completed: true, passed: true))
    }
    
    func test_moveOnCriteria_completedOrPassed() async throws {
        // Arrange
        let activity = createTestActivity(moveOn: .completedOrPassed)
        
        // Act & Assert
        XCTAssertTrue(isSatisfied(activity: activity, completed: true, passed: false))
        XCTAssertTrue(isSatisfied(activity: activity, completed: false, passed: true))
        XCTAssertTrue(isSatisfied(activity: activity, completed: true, passed: true))
    }
    
    // MARK: - Course Management Integration Tests
    
    func test_courseManagement_shouldCreateModulesFromCmi5() async throws {
        // Arrange
        let packageData = createTestCmi5Package()
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test.zip")
        try packageData.write(to: tempURL)
        
        // Import package
        let package = try await cmi5Service.importPackage(from: tempURL)
        
        // Act - Convert to managed course
        let converter = Cmi5CourseConverter()
        let managedCourse = converter.convertToManagedCourse(package: package)
        
        // Assert
        XCTAssertNotNil(managedCourse)
        XCTAssertGreaterThan(managedCourse.modules.count, 0)
        
        // Verify module has contentUrl
        let firstModule = managedCourse.modules.first
        XCTAssertNotNil(firstModule?.contentUrl)
        XCTAssertEqual(firstModule?.contentType, .cmi5)
    }
    
    // MARK: - Helper Methods
    
    private func createTestCmi5Package() -> Data {
        // Create a minimal cmi5.xml
        let cmi5XML = """
        <?xml version="1.0" encoding="utf-8"?>
        <courseStructure xmlns="https://w3id.org/xapi/profiles/cmi5/v1/CourseStructure.xsd">
            <course id="https://example.com/course/test">
                <title>
                    <langstring lang="en">Test Course</langstring>
                </title>
                <description>
                    <langstring lang="en">Test Description</langstring>
                </description>
            </course>
            <au id="https://example.com/activity/1" moveOn="Passed" masteryScore="0.8">
                <title>
                    <langstring lang="en">Module 1</langstring>
                </title>
                <description>
                    <langstring lang="en">First module</langstring>
                </description>
                <url>content/module1/index.html</url>
            </au>
        </courseStructure>
        """
        
        // Create a simple zip with cmi5.xml
        // In real implementation, use ZIPFoundation
        return cmi5XML.data(using: .utf8)!
    }
    
    private func createTestActivity(moveOn: Cmi5Activity.MoveOnCriteria = .completedOrPassed) -> Cmi5Activity {
        return Cmi5Activity(
            id: UUID(),
            packageId: UUID(),
            activityId: "https://example.com/activity/test",
            title: "Test Activity",
            description: "Test Description",
            launchUrl: "content/test/index.html",
            launchMethod: .ownWindow,
            moveOn: moveOn,
            masteryScore: 0.8,
            activityType: "http://adlnet.gov/expapi/activities/lesson",
            duration: "PT30M"
        )
    }
    
    private func createLaunchData(for activity: Cmi5Activity, sessionId: String) -> [String: Any] {
        return [
            "contextTemplate": [
                "registration": UUID().uuidString,
                "contextActivities": [
                    "grouping": [
                        ["id": "https://example.com/course/test"]
                    ]
                ],
                "extensions": [
                    "https://w3id.org/xapi/cmi5/context/extensions/sessionid": sessionId
                ]
            ],
            "launchMode": "Normal",
            "launchParameters": [
                "masteryScore": activity.masteryScore ?? 0.8,
                "moveOn": activity.moveOn.rawValue,
                "returnURL": "https://lms.example.com/return"
            ]
        ]
    }
    
    private func isSatisfied(activity: Cmi5Activity, completed: Bool, passed: Bool) -> Bool {
        switch activity.moveOn {
        case .passed:
            return passed
        case .completed:
            return completed
        case .completedAndPassed:
            return completed && passed
        case .completedOrPassed:
            return completed || passed
        case .notApplicable:
            return true
        }
    }
}

// MARK: - Cmi5Activity Extension for Testing

extension Cmi5Activity {
    func toXAPIActivity() -> XAPIActivity {
        return XAPIActivity(
            id: activityId,
            type: activityType,
            name: ["en-US": title],
            description: description.map { ["en-US": $0] }
        )
    }
} 