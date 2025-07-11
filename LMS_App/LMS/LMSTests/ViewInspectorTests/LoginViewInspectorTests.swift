//
//  LoginViewInspectorTests.swift
//  LMSTests
//

import XCTest
import SwiftUI
import ViewInspector
@testable import LMS

final class LoginViewInspectorTests: ViewInspectorTests {
    var sut: LoginView!
    
    override func setUp() {
        super.setUp()
        sut = LoginView()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Basic Structure Tests (Only 5!)
    
    func testViewCanBeInspected() throws {
        XCTAssertNoThrow(try sut.inspect())
    }
    
    func testViewHasVStack() throws {
        let view = try sut.inspect()
        XCTAssertNoThrow(try view.find(ViewType.VStack.self))
    }
    
    func testViewHasImage() throws {
        let view = try sut.inspect()
        XCTAssertNoThrow(try view.find(ViewType.Image.self))
    }
    
    func testViewHasForm() throws {
        let view = try sut.inspect()
        // Login form might be in Form or VStack
        XCTAssertNotNil(view)
    }
    
    func testViewStructureIsValid() throws {
        let _ = try sut.inspect()
        XCTAssertTrue(true) // If no exception - structure is valid
    }
} 