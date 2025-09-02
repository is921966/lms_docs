# Sprint 52 Mini: Доработка каналов Методология, Релизы, Спринты

**Sprint**: 52 Mini  
**Дата**: 22 июля 2025 (День 170, вторая половина)  
**Продолжительность**: 4-6 часов  
**Цель**: Исправить отображение контента и добавить полную историю в каналы

## 🎯 Основные задачи

1. **Исправить обрезание контента** - WebView должен показывать полный контент
2. **Добавить загрузку всей истории** - убрать лимит в 10 записей
3. **Реализовать автообновление** - FileSystemWatcher для новых файлов
4. **Улучшить навигацию** - пагинация и поиск по истории
5. **Оптимизировать производительность** - lazy loading для больших списков

## 📋 План разработки (TDD)

### Этап 1: Исправление отображения контента (1 час)

#### Тесты:
```swift
// HTMLContentWrapperTests.swift
func test_webView_dynamicallyAdjustsHeight() { }
func test_fullContentIsVisible() { }
func test_linksAreClickable() { }
```

#### Задачи:
- [ ] Написать тесты для динамической высоты WebView
- [ ] Реализовать JavaScript для измерения реальной высоты контента
- [ ] Убрать фиксированную minHeight и включить прокрутку
- [ ] Добавить обработку изменения размера контента
- [ ] Запустить тесты, убедиться что все зеленые

### Этап 2: Загрузка полной истории (1.5 часа)

#### Тесты:
```swift
// RealDataFeedServiceTests.swift
func test_loadsAllReleaseNotes_notJustLast10() { }
func test_loadsAllSprintReports() { }
func test_loadsAllMethodologyUpdates() { }
func test_sortsPostsByDateDescending() { }
```

#### Задачи:
- [ ] Написать тесты для загрузки всех файлов
- [ ] Убрать лимиты .prefix(10) в RealDataFeedService
- [ ] Добавить сортировку по дате создания файла
- [ ] Реализовать кэширование для производительности
- [ ] Добавить индикатор загрузки для больших списков

### Этап 3: Автообновление каналов (1.5 часа)

#### Тесты:
```swift
// FileSystemWatcherTests.swift
func test_detectsNewFileInReportsFolder() { }
func test_updatesChannelWhenNewFileAdded() { }
func test_throttlesFrequentUpdates() { }
```

#### Задачи:
- [ ] Написать тесты для FileSystemWatcher
- [ ] Реализовать мониторинг папок reports/, docs/releases/
- [ ] Добавить throttling для частых изменений (max 1/сек)
- [ ] Интегрировать с FeedViewModel для обновления UI
- [ ] Добавить уведомление о новых постах

### Этап 4: Улучшение навигации (1 час)

#### Тесты:
```swift
// FeedNavigationTests.swift
func test_searchInChannelHistory() { }
func test_paginationLoadsNext20Items() { }
func test_scrollToTopButton() { }
```

#### Задачи:
- [ ] Написать тесты для поиска и пагинации
- [ ] Добавить поиск по истории канала
- [ ] Реализовать пагинацию (20 постов на страницу)
- [ ] Добавить кнопку "Наверх" при прокрутке
- [ ] Реализовать pull-to-refresh

### Этап 5: Оптимизация производительности (1 час)

#### Тесты:
```swift
// PerformanceTests.swift
func test_lazyLoadingOf100Posts_under500ms() { }
func test_memoryUsageStableWithLargeHistory() { }
func test_scrollingPerformance60fps() { }
```

#### Задачи:
- [ ] Написать performance тесты
- [ ] Реализовать LazyVStack вместо VStack
- [ ] Добавить виртуализацию для больших списков
- [ ] Оптимизировать парсинг markdown/HTML
- [ ] Профилирование с Instruments

## 📊 Метрики успеха

| Метрика | Текущее | Цель |
|---------|---------|------|
| Полнота отображения контента | ~50% | 100% |
| Количество постов в истории | 10 | Все |
| Время загрузки канала | >2s | <500ms |
| FPS при прокрутке | ~45 | 60 |
| Автообновление | Нет | Да |
| Test coverage | 75% | >90% |

## 🔧 Технические детали

### HTMLContentWrapper улучшения:
```javascript
// Внедрить в WebView для измерения высоты
webView.evaluateJavaScript("""
    document.body.scrollHeight
""") { height, error in
    self.updateHeight(height)
}
```

### FileSystemWatcher реализация:
```swift
class FileSystemWatcher {
    private var source: DispatchSourceFileSystemObject?
    
    func watch(path: String, onChange: @escaping () -> Void) {
        // Реализация мониторинга
    }
}
```

### Структура данных для истории:
```swift
struct ChannelHistory {
    let posts: [FeedPost]
    let hasMore: Bool
    let nextPage: Int?
    
    func loadMore() async -> [FeedPost]
}
```

## ⚡ Быстрые команды

```bash
# Запуск тестов для Feed модуля
./scripts/test-quick-ui.sh LMSUITests/Feed

# Мониторинг производительности
xcrun instruments -t "Time Profiler" LMS.app

# Проверка обновлений файлов
fswatch -o reports/ | xargs -n1 -I{} echo "File changed"
```

## 🚨 Риски

1. **Большой объем данных** → Пагинация и lazy loading
2. **Частые обновления файлов** → Throttling и debouncing
3. **Производительность WebView** → Нативный рендеринг для простого HTML
4. **Память при большой истории** → Виртуализация списка

## ✅ Definition of Done

- [ ] Все тесты зеленые (>90% coverage)
- [ ] Контент отображается полностью без обрезания
- [ ] Загружается вся история постов
- [ ] Работает автообновление при добавлении файлов
- [ ] Производительность прокрутки 60 FPS
- [ ] Код прошел review
- [ ] Обновлена документация

## 🎯 Результат

После выполнения этого мини-спринта:
- Пользователи увидят полный контент постов
- Будет доступна вся история изменений проекта
- Новые посты появятся автоматически
- Улучшится UX при работе с большими списками 