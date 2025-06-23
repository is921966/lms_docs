# План Sprint 6: iOS App + User Management (Пересмотренный v2)

## 📋 Информация о спринте
- **Номер спринта**: 6
- **Название**: iOS Foundation + Complete User Management
- **Планируемая длительность**: 5-7 дней
- **Планируемое количество тестов**: ~150 (backend: ~80, iOS: ~70)
- **Основная цель**: Создать нативное iOS приложение с полным User Management и CI/CD

## 🎯 Цели спринта

### 1. CI/CD Pipeline (ОБЯЗАТЕЛЬНО)
Настроить автоматизацию с первого дня:
- [ ] GitHub Actions для iOS
- [ ] Автоматический запуск тестов на каждый push
- [ ] Build и подпись приложения
- [ ] Автоматический деплой в TestFlight
- [ ] Проверка code coverage (минимум 80%)
- [ ] SwiftLint для качества кода
- [ ] Автоматическое версионирование

### 2. iOS Project Setup
Настроить современный iOS стек:
- [ ] Xcode project с SwiftUI
- [ ] Swift Package Manager для зависимостей
- [ ] Архитектура MVVM + Clean Architecture
- [ ] Networking слой (URLSession + Combine)
- [ ] Keychain для безопасного хранения токенов
- [ ] Unit и UI тесты с XCTest

### 3. Design System Foundation
Создать переиспользуемые SwiftUI компоненты:
- [ ] Цветовая схема и типографика
- [ ] Кнопки, поля ввода, алерты
- [ ] Навигация (TabView + NavigationStack)
- [ ] Списки и карточки
- [ ] Loading states и error handling
- [ ] Поддержка Dark Mode

### 4. Authentication Module
Полный flow аутентификации:
- [ ] Экран логина с валидацией
- [ ] Биометрическая аутентификация (Face ID/Touch ID)
- [ ] JWT token management
- [ ] Auto-refresh токенов
- [ ] Logout и очистка данных
- [ ] Обработка сессий

### 5. User Management (Regular Users)
CRUD операции для обычных пользователей:
- [ ] Просмотр своего профиля
- [ ] Редактирование профиля
- [ ] Смена пароля
- [ ] Фото профиля (камера/галерея)
- [ ] Настройки уведомлений
- [ ] Просмотр коллег (если разрешено)

### 6. Admin Features (iOS Native)
Административный функционал прямо в приложении:
- [ ] Переключение в админ режим (для админов)
- [ ] Список всех пользователей с фильтрами
- [ ] Создание новых пользователей
- [ ] Редактирование любого пользователя
- [ ] Управление ролями и правами
- [ ] Блокировка/разблокировка пользователей
- [ ] Массовые операции (свайпы для действий)
- [ ] Статистика использования
- [ ] Экспорт данных (CSV/PDF на email)
- [ ] Аудит лог действий

### 7. Backend Integration
Интеграция с существующим API:
- [ ] API client с async/await
- [ ] Codable модели
- [ ] Error handling
- [ ] Offline support (Core Data)
- [ ] Синхронизация данных
- [ ] Фоновое обновление

## 📊 Планируемая декомпозиция по дням

### День 1: CI/CD Setup + Project
```yaml
Утро:
  - GitHub Actions workflow
  - Fastlane configuration
  - TestFlight automation
  
День:
  - Xcode project setup
  - Базовая структура
  - Первые тесты
```
Тесты: ~10

### День 2: Design System + Auth UI
```swift
- SwiftUI компоненты
- LoginView с TDD
- Биометрия setup
- Keychain wrapper
```
Тесты: ~20

### День 3: User Features
```swift
- ProfileView
- EditProfileView
- Settings screen
- Photo handling
```
Тесты: ~15

### День 4: Admin UI
```swift
- Admin mode toggle
- UserListView с фильтрами
- User CRUD operations
- Batch actions
```
Тесты: ~20

### День 5: Backend Integration
```swift
- API client implementation
- All endpoints connection
- Error handling
- Offline mode
```
Тесты: ~35

### День 6: Polish & Testing
```swift
- UI/UX improvements
- Performance optimization
- E2E tests
- TestFlight release
```
Тесты: ~30

### День 7: Documentation & Release
```swift
- Code documentation
- User guide
- Admin guide
- App Store preparation
```
Тесты: ~20

## 🏗️ Технические решения

### CI/CD Pipeline
```yaml
Инструменты:
  - GitHub Actions
  - Fastlane
  - xcpretty
  - danger-swift

Workflow:
  1. Push to branch
  2. Run tests
  3. Check coverage
  4. SwiftLint
  5. Build app
  6. Sign with certificates
  7. Upload to TestFlight
  8. Notify team in Slack
```

### Admin Mode Architecture
```swift
// Единое приложение с режимами
enum AppMode {
    case regular
    case admin
}

// Conditional UI based on permissions
struct ContentView: View {
    @EnvironmentObject var auth: AuthService
    
    var body: some View {
        if auth.currentUser.isAdmin {
            AdminTabView() // Расширенный функционал
        } else {
            RegularTabView() // Обычный функционал
        }
    }
}
```

### Структура iOS проекта
```
LMS/
├── LMSApp.swift              
├── CI/
│   ├── .github/
│   │   └── workflows/
│   │       ├── test.yml      # На каждый push
│   │       └── deploy.yml    # На merge в main
│   └── fastlane/
│       ├── Fastfile
│       └── Matchfile
├── Core/
│   ├── Network/              
│   ├── Storage/              
│   ├── Extensions/           
│   └── Utils/                
├── Features/
│   ├── Auth/                 
│   ├── Profile/              
│   ├── Admin/                # Admin-only features
│   │   ├── UserManagement/
│   │   ├── Statistics/
│   │   └── AuditLog/
│   └── Common/               
├── Resources/                
└── Tests/
    ├── UnitTests/
    └── UITests/
```

## 📈 Метрики успеха

### Обязательные:
- [ ] CI/CD pipeline работает
- [ ] Автодеплой в TestFlight
- [ ] Code coverage > 80%
- [ ] Все тесты зеленые
- [ ] Админ функционал в iOS
- [ ] Биометрическая аутентификация
- [ ] Offline режим

### Желательные:
- [ ] Время сборки < 5 минут
- [ ] 0 warnings
- [ ] Accessibility 100%
- [ ] Performance monitoring
- [ ] Crash reporting setup

## ⚠️ Особенности Admin Mode

### Преимущества iOS админки:
1. **Единое приложение** - не нужно переключаться
2. **Нативный UX** - свайпы, жесты для массовых операций
3. **Безопасность** - Face ID для админ действий
4. **Мобильность** - управление откуда угодно
5. **Push уведомления** - о важных событиях

### UI/UX для админов:
- Специальная цветовая схема в админ режиме
- Дополнительные табы в TabBar
- Контекстные меню с админ действиями
- Batch операции через multiselect
- Режим "бога" с расширенной информацией

## 📋 Definition of Done

Для каждой фичи:
- [ ] Код написан через TDD
- [ ] Unit тесты написаны и проходят
- [ ] UI тесты для критичных путей
- [ ] CI/CD pipeline зеленый
- [ ] Code review пройден
- [ ] Документация обновлена

Для спринта:
- [ ] CI/CD полностью настроен
- [ ] TestFlight build доступен
- [ ] Админ функционал работает в iOS
- [ ] Все тесты проходят
- [ ] Coverage > 80%
- [ ] 0 критических багов

## 🎯 Ожидаемые результаты

К концу спринта:
1. **Работающий CI/CD pipeline** с автодеплоем
2. **Единое iOS приложение** для всех пользователей
3. **Полный админ функционал** нативно в iOS
4. **Готовность к production** через TestFlight
5. **Автоматизация** всех рутинных процессов

## 🚀 CI/CD команды

```bash
# Локальный запуск
fastlane test          # Запуск тестов
fastlane beta          # Сборка для TestFlight
fastlane screenshots   # Генерация скриншотов

# Автоматически в CI
# При push - тесты
# При merge в main - TestFlight
```

---

**Старт спринта**: Сразу после утверждения  
**Методология**: TDD + CI/CD с первого коммита  
**Приоритет**: Сначала CI/CD, потом функционал 