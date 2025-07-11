# Руководство по интеграции Cmi5 в LMS

## Введение

Cmi5 (Computer Managed Instruction, 5th version) - это стандарт для создания и доставки интерактивного образовательного контента. Он основан на xAPI (Experience API) и предоставляет структурированный способ упаковки, импорта и отслеживания учебных материалов.

### Ключевые преимущества Cmi5:
- ✅ Стандартизированный формат пакетов
- ✅ Детальное отслеживание прогресса через xAPI
- ✅ Поддержка офлайн обучения
- ✅ Гибкие критерии завершения
- ✅ Мультиязычность

## Архитектура интеграции

### Компоненты системы:

```
┌─────────────────┐     ┌──────────────┐     ┌─────────────┐
│   Cmi5 Package  │────▶│  LMS Backend │────▶│     LRS     │
│   (ZIP файл)    │     │              │     │  (xAPI DB)  │
└─────────────────┘     └──────────────┘     └─────────────┘
                               │
                               ▼
                        ┌──────────────┐
                        │  iOS Client  │
                        │   (WebView)  │
                        └──────────────┘
```

## Структура Cmi5 пакета

### Минимальная структура:
```
cmi5-package.zip
├── cmi5.xml              # Манифест с метаданными
└── content/              # Папка с контентом
    ├── index.html        # Точка входа
    ├── scripts/          # JavaScript файлы
    ├── styles/           # CSS стили
    └── assets/           # Медиа файлы
```

### Пример манифеста (cmi5.xml):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<courseStructure xmlns="https://w3id.org/xapi/profiles/cmi5/v1/CourseStructure.xsd"
                id="course_example_v1">
    <course id="course_001">
        <title>Пример курса</title>
        <description>Описание курса</description>
        
        <au id="module_1" 
            launchMethod="OwnWindow" 
            moveOn="CompletedAndPassed" 
            masteryScore="0.8">
            <title>Модуль 1: Введение</title>
            <description>Вводный модуль</description>
            <url>content/module1/index.html</url>
            <activityType>http://adlnet.gov/expapi/activities/lesson</activityType>
            <duration>PT30M</duration>
        </au>
    </course>
</courseStructure>
```

## Процесс импорта

### 1. Загрузка пакета

```swift
// iOS - выбор файла
let picker = UIDocumentPickerViewController(
    forOpeningContentTypes: [.zip]
)
picker.delegate = self
present(picker, animated: true)

// Обработка выбранного файла
func documentPicker(_ controller: UIDocumentPickerViewController, 
                   didPickDocumentsAt urls: [URL]) {
    guard let url = urls.first else { return }
    uploadCmi5Package(from: url)
}
```

### 2. Валидация пакета

```swift
// Отправка на сервер для валидации
func uploadCmi5Package(from url: URL) {
    let uploadEndpoint = "/api/cmi5/upload"
    
    AF.upload(
        multipartFormData: { formData in
            formData.append(url, withName: "file")
        },
        to: uploadEndpoint
    ).responseJSON { response in
        if let uploadId = response.value?["uploadId"] as? String {
            validatePackage(uploadId: uploadId)
        }
    }
}
```

### 3. Импорт в курс

```swift
// Импорт валидного пакета
func importPackage(uploadId: String, courseId: UUID) {
    let importEndpoint = "/api/cmi5/import/\(courseId)"
    
    let parameters = [
        "uploadId": uploadId,
        "options": [
            "autoCreateLessons": true
        ]
    ]
    
    AF.request(importEndpoint, 
               method: .post,
               parameters: parameters)
        .responseDecodable(of: Cmi5Package.self) { response in
            // Пакет успешно импортирован
        }
}
```

## Запуск Cmi5 активности

### 1. Генерация Launch URL

При запуске Cmi5 активности необходимо передать специальные параметры:

```swift
func generateLaunchURL(for activity: Cmi5Activity, 
                      studentId: UUID,
                      sessionId: UUID) -> URL {
    
    var components = URLComponents(url: activity.launchUrl, 
                                  resolvingAgainstBaseURL: true)!
    
    // Обязательные параметры Cmi5
    components.queryItems = [
        URLQueryItem(name: "endpoint", 
                    value: "https://lrs.example.com/xapi/"),
        URLQueryItem(name: "fetch", 
                    value: generateAuthToken(for: sessionId)),
        URLQueryItem(name: "registration", 
                    value: sessionId.uuidString),
        URLQueryItem(name: "activityId", 
                    value: activity.activityId),
        URLQueryItem(name: "actor", 
                    value: generateActorJSON(studentId: studentId))
    ]
    
    return components.url!
}
```

### 2. Отображение в WebView

```swift
struct Cmi5LessonView: View {
    let launchURL: URL
    @State private var isFullScreen = false
    
    var body: some View {
        WebView(url: launchURL)
            .ignoresSafeArea(edges: isFullScreen ? .all : [])
            .navigationBarHidden(isFullScreen)
            .onAppear {
                sendLaunchedStatement()
            }
            .onDisappear {
                sendTerminatedStatement()
            }
    }
}
```

## xAPI Statements

### Обязательные Cmi5 глаголы:

1. **launched** - при открытии активности
2. **initialized** - после загрузки контента
3. **completed** - при завершении просмотра
4. **passed/failed** - результат оценивания
5. **terminated** - при закрытии активности

### Пример отправки statement:

```swift
func sendCompletedStatement(activityId: String, 
                           duration: TimeInterval,
                           score: Double? = nil) {
    
    let statement = XAPIStatement(
        actor: XAPIActor(
            account: XAPIAccount(
                name: currentUser.id.uuidString,
                homePage: "https://lms.example.com"
            )
        ),
        verb: XAPIVerb(
            id: "http://adlnet.gov/expapi/verbs/completed",
            display: ["en-US": "completed"]
        ),
        object: XAPIActivity(
            id: activityId,
            definition: nil
        ),
        result: XAPIResult(
            score: score.map { XAPIScore(scaled: $0/100) },
            completion: true,
            duration: formatDuration(duration)
        ),
        context: XAPIContext(
            registration: currentSession.id,
            contextActivities: XAPIContextActivities(
                parent: [parentActivity]
            )
        )
    )
    
    lrsService.sendStatement(statement)
}
```

## Отслеживание прогресса

### 1. Получение statements из LRS:

```swift
func getProgress(for activityId: String, userId: UUID) async throws -> ActivityProgress {
    let statements = try await lrsService.getStatements(
        activityId: activityId,
        userId: userId,
        limit: 100
    )
    
    // Анализ statements для определения прогресса
    let completed = statements.contains { 
        $0.verb.id == "http://adlnet.gov/expapi/verbs/completed" 
    }
    
    let passed = statements.contains { 
        $0.verb.id == "http://adlnet.gov/expapi/verbs/passed" 
    }
    
    let scores = statements.compactMap { $0.result?.score?.scaled }
    let averageScore = scores.isEmpty ? nil : scores.reduce(0, +) / Double(scores.count)
    
    return ActivityProgress(
        activityId: activityId,
        userId: userId,
        status: passed ? .passed : (completed ? .completed : .inProgress),
        score: averageScore,
        attempts: countAttempts(from: statements)
    )
}
```

### 2. State API для сохранения состояния:

```swift
// Сохранение прогресса
func saveProgress(activityId: String, progress: Int) async throws {
    let state = [
        "bookmark": currentLocation,
        "progress": progress,
        "lastAccessed": ISO8601DateFormatter().string(from: Date())
    ]
    
    try await lrsService.setState(
        activityId: activityId,
        userId: currentUser.id,
        stateId: "progress",
        value: state
    )
}

// Восстановление прогресса
func restoreProgress(activityId: String) async throws -> [String: Any]? {
    return try await lrsService.getState(
        activityId: activityId,
        userId: currentUser.id,
        stateId: "progress"
    )
}
```

## Безопасность

### 1. Валидация пакетов:
- ✅ Проверка размера (макс. 500MB)
- ✅ Валидация ZIP структуры
- ✅ Проверка манифеста на соответствие схеме
- ✅ Сканирование на вредоносный код

### 2. Изоляция контента:
- ✅ Запуск в изолированном WebView
- ✅ Ограничение доступа к API
- ✅ Content Security Policy
- ✅ Отключение небезопасных функций

### 3. Аутентификация xAPI:
- ✅ OAuth 2.0 токены с ограниченным временем жизни
- ✅ Scope ограничения для каждой сессии
- ✅ Логирование всех xAPI запросов

## Тестирование

### Unit тесты:
```swift
func testCmi5ManifestParsing() throws {
    let manifestXML = """
    <courseStructure id="test">
        <course id="course1">
            <title>Test Course</title>
        </course>
    </courseStructure>
    """
    
    let parser = Cmi5XMLParser()
    let result = try parser.parseManifest(manifestXML.data(using: .utf8)!)
    
    XCTAssertEqual(result.manifest.identifier, "test")
    XCTAssertEqual(result.manifest.title, "Test Course")
}
```

### Integration тесты:
```swift
func testFullCmi5ImportCycle() async throws {
    // 1. Загрузка
    let uploadResult = try await api.uploadPackage(testPackageURL)
    
    // 2. Валидация
    let validation = try await api.validatePackage(uploadResult.uploadId)
    XCTAssertTrue(validation.isValid)
    
    // 3. Импорт
    let package = try await api.importPackage(
        uploadId: uploadResult.uploadId,
        courseId: testCourse.id
    )
    
    // 4. Проверка активностей
    let activities = try await api.getActivities(packageId: package.id)
    XCTAssertFalse(activities.isEmpty)
}
```

## Лучшие практики

### 1. Производительность:
- 📦 Кэшируйте распакованные пакеты
- 🔄 Используйте lazy loading для больших курсов
- 📊 Batch отправка xAPI statements
- 🗜️ Сжимайте медиа файлы

### 2. UX рекомендации:
- 📱 Адаптивный дизайн для мобильных устройств
- 🔄 Автосохранение прогресса каждые 30 секунд
- 📶 Офлайн режим с синхронизацией
- ⏱️ Показ оставшегося времени

### 3. Отладка:
- 📝 Логирование всех xAPI транзакций
- 🔍 Debug панель для просмотра statements
- 📊 Метрики производительности WebView
- 🐛 Детальные ошибки валидации

## Troubleshooting

### Частые проблемы:

**1. Пакет не импортируется**
- Проверьте валидность ZIP архива
- Убедитесь что cmi5.xml в корне архива
- Проверьте размер файла (< 500MB)

**2. Активности не запускаются**
- Проверьте правильность Launch URL
- Убедитесь что все параметры переданы
- Проверьте CORS настройки

**3. Прогресс не сохраняется**
- Проверьте подключение к LRS
- Убедитесь что statements отправляются
- Проверьте права доступа пользователя

## Дополнительные ресурсы

- [Cmi5 Specification](https://github.com/AICC/CMI-5_Spec_Current)
- [xAPI Specification](https://github.com/adlnet/xAPI-Spec)
- [LRS Test Suite](https://lrs.adlnet.gov/test)
- [Cmi5 Best Practices](https://xapi.com/cmi5)

---

*Последнее обновление: Sprint 40, январь 2025* 