//
//  Cmi5ImportIntegrationTests.swift
//  LMSTests
//
//  Integration tests for Cmi5 import functionality
//

import XCTest
@testable import LMS

@MainActor
final class Cmi5ImportIntegrationTests: XCTestCase {
    
    var viewModel: Cmi5ImportViewModel!
    
    override func setUp() async throws {
        try await super.setUp()
        viewModel = Cmi5ImportViewModel()
    }
    
    override func tearDown() async throws {
        viewModel = nil
        try await super.tearDown()
    }
    
    // MARK: - Demo Package Tests
    
    func testSelectDemoFile() async throws {
        // Given
        XCTAssertNil(viewModel.selectedFileInfo)
        XCTAssertNil(viewModel.parsedPackage)
        
        // When
        viewModel.selectDemoFile()
        
        // Wait for async processing
        try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
        
        // Then
        XCTAssertNotNil(viewModel.selectedFileInfo)
        XCTAssertEqual(viewModel.selectedFileInfo?.name, "sample-cmi5-course.zip")
        XCTAssertEqual(viewModel.selectedFileInfo?.type, "ZIP Archive")
        
        XCTAssertNotNil(viewModel.parsedPackage)
        XCTAssertEqual(viewModel.parsedPackage?.title, "Демо курс Cmi5")
        XCTAssertTrue(viewModel.parsedPackage?.isValid ?? false)
    }
    
    func testCanImportWithDemoPackage() async throws {
        // Given
        XCTAssertFalse(viewModel.canImport)
        
        // When
        viewModel.selectDemoFile()
        try await Task.sleep(nanoseconds: 3_000_000_000)
        
        // Then
        XCTAssertTrue(viewModel.canImport)
        XCTAssertNil(viewModel.error)
    }
    
    // MARK: - Validation Tests
    
    func testZipFileValidation() async throws {
        // Test that ZIP files with .zip extension pass initial validation
        let archiveHandler = Cmi5ArchiveHandler()
        
        // Create a temporary file with .zip extension
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("test.zip")
        
        // Write ZIP header
        let zipHeader = Data([0x50, 0x4B, 0x03, 0x04]) // PK\x03\x04
        try zipHeader.write(to: tempURL)
        
        defer {
            try? FileManager.default.removeItem(at: tempURL)
        }
        
        // Should not throw
        XCTAssertNoThrow(try archiveHandler.validateArchive(at: tempURL))
    }
    
    func testNonZipFileValidation() async throws {
        let archiveHandler = Cmi5ArchiveHandler()
        
        // Create a temporary file with wrong extension
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("test.txt")
        
        try "Not a ZIP file".write(to: tempURL, atomically: true, encoding: .utf8)
        
        defer {
            try? FileManager.default.removeItem(at: tempURL)
        }
        
        // Should throw unsupportedFormat error
        XCTAssertThrowsError(try archiveHandler.validateArchive(at: tempURL)) { error in
            if let archiveError = error as? Cmi5ArchiveHandler.ArchiveError {
                XCTAssertEqual(archiveError, .unsupportedFormat)
            } else {
                XCTFail("Expected ArchiveError.unsupportedFormat")
            }
        }
    }
    
    // MARK: - Error Message Tests
    
    func testExtractArchiveReturnsProperErrorMessage() async throws {
        let archiveHandler = Cmi5ArchiveHandler()
        
        // Create a valid ZIP file
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("test.zip")
        
        let zipHeader = Data([0x50, 0x4B, 0x03, 0x04])
        try zipHeader.write(to: tempURL)
        
        defer {
            try? FileManager.default.removeItem(at: tempURL)
        }
        
        // Should throw with specific message
        do {
            _ = try await archiveHandler.extractArchive(from: tempURL)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error.localizedDescription.contains("Распаковка ZIP архивов временно недоступна"))
            XCTAssertTrue(error.localizedDescription.contains("интеграция библиотеки"))
        }
    }
    
    // MARK: - UI State Tests
    
    func testClearSelection() {
        // Given
        viewModel.selectDemoFile()
        viewModel.error = "Some error"
        viewModel.validationWarnings = ["Warning 1", "Warning 2"]
        
        // When
        viewModel.clearSelection()
        
        // Then
        XCTAssertNil(viewModel.selectedFileInfo)
        XCTAssertNil(viewModel.parsedPackage)
        XCTAssertNil(viewModel.error)
        XCTAssertTrue(viewModel.validationWarnings.isEmpty)
    }
    
    func testClearError() {
        // Given
        viewModel.error = "Test error"
        
        // When
        viewModel.clearError()
        
        // Then
        XCTAssertNil(viewModel.error)
    }
}

// MARK: - Cmi5ArchiveHandler.ArchiveError Extension for Testing

extension Cmi5ArchiveHandler.ArchiveError: Equatable {
    public static func == (lhs: Cmi5ArchiveHandler.ArchiveError, rhs: Cmi5ArchiveHandler.ArchiveError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidArchive, .invalidArchive),
             (.manifestNotFound, .manifestNotFound),
             (.unsupportedFormat, .unsupportedFormat):
            return true
        case (.invalidManifest(let lhsDetails), .invalidManifest(let rhsDetails)):
            return lhsDetails == rhsDetails
        case (.extractionFailed(let lhsReason), .extractionFailed(let rhsReason)):
            return lhsReason == rhsReason
        case (.fileTooLarge(let lhsMax), .fileTooLarge(let rhsMax)):
            return lhsMax == rhsMax
        case (.invalidStructure(let lhsDetails), .invalidStructure(let rhsDetails)):
            return lhsDetails == rhsDetails
        default:
            return false
        }
    }
} 