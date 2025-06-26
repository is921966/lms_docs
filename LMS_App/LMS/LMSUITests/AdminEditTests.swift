//
//  AdminEditTests.swift
//  LMSUITests
//
//  Created on 26/01/2025.
//

import XCTest

final class AdminEditTests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testCourseEditSavesChanges() throws {
        // Логинимся как администратор
        loginAsAdmin()
        
        // Переходим к курсам
        app.tabBars.buttons["Обучение"].tap()
        
        // Ждем загрузки списка
        let coursesList = app.scrollViews.firstMatch
        XCTAssertTrue(coursesList.waitForExistence(timeout: 5))
        
        // Проверяем наличие кнопки редактирования
        let firstCourseEditButton = app.buttons.matching(identifier: "pencil.circle.fill").firstMatch
        XCTAssertTrue(firstCourseEditButton.exists, "Кнопка редактирования должна быть видна для администратора")
        
        // Нажимаем редактировать
        firstCourseEditButton.tap()
        
        // Ждем появления формы редактирования
        let editForm = app.navigationBars["Редактирование курса"]
        XCTAssertTrue(editForm.waitForExistence(timeout: 5))
        
        // Изменяем название курса
        let titleField = app.textFields.firstMatch
        titleField.tap()
        titleField.clearAndTypeText("Обновленный курс продаж")
        
        // Сохраняем
        app.buttons["Сохранить"].tap()
        
        // Проверяем появление алерта
        let successAlert = app.alerts["Изменения сохранены"]
        XCTAssertTrue(successAlert.waitForExistence(timeout: 3))
        successAlert.buttons["OK"].tap()
        
        // Проверяем, что название изменилось в списке
        XCTAssertTrue(app.staticTexts["Обновленный курс продаж"].waitForExistence(timeout: 3))
    }
    
    func testTestEditSavesChanges() throws {
        // Логинимся как администратор
        loginAsAdmin()
        
        // Переходим к тестам
        app.tabBars.buttons["Тесты"].tap()
        
        // Ждем загрузки списка
        let testsList = app.scrollViews.firstMatch
        XCTAssertTrue(testsList.waitForExistence(timeout: 5))
        
        // Проверяем наличие кнопки редактирования
        let firstTestEditButton = app.buttons.matching(identifier: "pencil.circle.fill").firstMatch
        XCTAssertTrue(firstTestEditButton.exists, "Кнопка редактирования должна быть видна для администратора")
        
        // Нажимаем редактировать
        firstTestEditButton.tap()
        
        // Ждем появления формы редактирования
        let editForm = app.navigationBars["Редактирование теста"]
        XCTAssertTrue(editForm.waitForExistence(timeout: 5))
        
        // Изменяем название теста
        let titleField = app.textFields.firstMatch
        titleField.tap()
        titleField.clearAndTypeText("Обновленный тест Swift")
        
        // Изменяем проходной балл
        let passingScoreField = app.textFields.element(boundBy: 2)
        passingScoreField.tap()
        passingScoreField.clearAndTypeText("85")
        
        // Сохраняем
        app.buttons["Сохранить"].tap()
        
        // Проверяем появление алерта
        let successAlert = app.alerts["Изменения сохранены"]
        XCTAssertTrue(successAlert.waitForExistence(timeout: 3))
        successAlert.buttons["OK"].tap()
        
        // Проверяем, что название изменилось в списке
        XCTAssertTrue(app.staticTexts["Обновленный тест Swift"].waitForExistence(timeout: 3))
    }
    
    func testAddNewCourse() throws {
        // Логинимся как администратор
        loginAsAdmin()
        
        // Переходим к курсам
        app.tabBars.buttons["Обучение"].tap()
        
        // Нажимаем кнопку добавления
        app.buttons["plus.circle.fill"].tap()
        
        // Заполняем форму
        let titleField = app.textFields.element(boundBy: 0)
        titleField.tap()
        titleField.typeText("Новый курс для тестирования")
        
        let descriptionField = app.textFields.element(boundBy: 1)
        descriptionField.tap()
        descriptionField.typeText("Описание нового курса")
        
        // Создаем курс
        app.buttons["Создать"].tap()
        
        // Проверяем, что курс появился в списке
        XCTAssertTrue(app.staticTexts["Новый курс для тестирования"].waitForExistence(timeout: 3))
    }
    
    // MARK: - Helper Methods
    
    private func loginAsAdmin() {
        // Используем мок-авторизацию для админа
        if app.buttons["Войти как администратор"].exists {
            app.buttons["Войти как администратор"].tap()
        }
    }
}

extension XCUIElement {
    func clearAndTypeText(_ text: String) {
        guard let stringValue = self.value as? String else {
            XCTFail("Не удалось получить значение текстового поля")
            return
        }
        
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
        self.typeText(text)
    }
} 