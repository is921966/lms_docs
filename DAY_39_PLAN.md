# День 39 (Sprint 6, День 3): Navigation + Settings + Courses

## 🎯 Цели на день

### 1. Main Navigation Structure
- [ ] MainTabView с TabBar навигацией
- [ ] Интеграция всех основных экранов
- [ ] Правильная обработка deep links
- [ ] Badge для уведомлений

### 2. Settings Screen
- [ ] ProfileSection - информация о текущем пользователе
- [ ] Admin Mode Toggle (только для админов)
- [ ] Настройки уведомлений
- [ ] About & Support секция
- [ ] Logout функциональность

### 3. Course Management
- [ ] CourseViewModel - загрузка и фильтрация курсов
- [ ] CourseListView - список курсов
- [ ] CourseCard - карточка курса
- [ ] Enrollment статусы и прогресс

### 4. Profile Screen
- [ ] Текущий пользователь информация
- [ ] Статистика обучения
- [ ] Достижения и сертификаты
- [ ] Редактирование профиля

## 📋 План работы

### Утро: Navigation & Settings
1. MainTabView с 4 табами:
   - Courses
   - Users (admin only)
   - Profile
   - Settings
2. SettingsView с полным функционалом
3. Тесты для Settings логики

### День: Course Management
1. CourseViewModel с бизнес-логикой
2. CourseListView с категориями
3. CourseCard с прогрессом
4. Тесты для CourseViewModel

### Вечер: Profile & Integration
1. ProfileView с статистикой
2. Интеграция всех экранов
3. E2E тест основного flow
4. Проверка работы Admin Mode

## 🏗️ Архитектура

```
Features/
├── Navigation/
│   └── MainTabView.swift
├── Settings/
│   ├── Views/
│   │   └── SettingsView.swift
│   └── ViewModels/
│       └── SettingsViewModel.swift
├── Courses/
│   ├── Views/
│   │   ├── CourseListView.swift
│   │   └── CourseCard.swift
│   └── ViewModels/
│       └── CourseViewModel.swift
└── Profile/
    ├── Views/
    │   └── ProfileView.swift
    └── ViewModels/
        └── ProfileViewModel.swift
```

## ⏱️ Ожидаемое время
- Navigation & Settings: ~50 минут
- Course Management: ~60 минут
- Profile Screen: ~40 минут
- Integration & Testing: ~30 минут
- **Итого**: ~180 минут

## 📊 Ожидаемые метрики
- Новых файлов: ~12
- Тестов: ~20
- UI экранов: 4 основных
- Полная навигация приложения

Начинаем с MainTabView! 