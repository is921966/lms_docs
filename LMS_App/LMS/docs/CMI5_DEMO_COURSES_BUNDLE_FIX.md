# Решение проблемы с демо-курсами Cmi5

## Проблема
Демо-курсы не могут быть найдены в приложении, потому что ZIP файлы не включены в bundle приложения при сборке.

## Решение

### Вариант 1: Добавление файлов в Xcode (рекомендуется)

1. Откройте `LMS.xcodeproj` в Xcode
2. В навигаторе проекта кликните правой кнопкой на папку `LMS`
3. Выберите "Add Files to 'LMS'..."
4. Перейдите в `LMS/Resources/`
5. Выберите все ZIP файлы демо-курсов:
   - `ai_fluency_course_v1.0.zip`
   - `CatapultDemoCourses/single_au_basic_responsive.zip`
   - `CatapultDemoCourses/masteryscore_responsive.zip`
   - `CatapultDemoCourses/multi_au_framed.zip`
   - `CatapultDemoCourses/pre_post_test_framed.zip`
6. **ВАЖНО**: Убедитесь что:
   - ❌ "Copy items if needed" - НЕ отмечено
   - ✅ "Add to targets: LMS" - отмечено
7. Нажмите "Add"
8. Пересоберите проект

### Вариант 2: Автоматическое создание временных файлов

Приложение теперь имеет встроенный механизм создания временных демо-курсов:

1. `DemoCourseManager` автоматически создаст временные файлы если оригиналы не найдены
2. При первом запуске файлы будут скопированы в Documents директорию
3. Это позволяет тестировать функционал импорта даже без файлов в bundle

### Вариант 3: Ручное добавление в проект

Если у вас есть доступ к Ruby и gem xcodeproj:

```bash
# Установите xcodeproj
sudo gem install xcodeproj

# Запустите скрипт
ruby scripts/add-demo-courses-to-project.rb
```

## Архитектура решения

### DemoCourseManager
Новый компонент который управляет демо-курсами:

- **Приоритет поиска файлов**:
  1. Documents директория (для персистентности)
  2. App Bundle (основное расположение)
  3. Временные файлы (fallback для тестирования)

- **Функции**:
  - `copyDemoCoursesToDocuments()` - копирует курсы при первом запуске
  - `getDocumentsURL(for:)` - возвращает URL из Documents
  - `getBundleURL(for:)` - возвращает URL из Bundle
  - `createTemporaryDemoCourse(for:)` - создает временный файл

### Изменения в Cmi5ImportViewModel
- Метод `loadDemoCourse` теперь использует `DemoCourseManager`
- Поддерживает множественные источники файлов
- Graceful fallback если файлы не найдены

### Инициализация при запуске
- В `LMSApp.init()` добавлен вызов `setupDemoCourses()`
- Автоматическое копирование демо-курсов в Documents

## Результат
После применения любого из вариантов:
- Демо-курсы будут доступны в приложении
- Кнопка "Демо курсы" покажет селектор курсов
- Выбранные курсы можно будет импортировать
- Импортированные курсы появятся в Course Management

## Проверка
1. Запустите приложение
2. Перейдите в Settings → Learning → Cmi5 Import
3. Нажмите "Демо курсы"
4. Выберите любой курс
5. Нажмите "Импортировать"
6. Проверьте что курс появился в Course Management 