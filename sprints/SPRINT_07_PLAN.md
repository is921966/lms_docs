# Sprint 7: Backend Integration & Production Readiness

**Sprint Duration**: 5 дней  
**Sprint Goal**: Подключить iOS приложение к backend API и подготовить к production  
**Approach**: Incremental Integration with Fallbacks

## 🎯 Sprint Objectives

1. **Backend API Integration** (Priority 1)
2. **Offline Mode** с кешированием
3. **Push Notifications** базовая реализация
4. **Error Handling** и retry логика
5. **Production Configuration**

## 📋 User Stories

### 1. Backend Authentication (8 story points)
**As a** user  
**I want to** login with real credentials  
**So that** I can access my actual data

**Tasks:**
- [ ] Implement NetworkService для API calls
- [ ] Create AuthenticationAPI client
- [ ] Add token storage in Keychain
- [ ] Implement token refresh logic
- [ ] Add logout with token invalidation

### 2. Course Data Integration (5 story points)
**As a** user  
**I want to** see real courses from the backend  
**So that** I can access actual learning content

**Tasks:**
- [ ] Create CourseAPI client
- [ ] Map API responses to models
- [ ] Implement pagination
- [ ] Add pull-to-refresh
- [ ] Cache courses locally

### 3. Offline Mode (8 story points)
**As a** user  
**I want to** access content offline  
**So that** I can learn without internet

**Tasks:**
- [ ] Setup Core Data for local storage
- [ ] Implement sync mechanism
- [ ] Add offline indicators
- [ ] Queue actions for sync
- [ ] Handle conflicts

### 4. Push Notifications (5 story points)
**As a** user  
**I want to** receive notifications  
**So that** I stay informed about updates

**Tasks:**
- [ ] Setup push notification entitlements
- [ ] Implement registration flow
- [ ] Create notification handlers
- [ ] Add in-app notification display
- [ ] Test with sandbox environment

### 5. Error Handling (3 story points)
**As a** user  
**I want to** see helpful error messages  
**So that** I know what went wrong

**Tasks:**
- [ ] Create error presentation system
- [ ] Add retry mechanisms
- [ ] Implement fallback to cached data
- [ ] Add network status monitoring
- [ ] Create user-friendly error messages

## 🏗️ Technical Tasks

### Backend Setup
```yaml
Base URL Configuration:
  - Development: https://dev-api.lms.tsum.ru
  - Staging: https://staging-api.lms.tsum.ru  
  - Production: https://api.lms.tsum.ru

API Endpoints:
  - POST /auth/login
  - POST /auth/refresh
  - GET /courses
  - GET /courses/{id}
  - GET /user/profile
  - GET /user/progress
```

### Network Layer Architecture
```swift
NetworkService/
├── Core/
│   ├── NetworkService.swift
│   ├── APIEndpoint.swift
│   └── NetworkError.swift
├── Authentication/
│   ├── AuthAPI.swift
│   └── TokenManager.swift
├── Courses/
│   └── CourseAPI.swift
└── User/
    └── UserAPI.swift
```

## 📱 Implementation Priority

### Day 1-2: Network Foundation
- NetworkService implementation
- Authentication flow
- Token management
- Basic error handling

### Day 3: Data Integration
- Course API integration
- User profile integration
- Data mapping and models

### Day 4: Offline Mode
- Core Data setup
- Basic caching
- Sync mechanism

### Day 5: Polish & Testing
- Push notifications
- Error handling improvements
- Integration testing
- Bug fixes

## ✅ Definition of Done

- [ ] All API endpoints integrated
- [ ] Offline mode works for courses
- [ ] Push notifications registered
- [ ] Error handling covers all cases
- [ ] No hardcoded URLs or credentials
- [ ] All tests passing
- [ ] Successfully deployed to TestFlight

## 🚀 Демо сценарий для Sprint Review

1. **Login Flow**: Вход с реальными credentials
2. **Course Loading**: Загрузка курсов с backend
3. **Offline Mode**: Отключить интернет и показать кеш
4. **Push Notification**: Получить тестовое уведомление
5. **Error Recovery**: Показать обработку ошибок

## 📊 Метрики успеха

- API response time < 2 секунды
- Offline mode доступен для 100% курсов
- 0 крашей при отсутствии интернета
- Push notifications доставляются в 95% случаев

---

**Note**: Если backend API еще не готов, используем mock server или JSONPlaceholder для демонстрации интеграции. 