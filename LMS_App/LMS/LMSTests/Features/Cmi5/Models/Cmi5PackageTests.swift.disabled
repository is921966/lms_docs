//
//  Cmi5PackageTests.swift
//  LMSTests
//
//  Created on Sprint 40 Day 1 - Cmi5 Integration
//

import XCTest
@testable import LMS

final class Cmi5PackageTests: XCTestCase {
    
    // MARK: - Test Creation and Basic Properties
    
    func testCmi5PackageCreation() {
        // Arrange
        let packageId = UUID()
        let courseId = UUID()
        let uploadedBy = UUID()
        let packageName = "Sales Training Module"
        let packageVersion = "1.0.0"
        let fileSize: Int64 = 1024 * 1024 * 10 // 10MB
        
        // Act
        let package = Cmi5Package(
            id: packageId,
            courseId: courseId,
            packageName: packageName,
            packageVersion: packageVersion,
            manifest: Cmi5Manifest.empty(),
            activities: [],
            uploadedAt: Date(),
            uploadedBy: uploadedBy,
            fileSize: fileSize,
            status: .processing
        )
        
        // Assert
        XCTAssertEqual(package.id, packageId)
        XCTAssertEqual(package.courseId, courseId)
        XCTAssertEqual(package.packageName, packageName)
        XCTAssertEqual(package.packageVersion, packageVersion)
        XCTAssertEqual(package.uploadedBy, uploadedBy)
        XCTAssertEqual(package.fileSize, fileSize)
        XCTAssertEqual(package.status, .processing)
        XCTAssertTrue(package.activities.isEmpty)
    }
    
    func testPackageStatusTransitions() {
        // Arrange
        var package = Cmi5Package(
            id: UUID(),
            courseId: nil,
            packageName: "Test Package",
            packageVersion: nil,
            manifest: Cmi5Manifest.empty(),
            activities: [],
            uploadedAt: Date(),
            uploadedBy: UUID(),
            fileSize: 5000,
            status: .processing
        )
        
        // Act & Assert - Processing to Valid
        package.status = .valid
        XCTAssertEqual(package.status, .valid)
        
        // Act & Assert - Valid to Archived
        package.status = .archived
        XCTAssertEqual(package.status, .archived)
        
        // Act & Assert - Processing to Invalid
        package.status = .invalid
        XCTAssertEqual(package.status, .invalid)
    }
    
    func testPackageWithActivities() {
        // Arrange
        let packageId = UUID()
        let activity1 = Cmi5Activity(
            id: UUID(),
            packageId: packageId,
            activityId: "activity-001",
            title: "Introduction to Sales",
            description: "Basic sales concepts",
            launchUrl: "content/intro/index.html",
            launchMethod: .anyWindow,
            moveOn: .completed,
            masteryScore: nil,
            activityType: "http://adlnet.gov/expapi/activities/module",
            duration: "PT30M"
        )
        
        let activity2 = Cmi5Activity(
            id: UUID(),
            packageId: packageId,
            activityId: "activity-002",
            title: "Advanced Sales Techniques",
            description: "Complex sales strategies",
            launchUrl: "content/advanced/index.html",
            launchMethod: .ownWindow,
            moveOn: .passed,
            masteryScore: 0.8,
            activityType: "http://adlnet.gov/expapi/activities/assessment",
            duration: "PT45M"
        )
        
        // Act
        let package = Cmi5Package(
            id: packageId,
            courseId: UUID(),
            packageName: "Complete Sales Training",
            packageVersion: "2.0.0",
            manifest: Cmi5Manifest.empty(),
            activities: [activity1, activity2],
            uploadedAt: Date(),
            uploadedBy: UUID(),
            fileSize: 25 * 1024 * 1024,
            status: .valid
        )
        
        // Assert
        XCTAssertEqual(package.activities.count, 2)
        XCTAssertEqual(package.activities[0].title, "Introduction to Sales")
        XCTAssertEqual(package.activities[1].title, "Advanced Sales Techniques")
        XCTAssertEqual(package.activities[0].launchMethod, .anyWindow)
        XCTAssertEqual(package.activities[1].launchMethod, .ownWindow)
        XCTAssertEqual(package.activities[1].masteryScore, 0.8)
    }
    
    func testPackageFileSizeFormatting() {
        // Arrange
        let smallPackage = Cmi5Package(
            id: UUID(),
            courseId: nil,
            packageName: "Small Package",
            packageVersion: nil,
            manifest: Cmi5Manifest.empty(),
            activities: [],
            uploadedAt: Date(),
            uploadedBy: UUID(),
            fileSize: 512 * 1024, // 512KB
            status: .valid
        )
        
        let mediumPackage = Cmi5Package(
            id: UUID(),
            courseId: nil,
            packageName: "Medium Package",
            packageVersion: nil,
            manifest: Cmi5Manifest.empty(),
            activities: [],
            uploadedAt: Date(),
            uploadedBy: UUID(),
            fileSize: 15 * 1024 * 1024, // 15MB
            status: .valid
        )
        
        let largePackage = Cmi5Package(
            id: UUID(),
            courseId: nil,
            packageName: "Large Package",
            packageVersion: nil,
            manifest: Cmi5Manifest.empty(),
            activities: [],
            uploadedAt: Date(),
            uploadedBy: UUID(),
            fileSize: 2 * 1024 * 1024 * 1024, // 2GB
            status: .valid
        )
        
        // Assert
        XCTAssertEqual(smallPackage.formattedFileSize, "512 KB")
        XCTAssertEqual(mediumPackage.formattedFileSize, "15 MB")
        XCTAssertEqual(largePackage.formattedFileSize, "2 GB")
    }
    
    func testPackageCodable() throws {
        // Arrange
        let package = Cmi5Package(
            id: UUID(),
            courseId: UUID(),
            packageName: "Test Package",
            packageVersion: "1.0.0",
            manifest: Cmi5Manifest.empty(),
            activities: [],
            uploadedAt: Date(),
            uploadedBy: UUID(),
            fileSize: 1000000,
            status: .valid
        )
        
        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(package)
        
        let decoder = JSONDecoder()
        let decodedPackage = try decoder.decode(Cmi5Package.self, from: data)
        
        // Assert
        XCTAssertEqual(decodedPackage.id, package.id)
        XCTAssertEqual(decodedPackage.packageName, package.packageName)
        XCTAssertEqual(decodedPackage.packageVersion, package.packageVersion)
        XCTAssertEqual(decodedPackage.status, package.status)
        XCTAssertEqual(decodedPackage.fileSize, package.fileSize)
    }
    
    func testPackageValidation() {
        // Arrange
        let validPackage = Cmi5Package(
            id: UUID(),
            courseId: UUID(),
            packageName: "Valid Package",
            packageVersion: "1.0.0",
            manifest: Cmi5Manifest(
                identifier: "com.example.course",
                title: "Example Course",
                description: "Test description",
                moreInfo: nil,
                vendor: nil,
                course: Cmi5Course(
                    id: "course-001",
                    title: "Test Course",
                    description: "Course description",
                    auCount: 2
                )
            ),
            activities: [
                Cmi5Activity(
                    id: UUID(),
                    packageId: UUID(),
                    activityId: "activity-001",
                    title: "Test Activity",
                    description: nil,
                    launchUrl: "content/index.html",
                    launchMethod: .anyWindow,
                    moveOn: .completed,
                    masteryScore: nil,
                    activityType: "http://adlnet.gov/expapi/activities/module",
                    duration: nil
                )
            ],
            uploadedAt: Date(),
            uploadedBy: UUID(),
            fileSize: 1000000,
            status: .valid
        )
        
        let invalidPackage = Cmi5Package(
            id: UUID(),
            courseId: nil,
            packageName: "",
            packageVersion: nil,
            manifest: Cmi5Manifest.empty(),
            activities: [],
            uploadedAt: Date(),
            uploadedBy: UUID(),
            fileSize: 0,
            status: .invalid
        )
        
        // Assert
        XCTAssertTrue(validPackage.isValid)
        XCTAssertFalse(invalidPackage.isValid)
        
        XCTAssertNil(validPackage.validationErrors())
        XCTAssertNotNil(invalidPackage.validationErrors())
    }
}

// MARK: - Mock Helpers
// empty() method is defined in Cmi5Models.swift 