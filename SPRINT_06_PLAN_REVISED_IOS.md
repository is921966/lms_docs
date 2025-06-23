# План Sprint 6: iOS App + User Management (Пересмотренный)

## 📋 Информация о спринте
- **Номер спринта**: 6
- **Название**: iOS Foundation + Complete User Management
- **Планируемая длительность**: 5-7 дней
- **Планируемое количество тестов**: ~150 (backend: ~80, iOS: ~70)
- **Основная цель**: Создать нативное iOS приложение с полным User Management

## 🎯 Цели спринта

### 1. iOS Project Setup
Настроить современный iOS стек:
- [ ] Xcode project с SwiftUI
- [ ] Swift Package Manager для зависимостей
- [ ] Архитектура MVVM + Clean Architecture
- [ ] Networking слой (URLSession + Combine)
- [ ] Keychain для безопасного хранения токенов
- [ ] Unit и UI тесты с XCTest

### 2. Design System Foundation
Создать переиспользуемые SwiftUI компоненты:
- [ ] Цветовая схема и типографика
- [ ] Кнопки, поля ввода, алерты
- [ ] Навигация (TabView + NavigationStack)
- [ ] Списки и карточки
- [ ] Loading states и error handling
- [ ] Поддержка Dark Mode

### 3. Authentication Module
Полный flow аутентификации:
- [ ] Экран логина с валидацией
- [ ] Биометрическая аутентификация (Face ID/Touch ID)
- [ ] JWT token management
- [ ] Auto-refresh токенов
- [ ] Logout и очистка данных
- [ ] Обработка сессий

### 4. User Management
CRUD операции с пользователями:
- [ ] Список пользователей с поиском
- [ ] Детальный просмотр профиля
- [ ] Редактирование пользователя
- [ ] Управление ролями
- [ ] Фото профиля (камера/галерея)
- [ ] Pull-to-refresh

### 5. Backend Integration
Интеграция с существующим API:
- [ ] API client с async/await
- [ ] Codable модели
- [ ] Error handling
- [ ] Offline support (Core Data)
- [ ] Синхронизация данных

### 6. Admin Web Panel (Минимальный)
Базовая админка для браузера:
- [ ] Простой React dashboard
- [ ] Управление пользователями
- [ ] Просмотр статистики
- [ ] Экспорт данных

## 📊 Планируемая декомпозиция по дням

### День 1: iOS Project Setup
```swift
- Создание Xcode проекта
- Настройка архитектуры (MVVM)
- Базовый networking слой
- Конфигурация окружений (Dev/Prod)
- CI/CD setup (опционально)
```
Тесты: ~10

### День 2: Design System
```swift
- SwiftUI компоненты
- Цвета и шрифты из брендбука
- Анимации и переходы
- Accessibility поддержка
```
Тесты: ~15

### День 3: Authentication
```swift
- LoginView с валидацией
- Биометрия интеграция
- Keychain wrapper
- Session management
```
Тесты: ~20

### День 4: User List & Details
```swift
- UserListView с поиском
- UserDetailView
- Навигация между экранами
- Загрузка изображений
```
Тесты: ~15

### День 5: User Edit & Roles
```swift
- EditUserView
- Камера/галерея интеграция
- Role management UI
- Form валидация
```
Тесты: ~15

### День 6: Backend Integration
```swift
- Подключение к реальному API
- Обработка ошибок
- Offline режим
- Data синхронизация
```
Тесты: ~35

### День 7: Polish & Admin Panel
```swift
- UI улучшения
- Производительность
- Простая web админка
- App Store подготовка
```
Тесты: ~40

## 🏗️ Технические решения

### iOS Stack
```yaml
Язык: Swift 5.9+
UI: SwiftUI
Минимальная iOS: 16.0
Архитектура: MVVM + Clean Architecture
Навигация: NavigationStack
State: @StateObject, @EnvironmentObject
Networking: URLSession + async/await
Persistence: Core Data + Keychain
Testing: XCTest + ViewInspector
```

### Структура iOS проекта
```
LMS/
├── LMSApp.swift              # App entry point
├── Core/
│   ├── Network/              # API client
│   ├── Storage/              # Core Data + Keychain
│   ├── Extensions/           # Swift extensions
│   └── Utils/                # Helpers
├── Features/
│   ├── Auth/                 # Login, биометрия
│   ├── Users/                # User management
│   ├── Common/               # Shared views
│   └── TabBar/               # Main navigation
├── Resources/                # Assets, Localizable
└── Tests/
    ├── UnitTests/
    └── UITests/
```

### API интеграция
```swift
// Пример API client
class APIClient {
    func login(email: String, password: String) async throws -> AuthToken
    func getUsers() async throws -> [User]
    func updateUser(_ user: User) async throws -> User
}

// Модели
struct User: Codable, Identifiable {
    let id: UUID
    var email: String
    var name: String
    var role: Role
    var avatarURL: URL?
}
```

## 📈 Метрики успеха

### Обязательные:
- [ ] Приложение работает на iPhone и iPad
- [ ] Биометрическая аутентификация
- [ ] Offline режим для просмотра
- [ ] Время запуска < 1 сек
- [ ] Нет крашей

### Желательные:
- [ ] Поддержка widgets
- [ ] Shortcuts/Siri интеграция
- [ ] Apple Watch companion
- [ ] CloudKit синхронизация

## ⚠️ Особенности iOS разработки

### Преимущества перед Web:
1. **Нативный UX** - жесты, анимации, haptic feedback
2. **Биометрия** - безопасная аутентификация
3. **Offline** - работа без интернета
4. **Push уведомления** - вовлеченность
5. **Производительность** - 60 FPS

### Вызовы:
1. **App Store Review** - нужно соответствовать гайдлайнам
2. **Версионность** - поддержка старых версий
3. **Тестирование** - разные устройства
4. **Обновления** - не мгновенные как в web

## 📋 Definition of Done

Для каждой фичи:
- [ ] UI реализован в SwiftUI
- [ ] Unit тесты написаны
- [ ] UI тесты для критичных путей
- [ ] Работает на iPhone и iPad
- [ ] Поддерживает Dynamic Type
- [ ] VoiceOver accessibility
- [ ] Нет memory leaks
- [ ] Документация в коде

Для спринта:
- [ ] TestFlight beta готова
- [ ] Crash-free rate > 99.5%
- [ ] Backend интегрирован
- [ ] Биометрия работает
- [ ] Offline режим протестирован

## 🎯 Ожидаемые результаты

К концу спринта:
1. **Нативное iOS приложение** с отличным UX
2. **Полный User Management** с биометрией
3. **Offline поддержка** для продуктивности
4. **Готовность к расширению** для других модулей
5. **Минимальная web админка** для администраторов

## 🚀 Быстрый старт

```bash
# Backend (уже есть)
./test-quick.sh

# iOS
open LMS.xcodeproj
# CMD+U для запуска тестов
# CMD+R для запуска на симуляторе
```

---

**Старт спринта**: Сразу после утверждения  
**Методология**: TDD для Swift кода  
**Приоритет**: Сначала iPhone, потом iPad оптимизация 