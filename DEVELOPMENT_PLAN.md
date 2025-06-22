# План разработки LMS "ЦУМ: Корпоративный университет"

## Обзор проекта
- **Старт разработки:** Январь 2025
- **MVP релиз:** Q2 2025 (Июнь)
- **Методология:** Agile, 2-недельные спринты
- **Подход:** LLM-driven development с маленькими итерациями

## Фаза 0: Подготовка (Текущая неделя)
### Задачи:
- [x] Создание технического задания
- [x] Структура проекта для LLM
- [ ] Инициализация репозитория
- [ ] Настройка окружения разработки
- [ ] CI/CD pipeline базовая настройка

## Спринт 1: Базовая инфраструктура (Недели 1-2)
### Цель: Создать фундамент приложения и общие компоненты

#### Неделя 1: Common компоненты
**День 1-2: Интерфейсы и базовые классы**
- `src/Common/Interfaces/RepositoryInterface.php`
- `src/Common/Interfaces/ServiceInterface.php`
- `src/Common/Interfaces/ValidatorInterface.php`
- `src/Common/Base/BaseRepository.php`
- `src/Common/Base/BaseService.php`

**День 3-4: Трейты и утилиты**
- `src/Common/Traits/HasTimestamps.php`
- `src/Common/Traits/Cacheable.php`
- `src/Common/Traits/Loggable.php`
- `src/Common/Utils/DateHelper.php`
- `src/Common/Utils/StringHelper.php`

**День 5: Исключения и обработка ошибок**
- `src/Common/Exceptions/ValidationException.php`
- `src/Common/Exceptions/NotFoundException.php`
- `src/Common/Exceptions/AuthorizationException.php`
- `src/Common/Exceptions/BusinessLogicException.php`
- `src/Common/Http/ErrorHandler.php`

#### Неделя 2: Конфигурация и роутинг
**День 6-7: Конфигурация**
- `config/app.php`
- `config/database.php`
- `config/auth.php`
- `config/services.php`
- `.env.example`

**День 8-9: Роутинг и middleware**
- `config/routes/api.php`
- `config/routes/web.php`
- `src/Common/Middleware/AuthMiddleware.php`
- `src/Common/Middleware/CorsMiddleware.php`
- `src/Common/Middleware/LoggingMiddleware.php`

**День 10: Docker и инфраструктура**
- `docker-compose.yml`
- `Dockerfile`
- `docker/nginx/default.conf`
- `docker/php/php.ini`
- База данных миграций

### Deliverables Sprint 1:
- ✅ Работающее Docker окружение
- ✅ Базовая структура проекта
- ✅ Общие компоненты и интерфейсы
- ✅ Конфигурация приложения

## Спринт 2: User Management - Core (Недели 3-4)
### Цель: Базовая аутентификация и управление пользователями

#### Неделя 3: Domain и Repository слой
**День 11-12: Domain модели**
- `src/User/Domain/User.php`
- `src/User/Domain/Role.php`
- `src/User/Domain/Permission.php`
- `database/migrations/001_create_users_table.sql`
- `database/migrations/002_create_roles_table.sql`

**День 13-14: Репозитории**
- `src/User/Repository/UserRepositoryInterface.php`
- `src/User/Repository/UserRepository.php`
- `src/User/Repository/RoleRepositoryInterface.php`
- `src/User/Repository/RoleRepository.php`
- Unit тесты для репозиториев

**День 15: Value Objects и Events**
- `src/User/ValueObject/Email.php`
- `src/User/ValueObject/UserId.php`
- `src/User/Event/UserCreated.php`
- `src/User/Event/UserLoggedIn.php`
- `src/User/Event/PasswordChanged.php`

#### Неделя 4: Service и Controller слой
**День 16-17: Сервисы аутентификации**
- `src/User/Service/AuthenticationService.php`
- `src/User/Service/TokenService.php`
- `src/User/Service/PasswordService.php`
- Unit тесты для сервисов
- `config/jwt.php`

**День 18-19: Контроллеры и API**
- `src/User/Controller/AuthController.php`
- `src/User/Controller/UserController.php`
- `src/User/Request/LoginRequest.php`
- `src/User/Response/TokenResponse.php`
- Integration тесты API

**День 20: Документация и рефакторинг**
- API документация (OpenAPI)
- Postman коллекция
- README для User сервиса
- Code review и рефакторинг

### Deliverables Sprint 2:
- ✅ Работающая аутентификация
- ✅ JWT токены
- ✅ CRUD для пользователей
- ✅ Базовые роли и права

## Спринт 3: Active Directory Integration (Недели 5-6)
### Цель: Интеграция с Microsoft AD для SSO

#### Неделя 5: LDAP интеграция
**День 21-22: LDAP сервис**
- `src/User/Service/LdapService.php`
- `src/User/Service/LdapConnectionFactory.php`
- `config/ldap.php`
- `src/User/ValueObject/LdapUser.php`
- Unit тесты с mock LDAP

**День 23-24: Синхронизация пользователей**
- `src/User/Service/UserSyncService.php`
- `src/User/Command/SyncUsersCommand.php`
- `database/migrations/003_add_ad_fields_to_users.sql`
- Логирование синхронизации
- Обработка ошибок

**День 25: SAML подготовка**
- `config/saml.php`
- `src/User/Service/SamlService.php`
- Базовая конфигурация SimpleSAMLphp
- Тестовый IdP setup

#### Неделя 6: SSO и автоматизация
**День 26-27: SSO контроллеры**
- `src/User/Controller/SsoController.php`
- `src/User/Middleware/SsoMiddleware.php`
- Обработка SAML ответов
- Автоматическое создание пользователей
- Тесты SSO flow

**День 28-29: Scheduled синхронизация**
- `src/User/Schedule/UserSyncSchedule.php`
- Cron job для синхронизации
- Уведомления об ошибках
- Мониторинг синхронизации
- Performance оптимизация

**День 30: Интеграционное тестирование**
- End-to-end тесты AD
- Тестирование отказоустойчивости
- Документация по настройке AD
- Troubleshooting guide

### Deliverables Sprint 3:
- ✅ LDAP аутентификация
- ✅ SAML SSO
- ✅ Автоматическая синхронизация пользователей
- ✅ Полная интеграция с AD

## Спринт 4: Competency Management Core (Недели 7-8)
### Цель: Базовое управление компетенциями

#### Неделя 7: Domain и хранение
**День 31-32: Domain модели компетенций**
- `src/Competency/Domain/Competency.php`
- `src/Competency/Domain/CompetencyLevel.php`
- `src/Competency/Domain/CompetencyCategory.php`
- `database/migrations/004_create_competencies_tables.sql`
- Seeders для тестовых данных

**День 33-34: Репозитории и поиск**
- `src/Competency/Repository/CompetencyRepositoryInterface.php`
- `src/Competency/Repository/CompetencyRepository.php`
- `src/Competency/Repository/CompetencySearchRepository.php`
- Elasticsearch интеграция
- Unit тесты

**День 35: Value Objects**
- `src/Competency/ValueObject/CompetencyColor.php`
- `src/Competency/ValueObject/LevelDescription.php`
- `src/Competency/ValueObject/CompetencyId.php`
- Валидация значений
- Тесты value objects

#### Неделя 8: Бизнес-логика и API
**День 36-37: Сервисы компетенций**
- `src/Competency/Service/CompetencyService.php`
- `src/Competency/Service/CompetencyMappingService.php`
- `src/Competency/Service/CompetencyValidationService.php`
- Бизнес-правила
- Unit тесты сервисов

**День 38-39: API контроллеры**
- `src/Competency/Controller/CompetencyController.php`
- `src/Competency/Controller/CompetencyCategoryController.php`
- `src/Competency/Request/CreateCompetencyRequest.php`
- `src/Competency/Response/CompetencyResponse.php`
- API тесты

**День 40: Связь с должностями**
- `src/Competency/Service/PositionCompetencyService.php`
- `database/migrations/005_create_position_competencies_table.sql`
- API для привязки компетенций
- Массовые операции
- Performance тесты

### Deliverables Sprint 4:
- ✅ CRUD компетенций
- ✅ Категоризация и уровни
- ✅ Привязка к должностям
- ✅ Поиск компетенций

## Спринт 5: Learning Service - Courses (Недели 9-10)
### Цель: Управление курсами и материалами

#### Неделя 9: Курсы и модули
**День 41-42: Domain курсов**
- `src/Learning/Domain/Course/Course.php`
- `src/Learning/Domain/Course/CourseModule.php`
- `src/Learning/Domain/Course/CourseCategory.php`
- `database/migrations/006_create_courses_tables.sql`
- Связи с компетенциями

**День 43-44: Материалы и файлы**
- `src/Learning/Domain/Material/Material.php`
- `src/Learning/Domain/Material/MaterialType.php`
- `src/Learning/Service/FileStorageService.php`
- S3/локальное хранилище
- Обработка загрузок

**День 45: Репозитории курсов**
- `src/Learning/Repository/CourseRepositoryInterface.php`
- `src/Learning/Repository/CourseRepository.php`
- `src/Learning/Repository/ModuleRepository.php`
- Фильтрация и пагинация
- Unit тесты

#### Неделя 10: Enrollment и прогресс
**День 46-47: Enrollment сервис**
- `src/Learning/Service/EnrollmentService.php`
- `src/Learning/Domain/Enrollment/Enrollment.php`
- `database/migrations/007_create_enrollments_table.sql`
- Правила записи на курсы
- Уведомления о записи

**День 48-49: Tracking прогресса**
- `src/Learning/Domain/Progress/UserProgress.php`
- `src/Learning/Service/ProgressTrackingService.php`
- `database/migrations/008_create_progress_tables.sql`
- Автоматический подсчет
- API для обновления прогресса

**День 50: API и интеграция**
- `src/Learning/Controller/CourseController.php`
- `src/Learning/Controller/EnrollmentController.php`
- `src/Learning/Controller/ProgressController.php`
- Batch операции
- Performance оптимизация

### Deliverables Sprint 5:
- ✅ Управление курсами
- ✅ Загрузка материалов
- ✅ Запись на курсы
- ✅ Отслеживание прогресса

## Спринт 6: Testing System (Недели 11-12)
### Цель: Система тестирования и сертификаты

#### Неделя 11: Тесты и вопросы
**День 51-52: Domain тестов**
- `src/Learning/Domain/Test/Test.php`
- `src/Learning/Domain/Test/Question.php`
- `src/Learning/Domain/Test/Answer.php`
- `database/migrations/009_create_tests_tables.sql`
- Типы вопросов

**День 53-54: Сервис тестирования**
- `src/Learning/Service/TestService.php`
- `src/Learning/Service/TestSessionService.php`
- `src/Learning/Domain/Test/TestSession.php`
- Логика прохождения
- Подсчет результатов

**День 55: Безопасность тестов**
- Защита от читинга
- Ограничение времени
- Случайный порядок вопросов
- Логирование попыток
- Обработка сбоев

#### Неделя 12: Сертификаты
**День 56-57: Генерация сертификатов**
- `src/Learning/Service/CertificateService.php`
- `src/Learning/Domain/Certificate/Certificate.php`
- PDF генерация
- QR коды для проверки
- Шаблоны сертификатов

**День 58-59: API и хранение**
- `src/Learning/Controller/TestController.php`
- `src/Learning/Controller/CertificateController.php`
- Публичная проверка сертификатов
- Массовая выгрузка
- Статистика по тестам

**День 60: Интеграция с курсами**
- Автоматические сертификаты
- Условия получения
- Уведомления о сертификатах
- Интеграционные тесты
- Документация

### Deliverables Sprint 6:
- ✅ Создание и прохождение тестов
- ✅ Автоматическая проверка
- ✅ Генерация сертификатов
- ✅ Проверка подлинности

## Спринт 7: Program Service - Onboarding (Недели 13-14)
### Цель: Программы развития и онбординг

#### Неделя 13: Шаблоны программ
**День 61-62: Domain программ**
- `src/Program/Domain/Program.php`
- `src/Program/Domain/ProgramTemplate.php`
- `src/Program/Domain/ProgramStage.php`
- `database/migrations/010_create_programs_tables.sql`
- Типы программ

**День 63-64: Конструктор программ**
- `src/Program/Service/ProgramBuilderService.php`
- `src/Program/Service/TemplateService.php`
- Валидация этапов
- Зависимости между этапами
- Клонирование шаблонов

**День 65: Назначение программ**
- `src/Program/Service/ProgramAssignmentService.php`
- `src/Program/Domain/ProgramAssignment.php`
- Массовые назначения
- Автоматизация по должностям
- Unit тесты

#### Неделя 14: Выполнение и мониторинг
**День 66-67: Прогресс программ**
- `src/Program/Service/ProgramProgressService.php`
- `src/Program/Domain/StageProgress.php`
- Автоматическое продвижение
- Блокировки этапов
- Дедлайны

**День 68-69: Онбординг специфика**
- `src/Program/Service/OnboardingService.php`
- Интеграция с HR событиями
- Автоматический старт
- Менторство
- Чек-листы

**День 70: API и отчеты**
- `src/Program/Controller/ProgramController.php`
- `src/Program/Controller/OnboardingController.php`
- Дашборд прогресса
- Экспорт отчетов
- Performance тесты

### Deliverables Sprint 7:
- ✅ Шаблоны программ развития
- ✅ Автоматический онбординг
- ✅ Отслеживание выполнения
- ✅ Отчеты для HR

## Спринт 8: Notifications & Events (Недели 15-16)
### Цель: Система уведомлений и событий

#### Неделя 15: Event-driven архитектура
**День 71-72: Event bus**
- `src/Common/Event/EventBus.php`
- `src/Common/Event/EventDispatcher.php`
- RabbitMQ интеграция
- Обработка очередей
- Retry механизм

**День 73-74: Domain события**
- События всех сервисов
- `src/Notification/Event/NotificationEvent.php`
- Event listeners
- Асинхронная обработка
- Логирование событий

**День 75: Шаблоны уведомлений**
- `src/Notification/Domain/NotificationTemplate.php`
- `src/Notification/Service/TemplateEngine.php`
- Переменные в шаблонах
- Мультиязычность
- Preview режим

#### Неделя 16: Каналы доставки
**День 76-77: Email канал**
- `src/Notification/Channel/EmailChannel.php`
- `src/Notification/Service/EmailService.php`
- SMTP конфигурация
- Очереди отправки
- Bounce handling

**День 78-79: In-app уведомления**
- `src/Notification/Channel/DatabaseChannel.php`
- `src/Notification/Service/InAppNotificationService.php`
- Real-time через WebSocket
- Маркировка прочитанных
- Группировка уведомлений

**День 80: Планировщик и API**
- `src/Notification/Service/NotificationScheduler.php`
- `src/Notification/Controller/NotificationController.php`
- Массовые рассылки
- Отписка от уведомлений
- Аналитика доставки

### Deliverables Sprint 8:
- ✅ Event-driven коммуникация
- ✅ Email уведомления
- ✅ In-app уведомления
- ✅ Управление подписками

## Спринт 9: Analytics Foundation (Недели 17-18)
### Цель: Базовая аналитика и отчеты

#### Неделя 17: Сбор метрик
**День 81-82: Метрики и события**
- `src/Analytics/Domain/Metric.php`
- `src/Analytics/Service/MetricCollector.php`
- `src/Analytics/Event/AnalyticsEvent.php`
- ClickHouse setup
- Batch вставки

**День 83-84: Агрегация данных**
- `src/Analytics/Service/AggregationService.php`
- `src/Analytics/Job/DailyAggregation.php`
- Предрасчет метрик
- Оптимизация запросов
- Кеширование результатов

**День 85: Базовые отчеты**
- `src/Analytics/Service/ReportService.php`
- `src/Analytics/Domain/Report.php`
- Шаблоны отчетов
- Параметризация
- Экспорт в Excel/PDF

#### Неделя 18: API и визуализация
**День 86-87: Analytics API**
- `src/Analytics/Controller/AnalyticsController.php`
- `src/Analytics/Controller/ReportController.php`
- Фильтры и группировки
- Time series данные
- Права доступа

**День 88-89: Дашборды**
- Базовые виджеты
- Конфигурация дашбордов
- Real-time метрики
- Экспорт графиков
- Mobile responsive

**День 90: Интеграция и оптимизация**
- Интеграция со всеми сервисами
- Performance тюнинг
- Мониторинг нагрузки
- Документация API
- Примеры использования

### Deliverables Sprint 9:
- ✅ Сбор метрик
- ✅ Базовые отчеты
- ✅ API для аналитики
- ✅ Простые дашборды

## Спринт 10: Frontend Foundation (Недели 19-20)
### Цель: Базовый UI/UX

#### Неделя 19: Архитектура frontend
**День 91-92: Setup и структура**
- Vue.js 3 + TypeScript setup
- Компонентная архитектура
- Vuex store структура
- Router конфигурация
- API client

**День 93-94: UI Kit**
- Базовые компоненты
- Дизайн система
- Tailwind конфигурация
- Формы и валидация
- Нотификации

**День 95: Аутентификация UI**
- Login/Logout
- JWT handling
- Route guards
- Session management
- Error handling

#### Неделя 20: Основные страницы
**День 96-97: Личный кабинет**
- Dashboard
- Профиль пользователя
- Мои курсы
- Мой прогресс
- Уведомления

**День 98-99: Каталог обучения**
- Список курсов
- Фильтры и поиск
- Детали курса
- Запись на курс
- Прохождение модулей

**День 100: Responsive и UX**
- Mobile адаптация
- Accessibility
- Loading states
- Error boundaries
- Performance оптимизация

### Deliverables Sprint 10:
- ✅ Работающий frontend
- ✅ Основные страницы
- ✅ Мобильная версия
- ✅ Базовый UI/UX

## Спринт 11-12: Интеграция и стабилизация (Недели 21-24)
### Цель: Подготовка к production

#### Спринт 11: Интеграция (Недели 21-22)
- End-to-end тестирование
- Performance оптимизация
- Security audit
- Load testing
- Bug fixes

#### Спринт 12: Production ready (Недели 23-24)
- CI/CD финализация
- Monitoring setup (Prometheus/Grafana)
- Backup стратегия
- Документация
- Обучение пользователей

### Final Deliverables:
- ✅ Production-ready система
- ✅ Полная документация
- ✅ Мониторинг и алерты
- ✅ План поддержки

## Метрики успеха проекта
1. **Code Quality**: Coverage > 80%, 0 critical bugs
2. **Performance**: Response time < 200ms (p95)
3. **Availability**: 99.5% uptime
4. **User Adoption**: 80% активных пользователей в первый месяц
5. **Time to Market**: Релиз в срок (Q2 2025)

## Риски и митигация
1. **AD интеграция**: Ранний доступ к тестовому AD
2. **Performance**: Регулярное load testing
3. **Scope creep**: Строгое следование MVP scope
4. **LLM limitations**: Маленькие итерации, code review
5. **Team scaling**: Документация с первого дня

## Инструменты разработки
- **IDE**: Cursor с LLM поддержкой
- **Version Control**: Git + GitHub
- **CI/CD**: GitHub Actions
- **Monitoring**: Prometheus + Grafana
- **APM**: New Relic / DataDog
- **Communication**: Slack
- **Project Management**: Jira / Linear 