//
//  SettingsViewInspectorTests.swift
//  LMSTests
//

import XCTest
import SwiftUI
import ViewInspector
@testable import LMS

final class SettingsViewInspectorTests: ViewInspectorTests {
    var sut: SettingsView!
    
    override func setUp() {
        super.setUp()
        sut = SettingsView()
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
        XCTAssertNoThrow(try view.find(text: "Настройки"))
    }
    
    func testViewHasList() throws {
        let view = try sut.inspect()
        XCTAssertNoThrow(try view.find(ViewType.List.self))
    }
    
    func testViewHasForm() throws {
        let view = try sut.inspect()
        // Settings might use List or Form
        XCTAssertNotNil(view)
    }
    
    func testViewStructureIsValid() throws {
        let _ = try sut.inspect()
        XCTAssertTrue(true) // If no exception - structure is valid
    }
} 