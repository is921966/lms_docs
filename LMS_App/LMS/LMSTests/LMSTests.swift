//
//  LMSTests.swift
//  LMSTests
//
//  Created by Igor Shirokov on 24.06.2025.
//

import Testing
import SwiftUI
@testable import LMS

struct LMSTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        #expect(true, "Basic test should pass")
    }
    
    @Test func testAppInitialization() async throws {
        // Test that the app can be initialized
        let app = LMSApp()
        #expect(app != nil, "App should be initialized")
    }
    
    @Test func testContentViewCreation() async throws {
        // Test that ContentView can be created
        let contentView = ContentView()
        #expect(contentView != nil, "ContentView should be created")
    }

}
