# Детальный план спринтов для Production

## Sprint 1: Backend Integration Foundation
**Даты**: 1-14 июля 2025  
**Story Points**: 34

### User Stories

#### US-1.1: Как администратор, я хочу входить в систему через корпоративный AD
**Acceptance Criteria**:
- Вход через email/password из Active Directory
- Автоматическая синхронизация ролей
- Session management (JWT tokens)
- Logout функциональность

**Tasks**:
- Backend: LDAP connector (8h)
- Backend: JWT implementation (4h)
- iOS: Replace MockAuthService (6h)
- iOS: Token storage in Keychain (4h)
- Testing: Integration tests (4h)

#### US-1.2: Как пользователь, я хочу видеть реальные курсы из базы данных
**Acceptance Criteria**:
- Список курсов загружается с API
- Поиск и фильтрация работают
- Обработка ошибок сети
- Loading states

**Tasks**:
- Backend: Courses CRUD API (8h)
- Backend: Search/filter endpoints (4h)
- iOS: NetworkService implementation (6h)
- iOS: CourseAPIClient (4h)
- iOS: Error handling UI (4h)

#### US-1.3: Как разработчик, я хочу иметь надежный сетевой слой
**Acceptance Criteria**:
- Retry логика для failed requests
- Request/Response interceptors
- Логирование для debug
- Timeout handling

**Tasks**:
- iOS: NetworkManager with URLSession (8h)
- iOS: Request builders (4h)
- iOS: Response validators (4h)
- iOS: NetworkLogger (2h)

### Technical Debt:
- Рефакторинг MockServices на protocols (4h)
- Обновление тестов под real API (6h)

---

## Sprint 2: Core Features API Integration
**Даты**: 15-28 июля 2025  
**Story Points**: 42

### User Stories

#### US-2.1: Как студент, я хочу проходить тесты с сохранением на сервере
**Acceptance Criteria**:
- Загрузка тестов с API
- Отправка ответов в real-time
- Сохранение прогресса
- Получение результатов

**Tasks**:
- Backend: Tests API (8h)
- Backend: Results processing (6h)
- iOS: TestAPIClient (6h)
- iOS: Offline queue for answers (8h)
- Testing: E2E test scenarios (4h)

#### US-2.2: Как HR, я хочу управлять компетенциями сотрудников
**Acceptance Criteria**:
- CRUD операции для компетенций
- Привязка к пользователям
- История изменений
- Bulk операции

**Tasks**:
- Backend: Competencies API (6h)
- Backend: Audit log (4h)
- iOS: CompetencyAPIClient (4h)
- iOS: Bulk operations UI (6h)

#### US-2.3: Как пользователь, я хочу работать offline
**Acceptance Criteria**:
- Просмотр загруженных курсов offline
- Queue для операций
- Синхронизация при подключении
- Конфликты резолвятся корректно

**Tasks**:
- iOS: Core Data setup (8h)
- iOS: Sync engine (12h)
- iOS: Conflict resolution (8h)
- Testing: Offline scenarios (6h)

---

## Sprint 3: Security & Performance
**Даты**: 29 июля - 11 августа 2025  
**Story Points**: 38

### User Stories

#### US-3.1: Как пользователь, я хочу быстрый и безопасный вход
**Acceptance Criteria**:
- Face ID/Touch ID поддержка
- Remember me функция
- Auto-logout после неактивности
- Secure token refresh

**Tasks**:
- iOS: Biometric auth (6h)
- iOS: Session management (4h)
- iOS: Auto-logout timer (2h)
- Backend: Refresh token endpoint (4h)

#### US-3.2: Как администратор, я хочу мониторить производительность
**Acceptance Criteria**:
- Crash reports в реальном времени
- Performance metrics
- User behavior analytics
- Custom events

**Tasks**:
- iOS: Firebase Crashlytics setup (4h)
- iOS: Performance monitoring (4h)
- iOS: Analytics events (6h)
- Backend: Metrics aggregation (6h)

#### US-3.3: Как пользователь, я хочу быстрое приложение
**Acceptance Criteria**:
- App start < 2 секунды
- Smooth scrolling (60 fps)
- Images load progressively
- No memory leaks

**Tasks**:
- iOS: Startup optimization (8h)
- iOS: Image caching layer (6h)
- iOS: Memory profiling (4h)
- iOS: UI optimizations (6h)

---

## Sprint 4: Polish & App Store
**Даты**: 12-25 августа 2025  
**Story Points**: 32

### User Stories

#### US-4.1: Как пользователь, я хочу получать push-уведомления
**Acceptance Criteria**:
- Уведомления о новых курсах
- Напоминания о дедлайнах
- Результаты тестов
- Настройки уведомлений

**Tasks**:
- Backend: Push service (8h)
- iOS: Push notifications setup (6h)
- iOS: Notification settings UI (4h)
- Testing: Push scenarios (4h)

#### US-4.2: Как маркетолог, я хочу привлекательное App Store присутствие
**Acceptance Criteria**:
- Screenshots для всех размеров
- Локализованные описания
- App Preview видео
- Оптимизированные keywords

**Tasks**:
- Design: Screenshot templates (8h)
- Content: Descriptions RU/EN (4h)
- Video: App preview (8h)
- ASO optimization (4h)

#### US-4.3: Как пользователь, я хочу полированное приложение
**Acceptance Criteria**:
- Все анимации плавные
- Dark mode поддержка
- VoiceOver работает
- iPad оптимизация

**Tasks**:
- iOS: Animation polish (6h)
- iOS: Dark mode (8h)
- iOS: Accessibility (6h)
- iOS: iPad layouts (8h)

---

## 📊 Velocity и метрики

### Ожидаемая velocity:
- Sprint 1: 34 SP (setup sprint)
- Sprint 2: 42 SP (peak productivity)
- Sprint 3: 38 SP (сложные задачи)
- Sprint 4: 32 SP (polish и подготовка)

### Распределение времени:
- Backend: 30%
- iOS Development: 50%
- Testing: 15%
- DevOps/Infrastructure: 5%

### Риски по спринтам:
1. **Sprint 1**: Сложности с LDAP интеграцией
2. **Sprint 2**: Синхронизация данных может занять больше времени
3. **Sprint 3**: Performance оптимизация непредсказуема
4. **Sprint 4**: App Store review может затянуться

## 🔧 Технический стек для Production

### Backend:
- **Language**: Node.js/TypeScript или Go
- **Framework**: NestJS или Gin
- **Database**: PostgreSQL + Redis
- **Auth**: JWT + LDAP connector
- **API**: RESTful + OpenAPI docs

### iOS:
- **Network**: URLSession + Combine
- **Storage**: Core Data + Keychain
- **Analytics**: Firebase Suite
- **CI/CD**: GitHub Actions + Fastlane
- **Monitoring**: Crashlytics + Performance

### Infrastructure:
- **Hosting**: AWS ECS или Azure Container Instances
- **CDN**: CloudFlare
- **Storage**: S3 для файлов
- **Queue**: SQS или Azure Service Bus
- **Monitoring**: DataDog или New Relic

## 📈 Definition of Done для Production

### Code Quality:
- [ ] Code review пройден (2 approvals)
- [ ] Unit test coverage >80%
- [ ] Integration tests для критических путей
- [ ] No critical SonarQube issues
- [ ] Documentation updated

### Performance:
- [ ] API response time <500ms (p95)
- [ ] UI response time <100ms
- [ ] Memory usage stable
- [ ] No memory leaks
- [ ] Battery usage optimized

### Security:
- [ ] OWASP Top 10 проверено
- [ ] Penetration testing passed
- [ ] Data encryption implemented
- [ ] Security headers configured
- [ ] API rate limiting active

### Deployment:
- [ ] Blue-green deployment ready
- [ ] Rollback tested
- [ ] Monitoring configured
- [ ] Alerts set up
- [ ] Runbook created

## 🚀 Go-Live Checklist

### За неделю до релиза:
- [ ] Final regression testing
- [ ] Load testing (1000+ users)
- [ ] Security audit complete
- [ ] App Store submission
- [ ] Support team trained

### За день до релиза:
- [ ] Production backup
- [ ] DNS propagation check
- [ ] SSL certificates valid
- [ ] Monitoring dashboards ready
- [ ] On-call schedule set

### День релиза:
- [ ] Gradual rollout (10% → 50% → 100%)
- [ ] Real-time monitoring
- [ ] Support team standby
- [ ] Rollback plan ready
- [ ] Success metrics tracking

---

**Итого**: 4 спринта, 8 недель, ~146 story points
**Целевая дата Production**: 25 августа 2025 