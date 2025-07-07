#!/bin/bash
# create-simple-test.sh - Создает упрощенный ViewInspector тест

if [ -z "$1" ]; then
    echo "Usage: ./create-simple-test.sh ViewName"
    echo "Example: ./create-simple-test.sh NotificationListView"
    exit 1
fi

VIEW_NAME=$1
TEST_FILE="LMSTests/ViewInspectorTests/${VIEW_NAME}InspectorTests.swift"

# Создаем директорию если не существует
mkdir -p LMSTests/ViewInspectorTests

# Проверяем, существует ли файл
if [ -f "$TEST_FILE" ]; then
    echo "⚠️  File $TEST_FILE already exists!"
    read -p "Overwrite? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Создаем тестовый файл
cat > "$TEST_FILE" << EOF
//
//  ${VIEW_NAME}InspectorTests.swift
//  LMSTests
//
//  Created on $(date +%Y-%m-%d).
//

import XCTest
import SwiftUI
import ViewInspector
@testable import LMS

final class ${VIEW_NAME}InspectorTests: ViewInspectorTests {
    var sut: ${VIEW_NAME}!
    
    override func setUp() {
        super.setUp()
        sut = ${VIEW_NAME}()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Basic Structure Tests
    
    func testViewCanBeInspected() throws {
        XCTAssertNoThrow(try sut.inspect())
    }
    
    func testViewHasContent() throws {
        let view = try sut.inspect()
        XCTAssertNotNil(view)
    }
    
    func testViewHasVStack() throws {
        let view = try sut.inspect()
        XCTAssertNoThrow(try view.find(ViewType.VStack.self))
    }
    
    func testViewStructureIsValid() throws {
        XCTAssertNoThrow(try sut.inspect())
    }
    
    func testViewIsNotEmpty() throws {
        let view = try sut.inspect()
        XCTAssertNotNil(view)
    }
    
    // MARK: - Additional Tests (customize based on view)
    
    /*
    func testViewHasNavigationTitle() throws {
        let view = try sut.inspect()
        XCTAssertNoThrow(try view.find(text: "Title"))
    }
    
    func testViewHasList() throws {
        let view = try sut.inspect()
        XCTAssertNoThrow(try view.find(ViewType.List.self))
    }
    
    func testViewHasButton() throws {
        let view = try sut.inspect()
        XCTAssertNoThrow(try view.find(button: "Button Text"))
    }
    
    func testViewHasImage() throws {
        let view = try sut.inspect()
        XCTAssertNoThrow(try view.find(ViewType.Image.self))
    }
    
    func testViewHasTextField() throws {
        let view = try sut.inspect()
        XCTAssertNoThrow(try view.find(ViewType.TextField.self))
    }
    */
}
EOF

echo "✅ Created $TEST_FILE"
echo ""
echo "Next steps:"
echo "1. Uncomment and adapt additional tests based on the view content"
echo "2. Run: xcodebuild test -scheme LMS -only-testing:LMSTests/${VIEW_NAME}InspectorTests"
echo "3. Check compilation and fix any issues" 