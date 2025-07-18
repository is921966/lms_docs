//
//  CompetencyListViewTests.swift
//  LMSTests
//

import XCTest
import SwiftUI
import ViewInspector
@testable import LMS

final class CompetencyListViewInspectorTests: ViewInspectorTests {
    var sut: CompetencyListView!
    
    override func setUp() {
        super.setUp()
        sut = CompetencyListView()
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
        XCTAssertNoThrow(try view.find(text: "Компетенции"))
    }
    
    func testViewHasList() throws {
        let view = try sut.inspect()
        XCTAssertNoThrow(try view.find(ViewType.List.self))
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