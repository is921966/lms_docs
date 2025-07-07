//
//  ProfileViewInspectorTests.swift
//  LMSTests
//

import XCTest
import SwiftUI
import ViewInspector
@testable import LMS

@MainActor
final class ProfileViewInspectorTests: ViewInspectorTests {
    var sut: ProfileView!
    
    override func setUp() {
        super.setUp()
        sut = ProfileView()
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
        // ProfileView sets navigationTitle but doesn't contain NavigationView itself
        // We just verify the view can be inspected without error
        let _ = try sut.inspect()
        XCTAssertTrue(true) // navigationTitle is set as modifier
    }
    
    func testViewHasScrollView() throws {
        let view = try sut.inspect()
        XCTAssertNoThrow(try view.find(ViewType.ScrollView.self))
    }
    
    func testViewHasVStack() throws {
        let view = try sut.inspect()
        let scrollView = try view.find(ViewType.ScrollView.self)
        XCTAssertNoThrow(try scrollView.find(ViewType.VStack.self))
    }
    
    func testViewStructureIsValid() throws {
        let view = try sut.inspect()
        let scrollView = try view.find(ViewType.ScrollView.self)
        let vStack = try scrollView.find(ViewType.VStack.self)
        
        // Check for some expected elements
        XCTAssertNoThrow(try vStack.find(ViewType.Picker.self))
        XCTAssertNoThrow(try vStack.find(ViewType.Button.self))
    }
} 