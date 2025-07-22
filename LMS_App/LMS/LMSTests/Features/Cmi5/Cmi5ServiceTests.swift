//
//  Cmi5ServiceTests.swift
//  LMSTests
//
//  Created by Assistant on 15.07.2025.
//

import XCTest
@testable import LMS

final class Cmi5ServiceTests: XCTestCase {
    
    var sut: Cmi5Service!
    var mockRepository: MockCmi5Repository!
    var mockFileStorage: MockFileStorageService!
    var mockArchiveHandler: MockCmi5ArchiveHandler!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockCmi5Repository()
        mockFileStorage = MockFileStorageService()
        mockArchiveHandler = MockCmi5ArchiveHandler()
        
        // Inject mocks
        sut = Cmi5Service()
        // Note: In real implementation we would need dependency injection
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        mockFileStorage = nil
        mockArchiveHandler = nil
        super.tearDown()
    }
    
    func testLoadPackages() async throws {
        // Given
        let expectedPackages = [createMockPackage()]
        mockRepository.packages = expectedPackages
        
        // When
        let packages = try await sut.loadPackages()
        
        // Then
        XCTAssertEqual(packages.count, expectedPackages.count)
        XCTAssertEqual(packages.first?.id, expectedPackages.first?.id)
    }
    
    func testImportPackageSuccess() async throws {
        // Given
        let testBundle = Bundle(for: type(of: self))
        guard let zipPath = testBundle.path(forResource: "test_cmi5_course", ofType: "zip"),
              let zipURL = URL(string: "file://\(zipPath)") else {
            XCTFail("Test resource not found")
            return
        }
        
        let courseId = UUID()
        let uploadedBy = UUID()
        
        // When
        let result = try await sut.importPackage(from: zipURL, courseId: courseId, uploadedBy: uploadedBy)
        
        // Then
        XCTAssertNotNil(result.package)
        XCTAssertEqual(result.package.courseId, courseId)
        XCTAssertTrue(result.warnings.isEmpty)
    }
    
    func testFindActivityInPackages() async throws {
        // Given
        let activity = createMockActivity()
        let package = createMockPackage(with: [activity])
        mockRepository.packages = [package]
        
        // When
        let packages = try await sut.loadPackages()
        let foundActivity = findActivity(activityId: activity.activityId, in: packages)
        
        // Then
        XCTAssertNotNil(foundActivity)
        XCTAssertEqual(foundActivity?.activityId, activity.activityId)
    }
    
    // MARK: - Helper Methods
    
    private func createMockPackage(with activities: [Cmi5Activity] = []) -> Cmi5Package {
        let packageId = UUID()
        var manifest = Cmi5Manifest(
            identifier: packageId.uuidString,
            version: "1.0",
            title: "Test Package",
            description: "Test description",
            creator: "Test creator"
        )
        
        if !activities.isEmpty {
            let block = Cmi5ActivityBlock(
                id: "test_block",
                title: "Test Block",
                description: nil,
                activities: activities,
                blocks: []
            )
            let course = Cmi5Course(
                id: "test_course",
                title: "Test Course",
                description: nil,
                rootBlock: block
            )
            manifest.course = course
        }
        
        return Cmi5Package(
            packageId: packageId,
            title: "Test Package",
            description: "Test description",
            courseId: UUID(),
            manifest: manifest,
            filePath: "/test/path",
            size: 1000,
            uploadedBy: UUID(),
            version: "1.0",
            isValid: true,
            validationErrors: []
        )
    }
    
    private func createMockActivity() -> Cmi5Activity {
        return Cmi5Activity(
            id: UUID(),
            packageId: UUID(),
            activityId: "test_activity_001",
            title: "Test Activity",
            description: "Test activity description",
            launchUrl: "index.html",
            launchMethod: .ownWindow,
            moveOn: .completed,
            masteryScore: 0.8,
            activityType: "http://adlnet.gov/expapi/activities/lesson",
            duration: nil
        )
    }
    
    private func findActivity(activityId: String, in packages: [Cmi5Package]) -> Cmi5Activity? {
        for package in packages {
            if let course = package.manifest.course,
               let rootBlock = course.rootBlock {
                if let activity = findActivityInBlock(activityId: activityId, in: rootBlock) {
                    return activity
                }
            }
        }
        return nil
    }
    
    private func findActivityInBlock(activityId: String, in block: Cmi5ActivityBlock) -> Cmi5Activity? {
        // Check activities in this block
        if let activity = block.activities.first(where: { $0.activityId == activityId }) {
            return activity
        }
        
        // Check sub-blocks
        for subBlock in block.blocks {
            if let activity = findActivityInBlock(activityId: activityId, in: subBlock) {
                return activity
            }
        }
        
        return nil
    }
}

// MARK: - Mock Classes

class MockCmi5Repository {
    var packages: [Cmi5Package] = []
    
    func getAllPackages() async throws -> [Cmi5Package] {
        return packages
    }
}

class MockFileStorageService {
    func savePackage(id: UUID, from: URL) async throws -> URL {
        return URL(fileURLWithPath: "/mock/storage/\(id)")
    }
}

class MockCmi5ArchiveHandler {
    func extractArchive(from url: URL) async throws -> ExtractionResult {
        let tempPath = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
        
        return ExtractionResult(
            packageId: UUID().uuidString,
            extractedPath: tempPath,
            cmi5ManifestPath: tempPath.appendingPathComponent("cmi5.xml"),
            coursePath: tempPath
        )
    }
} 