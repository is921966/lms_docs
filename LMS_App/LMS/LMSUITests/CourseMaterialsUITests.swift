import XCTest

class CourseMaterialsUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testNavigateToCourseMaterialsFromCourseEdit() throws {
        // Логин как администратор
        loginAsAdmin()

        // Переход к управлению курсами
        app.tabBars.buttons["Ещё"].tap()
        app.collectionViews.buttons["Управление курсами"].tap()

        // Выбор первого курса для редактирования
        let coursesTable = app.tables
        XCTAssertTrue(coursesTable.cells.count > 0, "Нет курсов для редактирования")
        coursesTable.cells.element(boundBy: 0).tap()

        // Проверка наличия кнопки "Управление материалами"
        let materialsButton = app.buttons["Управление материалами"]
        XCTAssertTrue(materialsButton.exists, "Кнопка 'Управление материалами' не найдена")

        // Переход к управлению материалами
        materialsButton.tap()

        // Проверка загрузки экрана управления материалами
        XCTAssertTrue(app.navigationBars["Материалы курса"].exists, "Экран управления материалами не загружен")
    }

    func testAddVideoMaterial() throws {
        navigateToCourseMaterials()

        // Нажатие кнопки добавления материала
        app.navigationBars.buttons["plus"].tap()

        // Выбор типа "Видео"
        app.sheets.buttons["Видео"].tap()

        // Заполнение формы
        let titleField = app.textFields["Название материала"]
        titleField.tap()
        titleField.typeText("Вводное видео по курсу")

        let urlField = app.textFields["URL видео"]
        urlField.tap()
        urlField.typeText("https://youtube.com/watch?v=example")

        let durationField = app.textFields["Длительность"]
        durationField.tap()
        durationField.typeText("15:30")

        // Сохранение
        app.buttons["Сохранить"].tap()

        // Проверка, что материал добавлен
        XCTAssertTrue(app.tables.cells.staticTexts["Вводное видео по курсу"].exists, "Видео материал не добавлен")
    }

    func testAddPresentationMaterial() throws {
        navigateToCourseMaterials()

        app.navigationBars.buttons["plus"].tap()
        app.sheets.buttons["Презентация"].tap()

        let titleField = app.textFields["Название материала"]
        titleField.tap()
        titleField.typeText("Презентация модуля 1")

        let urlField = app.textFields["URL презентации"]
        urlField.tap()
        urlField.typeText("https://slides.com/presentation1")

        app.buttons["Сохранить"].tap()

        XCTAssertTrue(app.tables.cells.staticTexts["Презентация модуля 1"].exists, "Презентация не добавлена")
    }

    func testEditMaterial() throws {
        // Создаем материал для редактирования
        try testAddVideoMaterial()

        // Находим созданный материал
        let materialCell = app.tables.cells.containing(.staticText, identifier: "Вводное видео по курсу").element
        XCTAssertTrue(materialCell.exists, "Материал для редактирования не найден")

        // Свайп для отображения действий
        materialCell.swipeLeft()

        // Нажатие кнопки редактирования
        app.buttons["Изменить"].tap()

        // Изменение названия
        let titleField = app.textFields["Название материала"]
        titleField.tap()
        titleField.clearAndTypeText("Обновленное вводное видео")

        // Сохранение изменений
        app.buttons["Сохранить"].tap()

        // Проверка обновления
        XCTAssertTrue(app.tables.cells.staticTexts["Обновленное вводное видео"].exists, "Материал не обновлен")
        XCTAssertFalse(app.tables.cells.staticTexts["Вводное видео по курсу"].exists, "Старое название все еще отображается")
    }

    func testDeleteMaterial() throws {
        // Создаем материал для удаления
        try testAddPresentationMaterial()

        // Находим материал
        let materialCell = app.tables.cells.containing(.staticText, identifier: "Презентация модуля 1").element
        XCTAssertTrue(materialCell.exists, "Материал для удаления не найден")

        // Свайп для удаления
        materialCell.swipeLeft()

        // Нажатие кнопки удаления
        app.buttons["Удалить"].tap()

        // Подтверждение удаления
        app.alerts.buttons["Удалить"].tap()

        // Проверка, что материал удален
        XCTAssertFalse(app.tables.cells.staticTexts["Презентация модуля 1"].exists, "Материал не был удален")
    }

    func testMaterialsListDisplay() throws {
        navigateToCourseMaterials()

        // Добавляем несколько материалов разных типов
        addMaterial(type: "Видео", title: "Видео лекция 1")
        addMaterial(type: "Презентация", title: "Слайды к лекции")
        addMaterial(type: "Документ", title: "Методическое пособие")
        addMaterial(type: "Ссылка", title: "Дополнительные ресурсы")

        // Проверяем отображение всех материалов
        XCTAssertTrue(app.tables.cells.count >= 4, "Не все материалы отображаются")

        // Проверяем отображение иконок типов
        XCTAssertTrue(app.tables.cells.images["video.fill"].exists, "Иконка видео не отображается")
        XCTAssertTrue(app.tables.cells.images["doc.richtext.fill"].exists, "Иконка презентации не отображается")
        XCTAssertTrue(app.tables.cells.images["doc.text.fill"].exists, "Иконка документа не отображается")
        XCTAssertTrue(app.tables.cells.images["link"].exists, "Иконка ссылки не отображается")
    }

    // MARK: - Helper Methods

    private func loginAsAdmin() {
        if app.buttons["Войти как администратор"].exists {
            app.buttons["Войти как администратор"].tap()
        }
    }

    private func navigateToCourseMaterials() {
        loginAsAdmin()
        app.tabBars.buttons["Ещё"].tap()
        app.collectionViews.buttons["Управление курсами"].tap()

        let coursesTable = app.tables
        if coursesTable.cells.count > 0 {
            coursesTable.cells.element(boundBy: 0).tap()
            app.buttons["Управление материалами"].tap()
        }
    }

    private func addMaterial(type: String, title: String) {
        app.navigationBars.buttons["plus"].tap()
        app.sheets.buttons[type].tap()

        let titleField = app.textFields["Название материала"]
        titleField.tap()
        titleField.typeText(title)

        // Заполняем URL в зависимости от типа
        let urlFields = app.textFields.matching(NSPredicate(format: "label CONTAINS 'URL'"))
        if urlFields.count > 0 {
            let urlField = urlFields.element(boundBy: 0)
            urlField.tap()
            urlField.typeText("https://example.com/\(type.lowercased())")
        }

        app.buttons["Сохранить"].tap()
    }
}
