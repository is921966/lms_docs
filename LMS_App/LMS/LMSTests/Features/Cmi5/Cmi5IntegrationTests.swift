//
//  Cmi5IntegrationTests.swift
//  LMSTests
//
//  Created on Sprint 40 Day 5 - Integration Tests
//

import XCTest
@testable import LMS

/// Интеграционные тесты для Cmi5 модуля
final class Cmi5IntegrationTests: XCTestCase {
    
    private var service: Cmi5Service!
    private var lrsService: MockLRSService!
    
    override func setUp() {
        super.setUp()
        lrsService = MockLRSService()
        service = Cmi5Service()
    }
    
    override func tearDown() {
        service = nil
        lrsService = nil
        super.tearDown()
    }
    
    // MARK: - Full Cycle Tests
    
    func testFullImportCycle() async throws {
        // Given - создаем тестовый ZIP файл
        let testZipURL = try createTestZipPackage()
        defer { try? FileManager.default.removeItem(at: testZipURL) }
        
        // When - импортируем пакет
        let result = try await service.importPackage(
            from: testZipURL,
            courseId: UUID(),
            uploadedBy: UUID()
        )
        
        // Then - проверяем результат
        XCTAssertNotNil(result.package)
        XCTAssertEqual(result.package.title, "Test Cmi5 Course")
        XCTAssertTrue(result.package.isValid)
        XCTAssertTrue(result.warnings.isEmpty)
        XCTAssertNotNil(result.storageUrl)
        
        // Проверяем что пакет добавлен в список
        XCTAssertEqual(service.packages.count, 1)
        XCTAssertEqual(service.packages.first?.id, result.package.id)
    }
    
    func testImportAndAssignToCourse() async throws {
        // Given - импортируем пакет
        let testZipURL = try createTestZipPackage()
        defer { try? FileManager.default.removeItem(at: testZipURL) }
        
        let importResult = try await service.importPackage(
            from: testZipURL,
            uploadedBy: UUID()
        )
        
        let courseId = UUID()
        
        // When - привязываем к курсу
        try await service.assignPackageToCourse(
            packageId: importResult.package.id,
            courseId: courseId
        )
        
        // Then - проверяем привязку
        let updatedPackage = service.packages.first { $0.id == importResult.package.id }
        XCTAssertEqual(updatedPackage?.courseId, courseId)
    }
    
    func testGetActivitiesFromPackage() async throws {
        // Given - импортируем пакет с активностями
        let testZipURL = try createTestZipWithActivities()
        defer { try? FileManager.default.removeItem(at: testZipURL) }
        
        let result = try await service.importPackage(
            from: testZipURL,
            uploadedBy: UUID()
        )
        
        // When - получаем активности
        let activities = try await service.getActivities(for: result.package.id)
        
        // Then - проверяем активности
        XCTAssertEqual(activities.count, 3)
        XCTAssertTrue(activities.contains { $0.title == "Introduction" })
        XCTAssertTrue(activities.contains { $0.title == "Main Content" })
        XCTAssertTrue(activities.contains { $0.title == "Final Test" })
    }
    
    func testLaunchURLGeneration() async throws {
        // Given - создаем активность
        let activity = Cmi5Activity(
            packageId: UUID(),
            activityId: "test-activity",
            title: "Test Activity",
            launchUrl: "content/test/index.html",
            launchMethod: .ownWindow,
            moveOn: .completed,
            activityType: "lesson"
        )
        
        let studentId = UUID()
        let sessionId = UUID()
        
        // When - генерируем URL
        let launchURL = try await service.getLaunchURL(
            for: activity,
            studentId: studentId,
            sessionId: sessionId
        )
        
        // Then - проверяем параметры
        let components = URLComponents(url: launchURL, resolvingAgainstBaseURL: true)!
        XCTAssertNotNil(components.queryItems?.first { $0.name == "endpoint" })
        XCTAssertNotNil(components.queryItems?.first { $0.name == "fetch" })
        XCTAssertNotNil(components.queryItems?.first { $0.name == "registration" })
        XCTAssertNotNil(components.queryItems?.first { $0.name == "activityId" })
        XCTAssertNotNil(components.queryItems?.first { $0.name == "actor" })
        
        let registrationItem = components.queryItems?.first { $0.name == "registration" }
        XCTAssertEqual(registrationItem?.value, sessionId.uuidString)
    }
    
    // MARK: - xAPI Integration Tests
    
    func testSendLaunchedStatement() async throws {
        // Given
        let userId = "test-user"
        let activityId = "test-activity"
        let sessionId = "test-session"
        let registration = "test-registration"
        
        // When - создаем и отправляем launched statement
        let statement = try XAPIStatementBuilder.launchedStatement(
            userId: userId,
            activityId: activityId,
            sessionId: sessionId,
            registration: registration
        )
        
        let statementId = try await lrsService.sendStatement(statement)
        
        // Then
        XCTAssertFalse(statementId.isEmpty)
        
        // Проверяем что statement сохранен
        let statements = try await lrsService.getStatements(
            activityId: activityId,
            userId: nil,
            limit: 10
        )
        
        XCTAssertEqual(statements.count, 1)
        XCTAssertEqual(statements.first?.verb.id, XAPIStatementBuilder.Cmi5Verb.launched.id)
    }
    
    func testCompleteActivityFlow() async throws {
        // Given
        let userId = "test-user"
        let activityId = "test-activity"
        let sessionId = "test-session"
        let registration = "test-registration"
        
        // When - симулируем полный цикл активности
        
        // 1. Launched
        let launchedStatement = try XAPIStatementBuilder.launchedStatement(
            userId: userId,
            activityId: activityId,
            sessionId: sessionId,
            registration: registration
        )
        _ = try await lrsService.sendStatement(launchedStatement)
        
        // 2. Initialized
        let initializedStatement = try XAPIStatementBuilder()
            .setActor(userId: userId)
            .setVerb(XAPIStatementBuilder.Cmi5Verb.initialized)
            .setActivity(id: activityId)
            .setCmi5Context(sessionId: sessionId, registration: registration)
            .build()
        _ = try await lrsService.sendStatement(initializedStatement)
        
        // 3. Progress
        try await lrsService.setState(
            activityId: activityId,
            userId: userId,
            stateId: "progress",
            value: ["percent": 50]
        )
        
        // 4. Completed
        let completedStatement = try XAPIStatementBuilder.completedStatement(
            userId: userId,
            activityId: activityId,
            sessionId: sessionId,
            registration: registration,
            duration: "PT30M"
        )
        _ = try await lrsService.sendStatement(completedStatement)
        
        // 5. Passed
        let passedStatement = try XAPIStatementBuilder.passedStatement(
            userId: userId,
            activityId: activityId,
            sessionId: sessionId,
            registration: registration,
            score: 85.0,
            duration: "PT30M"
        )
        _ = try await lrsService.sendStatement(passedStatement)
        
        // 6. Terminated
        let terminatedStatement = try XAPIStatementBuilder.terminatedStatement(
            userId: userId,
            activityId: activityId,
            sessionId: sessionId,
            registration: registration,
            duration: "PT31M"
        )
        _ = try await lrsService.sendStatement(terminatedStatement)
        
        // Then - проверяем все statements
        let statements = try await lrsService.getStatements(
            activityId: activityId,
            userId: nil,
            limit: 10
        )
        
        XCTAssertEqual(statements.count, 6)
        
        // Проверяем последовательность
        let verbIds = statements.map { $0.verb.id }
        XCTAssertTrue(verbIds.contains(XAPIStatementBuilder.Cmi5Verb.launched.id))
        XCTAssertTrue(verbIds.contains(XAPIStatementBuilder.Cmi5Verb.initialized.id))
        XCTAssertTrue(verbIds.contains(XAPIStatementBuilder.Cmi5Verb.completed.id))
        XCTAssertTrue(verbIds.contains(XAPIStatementBuilder.Cmi5Verb.passed.id))
        XCTAssertTrue(verbIds.contains(XAPIStatementBuilder.Cmi5Verb.terminated.id))
        
        // Проверяем сохранение прогресса
        let progressState = try await lrsService.getState(
            activityId: activityId,
            userId: userId,
            stateId: "progress"
        )
        XCTAssertEqual(progressState?["percent"] as? Int, 50)
    }
    
    // MARK: - Error Handling Tests
    
    func testImportInvalidPackage() async throws {
        // Given - создаем невалидный файл
        let invalidURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("invalid.txt")
        try "Invalid content".write(to: invalidURL, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: invalidURL) }
        
        // When/Then - ожидаем ошибку
        do {
            _ = try await service.importPackage(
                from: invalidURL,
                uploadedBy: UUID()
            )
            XCTFail("Should throw error for invalid package")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func testDeletePackage() async throws {
        // Given - импортируем пакет
        let testZipURL = try createTestZipPackage()
        defer { try? FileManager.default.removeItem(at: testZipURL) }
        
        let result = try await service.importPackage(
            from: testZipURL,
            uploadedBy: UUID()
        )
        
        XCTAssertEqual(service.packages.count, 1)
        
        // When - удаляем пакет
        try await service.deletePackage(id: result.package.id)
        
        // Then - проверяем удаление
        XCTAssertEqual(service.packages.count, 0)
    }
    
    // MARK: - Helper Methods
    
    private func createTestZipPackage() throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        // Создаем манифест
        let manifestContent = """
        <?xml version="1.0" encoding="UTF-8"?>
        <courseStructure xmlns="https://w3id.org/xapi/profiles/cmi5/v1/CourseStructure.xsd"
                        id="test_course_v1">
            <course id="course_001">
                <title>Test Cmi5 Course</title>
                <description>Test course for integration testing</description>
                <au id="au_intro" launchMethod="OwnWindow" moveOn="Completed">
                    <title>Introduction</title>
                    <url>content/intro/index.html</url>
                </au>
            </course>
        </courseStructure>
        """
        
        let manifestURL = tempDir.appendingPathComponent("cmi5.xml")
        try manifestContent.write(to: manifestURL, atomically: true, encoding: .utf8)
        
        // Создаем content
        let contentDir = tempDir.appendingPathComponent("content/intro")
        try FileManager.default.createDirectory(at: contentDir, withIntermediateDirectories: true)
        
        let indexHTML = "<html><body>Test Content</body></html>"
        try indexHTML.write(
            to: contentDir.appendingPathComponent("index.html"),
            atomically: true,
            encoding: .utf8
        )
        
        // Создаем ZIP (в реальности используем ZIPFoundation)
        // Для теста просто переименуем папку
        let zipURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(UUID().uuidString).zip")
        
        // Копируем как ZIP для теста
        try FileManager.default.copyItem(at: tempDir, to: zipURL)
        
        // Удаляем временную папку
        try FileManager.default.removeItem(at: tempDir)
        
        return zipURL
    }
    
    private func createTestZipWithActivities() throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        // Создаем манифест с несколькими активностями
        let manifestContent = """
        <?xml version="1.0" encoding="UTF-8"?>
        <courseStructure xmlns="https://w3id.org/xapi/profiles/cmi5/v1/CourseStructure.xsd"
                        id="test_course_v1">
            <course id="course_001">
                <title>Test Course with Activities</title>
                <block id="block_main">
                    <title>Main Block</title>
                    <au id="au_intro" moveOn="Completed">
                        <title>Introduction</title>
                        <url>content/intro/index.html</url>
                    </au>
                    <au id="au_content" moveOn="CompletedAndPassed" masteryScore="0.8">
                        <title>Main Content</title>
                        <url>content/main/index.html</url>
                    </au>
                    <au id="au_test" moveOn="Passed" masteryScore="0.75">
                        <title>Final Test</title>
                        <url>content/test/index.html</url>
                        <activityType>http://adlnet.gov/expapi/activities/assessment</activityType>
                    </au>
                </block>
            </course>
        </courseStructure>
        """
        
        let manifestURL = tempDir.appendingPathComponent("cmi5.xml")
        try manifestContent.write(to: manifestURL, atomically: true, encoding: .utf8)
        
        // Создаем ZIP
        let zipURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(UUID().uuidString).zip")
        try FileManager.default.copyItem(at: tempDir, to: zipURL)
        try FileManager.default.removeItem(at: tempDir)
        
        return zipURL
    }
} 