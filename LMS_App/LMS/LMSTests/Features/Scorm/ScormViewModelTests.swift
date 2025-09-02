import XCTest
@testable import LMS

final class ScormViewModelTests: XCTestCase {
    
    var sut: ScormViewModel!
    
    override func setUp() {
        super.setUp()
        sut = ScormViewModel()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Test 1: ViewModel should load demo packages on init
    func test_init_shouldLoadDemoPackages() {
        // Given - setUp creates ViewModel
        
        // When - init is called in setUp
        
        // Then
        XCTAssertFalse(sut.packages.isEmpty)
        XCTAssertEqual(sut.packages.count, 2)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }
    
    // MARK: - Test 2: Import should add new package
    func test_importScormPackage_shouldAddNewPackage() async {
        // Given
        let initialCount = sut.packages.count
        let testURL = URL(fileURLWithPath: "/test/scorm.zip")
        let expectation = XCTestExpectation(description: "Import completed")
        
        // When
        sut.importScormPackage(from: testURL) { success, message in
            // Then
            XCTAssertTrue(success)
            XCTAssertEqual(message, "SCORM пакет успешно импортирован")
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 3.0)
        
        XCTAssertEqual(sut.packages.count, initialCount + 1)
        XCTAssertFalse(sut.isLoading)
    }
    
    // MARK: - Test 3: Delete should remove package
    func test_deletePackage_shouldRemoveFromList() {
        // Given
        let packageToDelete = sut.packages.first!
        let initialCount = sut.packages.count
        
        // When
        sut.deletePackage(packageToDelete)
        
        // Then
        XCTAssertEqual(sut.packages.count, initialCount - 1)
        XCTAssertFalse(sut.packages.contains { $0.id == packageToDelete.id })
    }
    
    // MARK: - Test 4: Demo packages should have correct properties
    func test_demoPackages_shouldHaveCorrectProperties() {
        // Given
        let firstPackage = sut.packages.first!
        let secondPackage = sut.packages[1]
        
        // Then - First package
        XCTAssertEqual(firstPackage.title, "Основы продаж в ЦУМ")
        XCTAssertEqual(firstPackage.organization, "ЦУМ Академия")
        XCTAssertEqual(firstPackage.scoCount, 5)
        XCTAssertEqual(firstPackage.version, "SCORM 2004 4th Edition")
        
        // Then - Second package
        XCTAssertEqual(secondPackage.title, "Клиентский сервис Premium")
        XCTAssertEqual(secondPackage.organization, "ЦУМ Академия")
        XCTAssertEqual(secondPackage.scoCount, 8)
        XCTAssertEqual(secondPackage.version, "SCORM 2004 3rd Edition")
    }
} 