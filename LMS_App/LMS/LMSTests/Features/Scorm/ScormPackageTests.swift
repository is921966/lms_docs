import XCTest
@testable import LMS

final class ScormPackageTests: XCTestCase {
    
    // MARK: - Test 1: ScormPackage should have required properties
    func test_scormPackage_shouldHaveRequiredProperties() {
        // Given
        let title = "Test SCORM Course"
        let version = "SCORM 2004 4th Edition"
        let fileSize: Int64 = 1024000
        let scoCount = 5
        let importDate = Date()
        let manifestPath = "/scorm/test/imsmanifest.xml"
        let contentPath = "/scorm/test/"
        
        // When
        let package = ScormPackage(
            title: title,
            description: nil,
            version: version,
            organization: nil,
            scoCount: scoCount,
            fileSize: fileSize,
            importDate: importDate,
            manifestPath: manifestPath,
            contentPath: contentPath
        )
        
        // Then
        XCTAssertNotNil(package.id)
        XCTAssertEqual(package.title, title)
        XCTAssertNil(package.description)
        XCTAssertEqual(package.version, version)
        XCTAssertNil(package.organization)
        XCTAssertEqual(package.scoCount, scoCount)
        XCTAssertEqual(package.fileSize, fileSize)
        XCTAssertEqual(package.importDate, importDate)
        XCTAssertEqual(package.manifestPath, manifestPath)
        XCTAssertEqual(package.contentPath, contentPath)
    }
    
    // MARK: - Test 2: Formatted size should display correctly
    func test_formattedSize_shouldDisplayCorrectly() {
        // Given
        let package1 = createPackage(fileSize: 1024) // 1 KB
        let package2 = createPackage(fileSize: 1048576) // 1 MB
        let package3 = createPackage(fileSize: 1073741824) // 1 GB
        
        // When & Then
        XCTAssertEqual(package1.formattedSize, "1 KB")
        XCTAssertEqual(package2.formattedSize, "1 MB")
        XCTAssertEqual(package3.formattedSize, "1 GB")
    }
    
    // MARK: - Test 3: Formatted date should be in Russian locale
    func test_formattedDate_shouldBeInRussianLocale() {
        // Given
        let dateComponents = DateComponents(year: 2025, month: 7, day: 22, hour: 15, minute: 30)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        let package = createPackage(importDate: date)
        
        // When
        let formattedDate = package.formattedDate
        
        // Then
        XCTAssertTrue(formattedDate.contains("июл"))
        XCTAssertTrue(formattedDate.contains("2025"))
        XCTAssertTrue(formattedDate.contains("15:30"))
    }
    
    // MARK: - Helper
    private func createPackage(
        fileSize: Int64 = 1024000,
        importDate: Date = Date()
    ) -> ScormPackage {
        return ScormPackage(
            title: "Test Package",
            description: nil,
            version: "SCORM 2004",
            organization: nil,
            scoCount: 1,
            fileSize: fileSize,
            importDate: importDate,
            manifestPath: "/test/manifest.xml",
            contentPath: "/test/"
        )
    }
} 