# Sprint 7: Backend Integration & Production Readiness

**Sprint Duration**: 5 дней  
**Sprint Goal**: Интеграция iOS приложения с backend API и подготовка к production

## 🎯 Цели спринта

### Основные цели:
1. **Backend интеграция** - подключить iOS приложение к реальным API
2. **CI/CD завершение** - настроить сертификаты и автоматический деплой
3. **Push уведомления** - базовая реализация
4. **Offline режим** - кеширование и синхронизация
5. **Детальные экраны** - CourseDetail, LessonView, TestView

### Дополнительные цели:
- Оптимизация производительности
- Улучшение error handling
- Добавление аналитики
- UI/UX полировка

## 📅 План по дням

### День 1: Backend Integration Foundation
- [ ] Создать NetworkService с Alamofire
- [ ] Реализовать AuthService с реальным API
- [ ] Token management и refresh logic
- [ ] Error handling и retry механизм
- [ ] Интеграционные тесты

### День 2: User & Course Services
- [ ] UserService - CRUD операции через API
- [ ] CourseService - получение и фильтрация курсов
- [ ] EnrollmentService - запись на курсы
- [ ] Обновить ViewModels для работы с реальными сервисами
- [ ] Тесты для сервисов

### День 3: Push Notifications & Offline
- [ ] Push notifications setup
- [ ] Notification handlers
- [ ] Core Data setup для offline
- [ ] Sync механизм
- [ ] Conflict resolution

### День 4: Detail Screens
- [ ] CourseDetailView с модулями и уроками
- [ ] LessonView с видео плеером
- [ ] TestView с вопросами
- [ ] ProgressTracking
- [ ] CertificateView

### День 5: CI/CD & Polish
- [ ] Сертификаты для iOS
- [ ] Fastlane полная настройка
- [ ] TestFlight деплой
- [ ] Performance оптимизация
- [ ] Финальное тестирование

## 🏗️ Технические задачи

### 1. Network Layer Architecture
```swift
protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

struct Endpoint {
    let path: String
    let method: HTTPMethod
    let parameters: Parameters?
    let headers: Headers?
}
```

### 2. Offline Storage
```swift
@Model
class OfflineCourse {
    let id: UUID
    let title: String
    let lastSynced: Date
    // Core Data entity
}
```

### 3. Push Notifications
```swift
class NotificationService {
    func requestAuthorization()
    func handleNotification(_ userInfo: [AnyHashable: Any])
    func updateBadgeCount(_ count: Int)
}
```

## 📊 Definition of Done

### Story Level:
- [ ] Функциональность работает с реальным API
- [ ] Offline режим протестирован
- [ ] Unit и интеграционные тесты написаны
- [ ] UI тесты для критических путей
- [ ] Документация обновлена

### Sprint Level:
- [ ] Приложение работает с production backend
- [ ] CI/CD pipeline полностью настроен
- [ ] TestFlight build загружен
- [ ] Performance метрики в норме
- [ ] Crash-free rate > 99%

## 🎯 Success Metrics

### Технические метрики:
- API response time < 2s
- App launch time < 1s
- Memory usage < 100MB
- Battery drain < 5% в час
- Offline sync time < 30s

### Бизнес метрики:
- Все основные user flows работают
- Push notifications доставляются
- Offline режим сохраняет прогресс
- Сертификаты генерируются корректно

## 🚧 Риски и митигация

### Риск 1: API не готово
**Митигация**: Использовать mock server или задержать интеграцию

### Риск 2: Сертификаты Apple
**Митигация**: Начать процесс в День 1, иметь запасной план

### Риск 3: Сложность offline sync
**Митигация**: MVP версия без конфликтов, только read-only

### Риск 4: Performance проблемы
**Митигация**: Профилирование с первого дня, lazy loading

## 📱 Deliverables

### К концу спринта:
1. **Production-ready iOS app** с backend интеграцией
2. **TestFlight beta** доступная для тестирования
3. **CI/CD pipeline** с автоматическим деплоем
4. **Offline mode** для базовых сценариев
5. **Push notifications** работающие

### Документация:
- API integration guide
- Deployment guide
- Testing guide
- User manual (draft)

## 🔄 Зависимости

### Внешние:
- Backend API должно быть доступно
- Apple Developer сертификаты
- Push notification сервер
- TestFlight тестировщики

### Внутренние:
- Завершенный Sprint 6
- Дизайн для новых экранов
- Test data для API
- Analytics план

## 💡 Технический стек

### Добавляемые технологии:
- **Alamofire** - networking (уже есть)
- **Core Data** - offline storage
- **Firebase** - push notifications
- **Sentry** - crash reporting
- **Amplitude** - analytics

### Инструменты:
- **Charles Proxy** - API debugging
- **Instruments** - performance profiling
- **TestFlight** - beta testing
- **Firebase Console** - push testing

## 🎯 Определение успеха

Sprint 7 будет считаться успешным если:
1. ✅ Приложение работает с реальным backend
2. ✅ Можно скачать через TestFlight
3. ✅ Push уведомления доставляются
4. ✅ Offline режим сохраняет данные
5. ✅ Нет критических багов

**Готовность к production: 80%** (останется только полировка и исправление багов по результатам бета-тестирования) 