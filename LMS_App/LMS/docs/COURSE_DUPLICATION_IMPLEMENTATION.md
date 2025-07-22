# Реализация дублирования курсов (Course Duplication)

## Обзор

Реализована функциональность дублирования курсов для Course Management в рамках Фазы 2.

## Компоненты

### 1. Сервисный слой

#### MockCourseService
**Файл**: `Services/MockCourseService.swift`

Реализован метод `duplicateCourse`:
- Создает копию курса с новым ID
- Генерирует новое название с суффиксом "(копия)"
- Поддерживает инкрементацию для множественных копий
- Дублирует все модули с новыми ID
- Сбрасывает статус на "черновик"
- Обновляет временные метки

```swift
func duplicateCourse(_ id: UUID) async throws -> ManagedCourse {
    // Поиск оригинального курса
    guard let originalCourse = courses.first(where: { $0.id == id }) else {
        throw CourseError.courseNotFound
    }
    
    // Генерация нового названия
    let newTitle = generateDuplicateTitle(for: originalCourse.title)
    
    // Дублирование модулей
    let duplicatedModules = originalCourse.modules.map { ... }
    
    // Создание копии
    let duplicatedCourse = ManagedCourse(...)
    
    return duplicatedCourse
}
```

### 2. ViewModel слой

#### CourseManagementViewModel
**Файл**: `ViewModels/CourseManagementViewModel.swift`

Добавлен метод для дублирования через протокол:
```swift
func duplicateCourse(_ id: UUID) async throws {
    let duplicatedCourse = try await courseService.duplicateCourse(id)
    self.courses.append(duplicatedCourse)
    self.successMessage = "Курс '\(duplicatedCourse.title)' успешно дублирован"
}
```

#### CourseDetailViewModel  
**Файл**: `ViewModels/CourseDetailViewModel.swift`

Использует существующий метод `duplicateCourse()` для дублирования текущего курса.

### 3. UI слой

#### ManagedCourseDetailView
**Файл**: `Views/ManagedCourseDetailView.swift`

Интеграция в меню действий:
- Добавлена кнопка "Дублировать курс" с иконкой `doc.on.doc`
- Показ прогресса во время дублирования
- Обработка ошибок с алертом
- Автоматический переход обратно после успешного дублирования

## Функциональность

### Генерация названий
- Первая копия: "Название курса (копия)"
- Вторая копия: "Название курса (копия 2)"
- Последующие: "Название курса (копия N)"

### Правила дублирования
1. **ID**: Генерируется новый UUID
2. **Название**: Добавляется суффикс "(копия)"
3. **Статус**: Всегда сбрасывается на "черновик"
4. **Модули**: Дублируются с новыми ID
5. **Компетенции**: Сохраняются те же связи
6. **Временные метки**: Обновляются на текущее время
7. **Cmi5PackageId**: Сохраняется связь с пакетом

## Тестирование

### Unit тесты
**Файл**: `LMSTests/Features/CourseManagement/CourseDuplicationTests.swift`

Покрытие:
- Создание нового курса с новым ID
- Правильная генерация названий
- Инкрементация номеров копий
- Сброс статуса на черновик
- Копирование всех свойств
- Дублирование модулей
- Обновление временных меток
- Обработка ошибок
- Сохранность оригинала

### UI тесты
Проверка доступности кнопки дублирования в меню курса.

## Дальнейшие улучшения

1. **Пакетное дублирование**: Возможность дублировать несколько курсов
2. **Настройка дублирования**: Выбор что копировать (модули, компетенции, студенты)
3. **История дублирования**: Отслеживание связей между оригиналом и копиями
4. **Шаблоны курсов**: Создание шаблонов для быстрого создания новых курсов

---

**Sprint 47, День 151**  
**Статус**: ✅ Реализовано  
**TDD**: ✅ Соблюден 