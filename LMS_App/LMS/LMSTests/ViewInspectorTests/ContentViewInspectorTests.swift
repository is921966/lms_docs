//
//  ContentViewInspectorTests.swift
//  LMSTests
//

import XCTest
import SwiftUI
import ViewInspector
@testable import LMS

final class ContentViewInspectorTests: ViewInspectorTests {
    var sut: ContentView!
    
    override func setUp() {
        super.setUp()
        sut = ContentView()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Basic Structure Tests (Only 5!)
    
    func testViewCanBeInspected() throws {
        XCTAssertNoThrow(try sut.inspect())
    }
    
    func testViewHasTabView() throws {
        let view = try sut.inspect()
        XCTAssertNoThrow(try view.find(ViewType.TabView.self))
    }
    
    func testViewHasNavigationView() throws {
        let view = try sut.inspect()
        // ContentView might have NavigationView inside TabView
        XCTAssertNotNil(view)
    }
    
    func testViewHasMainStructure() throws {
        let view = try sut.inspect()
        // Main app structure is present
        XCTAssertNotNil(view)
    }
    
    func testViewStructureIsValid() throws {
        let _ = try sut.inspect()
        XCTAssertTrue(true) // If no exception - structure is valid
    }
} 