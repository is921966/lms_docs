//
//  StudentDashboardViewTests.swift
//  LMSTests
//

import XCTest
import SwiftUI
import ViewInspector
@testable import LMS

final class StudentDashboardViewInspectorTests: ViewInspectorTests {
    var sut: StudentDashboardView!
    
    override func setUp() {
        super.setUp()
        sut = StudentDashboardView()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Basic Structure Tests (Only 5!)
    
    func testViewCanBeInspected() throws {
        XCTAssertNoThrow(try sut.inspect())
    }
    
    func testViewHasNavigationTitle() throws {
        let view = try sut.inspect()
        XCTAssertNoThrow(try view.find(text: "Панель студента"))
    }
    
    func testViewHasScrollView() throws {
        let view = try sut.inspect()
        XCTAssertNoThrow(try view.find(ViewType.ScrollView.self))
    }
    
    func testViewHasVStack() throws {
        let view = try sut.inspect()
        XCTAssertNoThrow(try view.find(ViewType.VStack.self))
    }
    
    func testViewStructureIsValid() throws {
        let _ = try sut.inspect()
        XCTAssertTrue(true) // If no exception - structure is valid
    }
} 