# Sprint 8: Frontend Development (Vertical Slice)

**Даты:** 2025-01-20 - 2025-01-24 (5 дней)  
**Цель:** Реализовать полный функционал входа через VK ID на Frontend с интеграцией Backend

## 🎯 Цели спринта

1. **Frontend VK ID Authentication** - полный flow входа
2. **React Components with TDD** - компонентная разработка через тесты
3. **Backend API Integration** - подключение к реальным endpoints
4. **E2E Tests** - сквозные тесты критических путей
5. **UI/UX Polish** - финальная доводка интерфейса

## 📋 User Stories

### Story 1: VK ID Login Component
**Как** пользователь  
**Я хочу** войти через VK ID  
**Чтобы** получить доступ к платформе обучения

**Acceptance Criteria:**
```gherkin
Feature: VK ID Authentication

Scenario: Successful login
  Given I am on the login page
  When I click "Войти через VK ID"
  And I authorize in VK popup
  Then I should be redirected to dashboard
  And I should see my VK name

Scenario: First time login
  Given I am a new user
  When I complete VK authorization
  Then I should see "Ожидание одобрения" status
  And I should receive confirmation email
```

### Story 2: Dashboard with User Data
**Как** авторизованный пользователь  
**Я хочу** видеть персонализированную главную страницу  
**Чтобы** быстро получить доступ к моим курсам

**Acceptance Criteria:**
- Отображение имени пользователя из VK
- Список активных курсов
- Прогресс обучения
- Быстрые действия

### Story 3: Course Catalog Integration
**Как** студент  
**Я хочу** просматривать доступные курсы  
**Чтобы** выбрать подходящее обучение

**Acceptance Criteria:**
- Загрузка курсов через API
- Фильтрация и поиск
- Детальная информация о курсе
- Кнопка записи на курс

## 🏗️ Техническая архитектура

### Frontend Stack:
- React 18 + TypeScript
- Vite для сборки
- React Query для API
- React Router для навигации
- Tailwind CSS для стилей
- Jest + React Testing Library для тестов

### Структура компонентов:
```
frontend/src/
├── features/
│   ├── auth/
│   │   ├── components/
│   │   │   ├── VKLoginButton.tsx
│   │   │   ├── VKLoginButton.test.tsx
│   │   │   └── PendingApproval.tsx
│   │   ├── hooks/
│   │   │   └── useVKAuth.ts
│   │   └── services/
│   │       └── vkAuthService.ts
│   ├── dashboard/
│   │   ├── components/
│   │   │   ├── Dashboard.tsx
│   │   │   └── Dashboard.test.tsx
│   └── courses/
│       ├── components/
│       │   ├── CourseList.tsx
│       │   ├── CourseCard.tsx
│       │   └── CourseDetail.tsx
├── shared/
│   ├── api/
│   │   └── apiClient.ts
│   └── components/
│       └── Layout.tsx
└── e2e/
    └── auth.spec.ts
```

## 📅 План по дням

### День 1: Setup & VK Auth Component
- [ ] Настройка React проекта с Vite
- [ ] TDD: VKLoginButton тесты
- [ ] Реализация VKLoginButton
- [ ] Интеграция VK SDK

### День 2: Auth Flow & State
- [ ] TDD: useVKAuth hook тесты
- [ ] Реализация auth state management
- [ ] PendingApproval компонент
- [ ] Роутинг после авторизации

### День 3: Dashboard & API Integration
- [ ] TDD: Dashboard тесты
- [ ] API client setup
- [ ] Dashboard с данными пользователя
- [ ] React Query интеграция

### День 4: Course Catalog
- [ ] TDD: CourseList тесты
- [ ] Компоненты каталога курсов
- [ ] Поиск и фильтрация
- [ ] Course detail view

### День 5: E2E Tests & Polish
- [ ] Playwright setup
- [ ] E2E тесты auth flow
- [ ] UI/UX improvements
- [ ] Performance optimization

## ✅ Definition of Done

### Story Level:
- [ ] Все unit тесты написаны и проходят
- [ ] Компоненты протестированы через RTL
- [ ] API интеграция работает
- [ ] E2E тесты проходят
- [ ] Код review пройден

### Sprint Level:
- [ ] VK ID auth полностью работает
- [ ] Dashboard загружает реальные данные
- [ ] Курсы отображаются из API
- [ ] Производительность < 3s загрузка
- [ ] Доступность WCAG 2.1 AA

## 📊 Метрики успеха

- Test coverage > 80%
- Все критические пути покрыты E2E
- Performance score > 90 (Lighthouse)
- 0 критических багов
- Успешная демонстрация stakeholders

## 🚨 Риски

1. **VK SDK интеграция** - может потребовать дополнительной настройки
2. **CORS issues** - настройка backend для frontend запросов
3. **State management** - сложность с токенами и refresh
4. **Mobile responsiveness** - дополнительное время на адаптацию

## 🔧 Технические требования

### Environment Variables:
```env
VITE_API_URL=http://localhost:8000/api
VITE_VK_APP_ID=your_vk_app_id
VITE_VK_REDIRECT_URI=http://localhost:5173/auth/callback
```

### API Endpoints:
- POST `/api/auth/vk` - VK token exchange
- GET `/api/user/me` - Current user info
- GET `/api/courses` - Course list
- GET `/api/courses/{id}` - Course detail

## 🎯 MVP Scope

Для этого спринта фокусируемся на:
1. ✅ Рабочий VK ID login
2. ✅ Базовый dashboard
3. ✅ Список курсов
4. ✅ Простая навигация

Откладываем на следующий спринт:
- ❌ Сложные фильтры курсов
- ❌ Уведомления
- ❌ Офлайн режим
- ❌ Расширенная аналитика

---

**Готовность к старту:** ✅ Все технические требования определены, команда готова к vertical slice разработке Frontend. 