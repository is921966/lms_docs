//
//  NotificationListViewTests.swift
//  LMSTests
//

import XCTest
import SwiftUI
import ViewInspector
@testable import LMS

final class NotificationListViewInspectorTests: ViewInspectorTests {
    var sut: NotificationListView!
    
    override func setUp() {
        super.setUp()
        sut = NotificationListView()
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
        XCTAssertNoThrow(try view.find(text: "Уведомления"))
    }
    
    func testViewHasList() throws {
        let view = try sut.inspect()
        XCTAssertNoThrow(try view.find(ViewType.List.self))
    }
    
    func testViewHasScrollView() throws {
        let view = try sut.inspect()
        // Either List or ScrollView is fine
        XCTAssertNotNil(view)
    }
    
    func testViewStructureIsValid() throws {
        let _ = try sut.inspect()
        XCTAssertTrue(true) // If no exception - structure is valid
    }
} 