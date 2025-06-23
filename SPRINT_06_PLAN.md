# План Sprint 6: UI Framework + User Management (Vertical Slice)

## 📋 Информация о спринте
- **Номер спринта**: 6
- **Название**: UI Foundation + Complete User Management
- **Планируемая длительность**: 5-7 дней
- **Планируемое количество тестов**: ~180 (backend: ~100, frontend: ~80)
- **Основная цель**: Создать базовый UI framework и полностью работающий User Management модуль

## 🎯 Цели спринта

### 1. UI Framework Setup
Настроить современный фронтенд стек:
- [ ] React 18 + TypeScript
- [ ] Vite для быстрой сборки
- [ ] TailwindCSS для стилей
- [ ] React Router для навигации
- [ ] Axios для API вызовов
- [ ] React Query для state management
- [ ] Jest + React Testing Library

### 2. Design System Foundation
Создать базовые UI компоненты:
- [ ] Layout компоненты (Header, Sidebar, Content)
- [ ] Form компоненты (Input, Select, Button)
- [ ] Feedback компоненты (Alert, Modal, Toast)
- [ ] Table компонент с сортировкой и пагинацией
- [ ] Loading и Error states

### 3. User Management - Full Stack
Полный вертикальный срез функционала:

#### Backend (интеграция существующего):
- [ ] Doctrine UserRepository
- [ ] API endpoints с JWT authentication
- [ ] Database migrations
- [ ] Integration tests

#### Frontend:
- [ ] Страница логина
- [ ] Личный кабинет пользователя
- [ ] Список пользователей (admin)
- [ ] Создание/редактирование пользователя
- [ ] Управление ролями
- [ ] Сброс пароля

### 4. Authentication Flow
End-to-end аутентификация:
- [ ] JWT token management
- [ ] Refresh token logic
- [ ] Protected routes
- [ ] Logout functionality
- [ ] Remember me option

### 5. API Integration Layer
Связь frontend и backend:
- [ ] API client с interceptors
- [ ] Error handling
- [ ] Loading states
- [ ] Optimistic updates
- [ ] Request retry logic

## 📊 Планируемая декомпозиция по дням

### День 1: UI Framework Setup
- Инициализация React проекта
- Настройка build tools (Vite)
- Установка и конфигурация библиотек
- Базовая структура проекта
- Настройка тестового окружения
- Тесты: ~15

### День 2: Design System
- Создание базовых компонентов
- Настройка TailwindCSS
- Storybook для компонентов (опционально)
- Unit тесты компонентов
- Тесты: ~25

### День 3: Authentication UI
- Страница логина
- JWT token management
- Protected routes setup
- Logout функционал
- Тесты: ~20

### День 4: User Management UI
- Список пользователей
- Форма создания/редактирования
- Модальные окна
- Управление ролями UI
- Тесты: ~20

### День 5: Backend Integration
- Doctrine repositories
- API endpoints
- Database migrations
- JWT implementation
- Тесты: ~40

### День 6: Full Integration
- Связка frontend + backend
- End-to-end flows
- Error handling
- Performance optimization
- Тесты: ~30

### День 7: Polish & Testing
- UI/UX улучшения
- E2E тесты (Cypress)
- Документация
- Bug fixes
- Тесты: ~30

## 🏗️ Технические решения

### Frontend Stack
```yaml
Framework: React 18
Язык: TypeScript
Сборка: Vite
Стили: TailwindCSS
Routing: React Router v6
State: React Query + Context
Forms: React Hook Form
Validation: Zod
Testing: Jest + RTL + Cypress
```

### Структура frontend проекта
```
frontend/
├── src/
│   ├── components/     # Переиспользуемые компоненты
│   │   ├── common/     # Button, Input, etc.
│   │   ├── layout/     # Header, Sidebar
│   │   └── forms/      # Form components
│   ├── features/       # Функциональные модули
│   │   ├── auth/       # Login, logout
│   │   └── users/      # User management
│   ├── services/       # API services
│   ├── hooks/          # Custom hooks
│   ├── utils/          # Helpers
│   └── types/          # TypeScript types
├── tests/              # Тесты
└── public/             # Статика
```

### API Design
```yaml
Endpoints:
  POST   /api/auth/login
  POST   /api/auth/refresh
  POST   /api/auth/logout
  GET    /api/users
  GET    /api/users/{id}
  POST   /api/users
  PUT    /api/users/{id}
  DELETE /api/users/{id}
  GET    /api/roles
  PUT    /api/users/{id}/roles
```

## 📈 Метрики успеха

### Обязательные:
- [ ] Пользователь может войти в систему
- [ ] Админ может управлять пользователями
- [ ] Все CRUD операции работают
- [ ] JWT токены корректно обновляются
- [ ] Тесты покрывают > 80% кода

### Желательные:
- [ ] Время загрузки страницы < 1s
- [ ] Responsive дизайн
- [ ] Доступность (a11y)
- [ ] PWA capabilities
- [ ] Оффлайн поддержка форм

## ⚠️ Риски и митигация

### Риск 1: Сложность настройки окружения
**Митигация**: Использовать create-vite с готовым шаблоном

### Риск 2: Несовместимость API
**Митигация**: Начать с API design и контрактов

### Риск 3: Сложность тестирования
**Митигация**: TDD для компонентов, MSW для API mocking

## 📋 Definition of Done

Для каждой задачи:
- [ ] Компонент написан через TDD
- [ ] Unit тесты проходят
- [ ] Storybook story создана (для UI)
- [ ] Доступность проверена
- [ ] Responsive дизайн работает

Для спринта:
- [ ] Пользователь может полностью работать с системой
- [ ] Frontend и Backend интегрированы
- [ ] E2E тесты проходят
- [ ] Документация обновлена
- [ ] Можно показать стейкхолдерам

## 🎯 Ожидаемые результаты

К концу спринта:
1. **Работающее приложение** с настоящим UI
2. **Полный User Management** - от UI до БД
3. **Готовый UI framework** для остальных модулей
4. **Валидация архитектуры** на реальном примере
5. **Обратная связь** от первых пользователей

## 🚀 Быстрый старт для разработки

```bash
# Backend (уже есть)
./test-quick.sh

# Frontend (новое)
cd frontend
npm install
npm run dev     # Запуск dev сервера
npm test        # Запуск тестов
npm run build   # Production сборка
```

---

**Старт спринта**: После утверждения плана  
**Методология**: TDD для backend и frontend  
**Приоритет**: Сначала минимальный рабочий flow (login → user list) 