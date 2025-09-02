import XCTest
@testable import LMS

final class OrgStructureUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        
        // Ждем загрузки приложения
        sleep(2)
        
        // Переходим к экрану More
        let moreTab = app.tabBars.buttons["Ещё"]
        if moreTab.exists {
            moreTab.tap()
            sleep(1)
        }
    }
    
    // MARK: - Navigation Tests
    
    func testNavigateToOrgStructure() throws {
        // Tap on OrgStructure menu item
        let orgStructureCell = app.cells.staticTexts["Оргструктура"]
        XCTAssertTrue(orgStructureCell.waitForExistence(timeout: 5))
        orgStructureCell.tap()
        
        // Verify we're on OrgStructure screen
        XCTAssertTrue(app.navigationBars["Оргструктура компании"].exists)
    }
    
    // MARK: - Department Tree Tests
    
    func testExpandCollapseDepartment() throws {
        // Navigate to OrgStructure
        navigateToOrgStructure()
        
        // Find a department with children (IT Department)
        let itDepartment = app.otherElements.staticTexts["IT Департамент"]
        XCTAssertTrue(itDepartment.waitForExistence(timeout: 5))
        
        // Tap to expand
        itDepartment.tap()
        sleep(1)
        
        // Check if child departments are visible
        let developmentDept = app.otherElements.staticTexts["Отдел Разработки"]
        XCTAssertTrue(developmentDept.exists)
        
        // Tap again to collapse
        itDepartment.tap()
        Thread.sleep(forTimeInterval: 0.5)
        
        // Check if child departments are hidden
        XCTAssertFalse(developmentDept.exists)
    }
    
    func testSwitchTreeListView() throws {
        // Navigate to OrgStructure
        navigateToOrgStructure()
        
        // Switch to list view
        let listViewButton = app.buttons["list.bullet"]
        if listViewButton.exists {
            listViewButton.tap()
            Thread.sleep(forTimeInterval: 0.5)
            
            // Verify list view is shown
            let firstRow = app.otherElements.buttons.element(boundBy: 0)
            XCTAssertTrue(firstRow.exists)
        }
        
        // Switch back to tree view
        let treeViewButton = app.buttons["chart.bar.doc.horizontal"]
        if treeViewButton.exists {
            treeViewButton.tap()
            Thread.sleep(forTimeInterval: 0.5)
        }
    }
    
    // MARK: - Department Detail Tests
    
    func testOpenDepartmentDetail() throws {
        // Navigate to OrgStructure
        navigateToOrgStructure()
        
        // Expand IT Department
        let itDepartment = app.otherElements.staticTexts["IT Департамент"]
        itDepartment.tap()
        Thread.sleep(forTimeInterval: 0.5)
        
        // Tap on Development Department
        let developmentDept = app.otherElements.staticTexts["Отдел Разработки"]
        developmentDept.tap()
        
        // Verify department detail is shown
        XCTAssertTrue(app.navigationBars["Отдел Разработки"].exists)
        
        // Check for department info
        XCTAssertTrue(app.staticTexts["Код: АП.2.1"].exists)
        XCTAssertTrue(app.staticTexts["Сотрудников: 3"].exists)
    }
    
    func testDepartmentBreadcrumb() throws {
        // Navigate to department detail
        navigateToOrgStructure()
        let itDepartment = app.otherElements.staticTexts["IT Департамент"]
        itDepartment.tap()
        Thread.sleep(forTimeInterval: 0.5)
        
        let developmentDept = app.otherElements.staticTexts["Отдел Разработки"]
        developmentDept.tap()
        
        // Check breadcrumb navigation
        XCTAssertTrue(app.staticTexts["ЦУМ"].exists)
        XCTAssertTrue(app.images["chevron.right"].exists)
        XCTAssertTrue(app.staticTexts["IT Департамент"].exists)
    }
    
    // MARK: - Employee Tests
    
    func testViewEmployeeInDepartment() throws {
        // Navigate to department detail
        navigateToOrgStructure()
        let itDepartment = app.otherElements.staticTexts["IT Департамент"]
        itDepartment.tap()
        Thread.sleep(forTimeInterval: 0.5)
        
        let developmentDept = app.otherElements.staticTexts["Отдел Разработки"]
        developmentDept.tap()
        
        // Check employees are listed
        XCTAssertTrue(app.staticTexts["Козлов Дмитрий Андреевич"].exists)
        XCTAssertTrue(app.staticTexts["Senior-разработчик"].exists)
    }
    
    func testOpenEmployeeDetail() throws {
        // Navigate to employee detail
        navigateToOrgStructure()
        let itDepartment = app.otherElements.staticTexts["IT Департамент"]
        itDepartment.tap()
        Thread.sleep(forTimeInterval: 0.5)
        
        let developmentDept = app.otherElements.staticTexts["Отдел Разработки"]
        developmentDept.tap()
        
        // Tap on employee
        let employeeRow = app.otherElements.containing(.staticText, identifier: "Козлов Дмитрий Андреевич").element
        employeeRow.tap()
        
        // Verify employee detail is shown
        XCTAssertTrue(app.navigationBars["Карточка сотрудника"].exists)
        XCTAssertTrue(app.staticTexts["АР21000620"].exists)
        XCTAssertTrue(app.staticTexts["Senior-разработчик"].exists)
    }
    
    // MARK: - Search Tests
    
    func testSearchEmployee() throws {
        // Navigate to OrgStructure
        navigateToOrgStructure()
        
        // Tap search button
        let searchButton = app.buttons["magnifyingglass"]
        XCTAssertTrue(searchButton.waitForExistence(timeout: 5))
        searchButton.tap()
        
        // Type in search field
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("Иванов")
        
        // Check search results
        sleep(1)
        XCTAssertTrue(app.staticTexts["Иванов Иван Иванович"].exists)
        XCTAssertTrue(app.staticTexts["CEO"].exists)
    }
    
    func testSearchClearResults() throws {
        // Navigate to OrgStructure and search
        navigateToOrgStructure()
        let searchButton = app.buttons["magnifyingglass"]
        searchButton.tap()
        
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("xyz123")
        
        // Check no results
        sleep(1)
        XCTAssertTrue(app.staticTexts["Сотрудники не найдены"].exists)
        
        // Clear search
        let clearButton = app.buttons["xmark.circle.fill"]
        if clearButton.exists {
            clearButton.tap()
        }
    }
    
    // MARK: - Import Tests
    
    func testOpenImportDialog() throws {
        // Navigate to OrgStructure
        navigateToOrgStructure()
        
        // Tap import button
        let importButton = app.buttons["square.and.arrow.down"]
        XCTAssertTrue(importButton.waitForExistence(timeout: 5))
        importButton.tap()
        
        // Verify import sheet is shown
        XCTAssertTrue(app.staticTexts["Импорт оргструктуры"].exists)
        XCTAssertTrue(app.buttons["Выбрать Excel файл"].exists)
        
        // Check import modes
        XCTAssertTrue(app.staticTexts["Режим импорта"].exists)
        XCTAssertTrue(app.radioButtons["Объединить"].exists)
        XCTAssertTrue(app.radioButtons["Заменить"].exists)
        
        // Cancel import
        let cancelButton = app.buttons["Отмена"]
        cancelButton.tap()
    }
    
    // MARK: - Performance Tests
    
    func testLaunchPerformance() throws {
        if #available(iOS 17.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func navigateToOrgStructure() {
        let orgStructureCell = app.cells.staticTexts["Оргструктура"]
        if orgStructureCell.exists {
            orgStructureCell.tap()
            sleep(1)
        }
    }
} 