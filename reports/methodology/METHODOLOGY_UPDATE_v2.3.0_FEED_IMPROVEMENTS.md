# Обновление методологии v2.3.0: Уроки разработки Feed модуля

**Версия**: 2.3.0  
**Дата**: 22 июля 2025  
**Автор**: AI Development Team  

## 📋 Новые практики и паттерны

### 1. Динамическая загрузка контента из файловой системы

**Проблема**: Хардкод списков файлов быстро устаревает  
**Решение**: Динамическое сканирование директорий

```swift
// ❌ Плохо
let files = ["RELEASE_v1.0.0.md", "RELEASE_v1.1.0.md"]

// ✅ Хорошо
let files = try fileManager.contentsOfDirectory(atPath: path)
let releaseFiles = files.filter { 
    $0.contains("RELEASE") && $0.hasSuffix(".md")
}
```

### 2. WebView с динамической высотой

**Проблема**: Фиксированная высота обрезает контент  
**Решение**: JavaScript ResizeObserver + Message Handlers

```swift
// Добавить в makeUIView
let script = """
var observer = new ResizeObserver(function(entries) {
    window.webkit.messageHandlers.heightHandler.postMessage(
        document.body.scrollHeight
    );
});
observer.observe(document.body);
"""

// Обработчик сообщений
coordinator.parent.dynamicHeight = CGFloat(height)
```

### 3. Производительность при большом количестве элементов

**Проблема**: Загрузка 100+ постов замедляет UI  
**Решение**: Поэтапный подход

1. **Фаза 1**: Загрузить все, отсортировать по дате
2. **Фаза 2**: Добавить lazy loading для списков
3. **Фаза 3**: Реализовать пагинацию
4. **Фаза 4**: Добавить кэширование

### 4. TDD для UI компонентов

**Новый подход**: Тестирование через публичные свойства

```swift
// Тест для динамической высоты
func test_webView_updatesHeightDynamically() {
    let wrapper = HTMLContentWrapper(htmlContent: testHTML)
    let hostingController = UIHostingController(rootView: wrapper)
    
    // Trigger view lifecycle
    _ = hostingController.view
    
    // Simulate JavaScript callback
    wrapper.coordinator?.userContentController(
        mockController, 
        didReceive: mockMessage
    )
    
    XCTAssertEqual(wrapper.dynamicHeight, expectedHeight)
}
```

### 5. Модульная архитектура сервисов

**Паттерн**: Service → Mock Service → Real Service

```
MockFeedService (координатор)
    ├── RealDataFeedService (файлы)
    ├── APIFeedService (backend) - будущее
    └── CacheFeedService (offline) - будущее
```

### 6. Конвертация Markdown → HTML на лету

**Лучшая практика**: Единая функция конвертации

```swift
private func convertMarkdownToHTML(_ markdown: String) -> String {
    return markdown
        .replacingOccurrences(of: "## ", with: "<h2>")
        .replacingOccurrences(of: "\n- ", with: "<li>")
        .replacingOccurrences(of: "**", with: "<strong>")
        // ... остальные правила
}
```

## 🚨 Новые антипаттерны

### 1. Ограничение количества загружаемых элементов

**Антипаттерн**: `.prefix(10)` без возможности загрузить больше  
**Почему плохо**: Пользователи теряют доступ к истории  
**Решение**: Загружать все, но показывать постепенно

### 2. Фиксированные размеры для динамического контента

**Антипаттерн**: `.frame(minHeight: 200)`  
**Почему плохо**: Контент обрезается или остается пустое место  
**Решение**: Динамический расчет размеров

### 3. Игнорирование системных логов

**Антипаттерн**: Не читать логи при отладке  
**Почему плохо**: Пропускаются важные ошибки  
**Решение**: Всегда проверять `ComprehensiveLogger` логи

## 📊 Метрики качества для Feed модулей

| Метрика | Минимум | Оптимально |
|---------|---------|------------|
| Время загрузки канала | <500ms | <200ms |
| FPS при прокрутке | 30 | 60 |
| Память на 100 постов | <100MB | <50MB |
| Покрытие тестами | 80% | 95% |

## 🔧 Чеклист для Feed-подобных модулей

- [ ] Динамическая загрузка контента
- [ ] Обработка пустых состояний
- [ ] Поддержка разных форматов (HTML/Markdown)
- [ ] Оптимизация для больших списков
- [ ] Offline поддержка (planned)
- [ ] Pull-to-refresh
- [ ] Поиск и фильтрация
- [ ] Правильная работа с WebView
- [ ] Accessibility поддержка
- [ ] Логирование всех действий

## 💡 Рекомендации для будущих спринтов

1. **FileSystemWatcher**: Обязательно для production
2. **Пагинация**: При >50 элементах
3. **Кэширование**: Core Data для офлайн
4. **Тесты производительности**: Instruments профилирование
5. **A/B тестирование**: Для UI изменений

## 🎯 Применимость

Эти практики применимы для:
- Новостных лент
- Списков курсов
- Уведомлений
- Чатов и сообщений
- Любых динамических списков

---

**Важно**: Добавить эти практики в основной файл методологии при следующем обновлении. 