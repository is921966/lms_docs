//
//  HTMLContentWrapperTests.swift
//  LMSTests
//
//  TDD тесты для HTMLContentWrapper
//

import XCTest
import SwiftUI
import WebKit
@testable import LMS

class HTMLContentWrapperTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        ComprehensiveLogger.shared.log(.test, .info, "Starting HTMLContentWrapperTests")
    }
    
    // MARK: - Test: WebView динамически подстраивает высоту
    
    func test_webView_dynamicallyAdjustsHeight() {
        // Given
        let htmlContent = """
            <h1>Test Header</h1>
            <p>This is a test paragraph with some content.</p>
            <ul>
                <li>Item 1</li>
                <li>Item 2</li>
                <li>Item 3</li>
            </ul>
            <p>More content to make the page longer.</p>
        """
        let wrapper = HTMLContentWrapper(htmlContent: htmlContent)
        
        // When
        let hostingController = UIHostingController(rootView: wrapper)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        
        // Wait for WebView to load
        let expectation = expectation(description: "WebView loads content")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Then - проверяем что высота больше минимальной
            if let webView = self.findWebView(in: hostingController.view) {
                XCTAssertTrue(webView.scrollView.contentSize.height > 200, 
                             "WebView should adjust height based on content")
                XCTAssertTrue(webView.scrollView.isScrollEnabled, 
                             "WebView should allow scrolling for large content")
            } else {
                XCTFail("WebView not found")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Test: Полный контент видим
    
    func test_fullContentIsVisible() {
        // Given
        let longContent = """
            <h1>Sprint 52 Report</h1>
            <h2>Основные достижения</h2>
            <ul>
                <li>Завершена миграция на Clean Architecture</li>
                <li>Реализован новый дизайн ленты новостей</li>
                <li>Улучшена производительность приложения</li>
                <li>Исправлены критические ошибки</li>
            </ul>
            <h2>Что нового</h2>
            <p>Новый интерфейс в стиле Telegram</p>
            <p>Папки для организации новостей</p>
            <p>Автоматическое обновление контента</p>
            <h2>Планы на следующий спринт</h2>
            <p>Интеграция с backend API</p>
            <p>Push уведомления</p>
            <p>Офлайн режим</p>
        """
        
        let wrapper = HTMLContentWrapper(htmlContent: longContent)
        
        // When
        let hostingController = UIHostingController(rootView: wrapper)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: 375, height: 667)
        
        let expectation = expectation(description: "Content fully loaded")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Then
            if let webView = self.findWebView(in: hostingController.view) {
                let contentHeight = webView.scrollView.contentSize.height
                XCTAssertTrue(contentHeight > 400, 
                             "Content height should be sufficient for all content")
                
                // Проверяем что контент не обрезается
                webView.evaluateJavaScript("document.body.scrollHeight") { (height, error) in
                    if let bodyHeight = height as? CGFloat {
                        XCTAssertEqual(contentHeight, bodyHeight, accuracy: 50,
                                      "WebView content size should match body scroll height")
                    }
                }
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    // MARK: - Test: Ссылки кликабельны
    
    func test_linksAreClickable() {
        // Given
        let htmlWithLinks = """
            <p>Check out <a href="https://example.com">this link</a></p>
            <p>Or visit <a href="https://apple.com">Apple</a></p>
        """
        
        let wrapper = HTMLContentWrapper(htmlContent: htmlWithLinks)
        let coordinator = wrapper.makeCoordinator()
        
        // When - симулируем клик по ссылке
        let webView = WKWebView()
        let navigationAction = MockNavigationAction(url: URL(string: "https://example.com")!)
        
        let expectation = expectation(description: "Link navigation handled")
        
        coordinator.webView(webView, decidePolicyFor: navigationAction) { policy in
            // Then
            XCTAssertEqual(policy, .cancel, "External links should be cancelled and opened in browser")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Helper Methods
    
    private func findWebView(in view: UIView) -> WKWebView? {
        if let webView = view as? WKWebView {
            return webView
        }
        
        for subview in view.subviews {
            if let webView = findWebView(in: subview) {
                return webView
            }
        }
        
        return nil
    }
}

// MARK: - Mock Navigation Action

class MockNavigationAction: WKNavigationAction {
    private let mockRequest: URLRequest
    private let mockNavigationType: WKNavigationType
    
    init(url: URL, navigationType: WKNavigationType = .linkActivated) {
        self.mockRequest = URLRequest(url: url)
        self.mockNavigationType = navigationType
        super.init()
    }
    
    override var request: URLRequest {
        return mockRequest
    }
    
    override var navigationType: WKNavigationType {
        return mockNavigationType
    }
} 