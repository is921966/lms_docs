import XCTest
import SwiftUI
@testable import LMS

@MainActor
final class MarkdownContentViewTests: XCTestCase {
    
    func testMarkdownContentViewWithPlainText() {
        // Given
        let plainText = "This is plain text"
        
        // When
        let view = MarkdownContentView(text: plainText)
        
        // Then
        XCTAssertNotNil(view)
        XCTAssertEqual(view.text, plainText)
    }
    
    func testMarkdownContentViewWithBoldText() {
        // Given
        let markdownText = "This is **bold** text"
        
        // When
        let view = MarkdownContentView(text: markdownText)
        
        // Then
        XCTAssertNotNil(view)
        XCTAssertTrue(view.text.contains("**"))
    }
    
    func testMarkdownContentViewWithItalicText() {
        // Given
        let markdownText = "This is *italic* text"
        
        // When
        let view = MarkdownContentView(text: markdownText)
        
        // Then
        XCTAssertNotNil(view)
        XCTAssertTrue(view.text.contains("*"))
    }
    
    func testMarkdownContentViewWithLinks() {
        // Given
        let markdownText = "Check out [our website](https://example.com)"
        
        // When
        let view = MarkdownContentView(text: markdownText)
        
        // Then
        XCTAssertNotNil(view)
        XCTAssertTrue(view.text.contains("["))
        XCTAssertTrue(view.text.contains("]("))
    }
    
    func testMarkdownContentViewWithHeaders() {
        // Given
        let markdownText = "# Header 1\n## Header 2\n### Header 3"
        
        // When
        let view = MarkdownContentView(text: markdownText)
        
        // Then
        XCTAssertNotNil(view)
        XCTAssertTrue(view.text.contains("#"))
    }
    
    func testMarkdownContentViewWithLists() {
        // Given
        let markdownText = """
        - Item 1
        - Item 2
        - Item 3
        
        1. First
        2. Second
        3. Third
        """
        
        // When
        let view = MarkdownContentView(text: markdownText)
        
        // Then
        XCTAssertNotNil(view)
        XCTAssertTrue(view.text.contains("-"))
        XCTAssertTrue(view.text.contains("1."))
    }
    
    func testMarkdownContentViewWithCodeBlocks() {
        // Given
        let markdownText = """
        Here is some code:
        ```swift
        let message = "Hello, World!"
        print(message)
        ```
        """
        
        // When
        let view = MarkdownContentView(text: markdownText)
        
        // Then
        XCTAssertNotNil(view)
        XCTAssertTrue(view.text.contains("```"))
    }
    
    func testMarkdownContentViewWithMixedContent() {
        // Given
        let markdownText = """
        # Welcome
        
        This is **important** information with *emphasis*.
        
        Check [this link](https://example.com) for more.
        
        - Feature 1
        - Feature 2
        
        ```
        code example
        ```
        """
        
        // When
        let view = MarkdownContentView(text: markdownText)
        
        // Then
        XCTAssertNotNil(view)
        XCTAssertTrue(view.text.contains("#"))
        XCTAssertTrue(view.text.contains("**"))
        XCTAssertTrue(view.text.contains("*"))
        XCTAssertTrue(view.text.contains("["))
        XCTAssertTrue(view.text.contains("-"))
        XCTAssertTrue(view.text.contains("```"))
    }
} 