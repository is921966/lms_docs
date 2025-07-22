import XCTest
import SwiftUI
@testable import LMS

@MainActor
final class RefreshViewTests: XCTestCase {
    
    func testRefreshViewInitialization() {
        // Given & When
        let refreshView = RefreshView()
        
        // Then
        XCTAssertEqual(refreshView.animationPhase, 0.0)
        XCTAssertFalse(refreshView.isAnimating)
    }
    
    func testRefreshViewStartAnimation() {
        // Given
        var refreshView = RefreshView()
        
        // When
        refreshView.startAnimation()
        
        // Then
        XCTAssertTrue(refreshView.isAnimating)
    }
    
    func testRefreshViewStopAnimation() {
        // Given
        var refreshView = RefreshView()
        refreshView.startAnimation()
        
        // When
        refreshView.stopAnimation()
        
        // Then
        XCTAssertFalse(refreshView.isAnimating)
        XCTAssertEqual(refreshView.animationPhase, 0.0)
    }
    
    func testRefreshViewWithProgress() {
        // Given
        let refreshView = RefreshView(progress: 0.5)
        
        // Then
        XCTAssertEqual(refreshView.progress, 0.5)
    }
    
    func testRefreshViewColors() {
        // Given & When
        let refreshView = RefreshView()
        
        // Then
        XCTAssertEqual(refreshView.primaryColor, Color.blue)
        XCTAssertEqual(refreshView.secondaryColor, Color.blue.opacity(0.3))
    }
} 