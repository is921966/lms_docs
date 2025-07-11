# Sprint 46 Plan: Perplexity-Style Redesign

**Dates**: January 13-17, 2025  
**Goal**: Полный редизайн iOS приложения в стиле Perplexity AI  
**Version**: 3.0.0

## 🎯 Цели спринта

1. **Минималистичный дизайн** - чистый интерфейс с фокусом на контент
2. **AI-first подход** - интеграция поиска и AI-ассистента
3. **Современная навигация** - боковое меню вместо табов
4. **Темная тема по умолчанию** - как в Perplexity
5. **Анимации и переходы** - плавные и современные

## 🎨 Дизайн система Perplexity-style

### Цветовая палитра
```swift
// Primary Colors
Background: #0A0A0A (почти черный)
Surface: #1A1A1A (темно-серый)
Primary: #10A37F (зеленый акцент Perplexity)
Secondary: #8E8EA0 (серый текст)
Text: #FFFFFF (белый)
Muted: #565869 (приглушенный)

// Accent Colors
Blue: #3B82F6
Purple: #8B5CF6
Pink: #EC4899
```

### Типографика
```swift
// Headers
Title: SF Pro Display, 32pt, Bold
Subtitle: SF Pro Display, 20pt, Semibold
Section: SF Pro Text, 16pt, Medium

// Body
Body: SF Pro Text, 15pt, Regular
Caption: SF Pro Text, 13pt, Regular
```

### Компоненты UI

#### 1. Search Bar (главный элемент)
- Большое поле поиска по центру
- Placeholder: "Спросите что-нибудь..."
- AI иконка слева
- Микрофон справа

#### 2. Sidebar Navigation
- Выезжающее боковое меню
- Иконки + текст
- Разделы: Главная, Курсы, Профиль, Настройки

#### 3. Cards
- Закругленные углы (12px)
- Тонкая граница (#2A2A2A)
- Hover эффект с подсветкой
- Тень для глубины

#### 4. Buttons
- Primary: зеленый градиент
- Secondary: прозрачный с границей
- Закругленные (8px)

## 📱 Структура приложения

### Day 1: Core UI Components
1. **PerplexityTheme.swift** - цвета, шрифты, стили
2. **PerplexitySearchBar.swift** - главный поиск
3. **PerplexityCard.swift** - универсальная карточка
4. **PerplexityButton.swift** - стилизованные кнопки
5. **PerplexitySidebar.swift** - боковое меню

### Day 2: Navigation & Layout
1. **PerplexityRootView.swift** - главный контейнер
2. **PerplexityNavigationController.swift** - управление навигацией
3. **PerplexityTablessLayout.swift** - layout без табов
4. **PerplexityTransitions.swift** - анимации переходов

### Day 3: Screen Redesign
1. **PerplexityHomeView.swift** - главный экран с поиском
2. **PerplexityCoursesView.swift** - список курсов в новом стиле
3. **PerplexityProfileView.swift** - минималистичный профиль
4. **PerplexitySettingsView.swift** - настройки в стиле Perplexity

### Day 4: AI Integration
1. **PerplexityAIService.swift** - сервис для AI функций
2. **PerplexitySearchEngine.swift** - умный поиск
3. **PerplexityAssistantView.swift** - AI ассистент
4. **PerplexityResponseCard.swift** - карточки ответов

### Day 5: Polish & TestFlight
1. Анимации и переходы
2. Темная тема везде
3. Исправление багов
4. TestFlight Build 3.0.0

## 🔧 Технические детали

### SwiftUI модификаторы
```swift
// Perplexity-style модификаторы
.perplexityCard()
.perplexityButton(style: .primary)
.perplexityTransition()
.perplexityGlow()
```

### Анимации
- Spring анимации для плавности
- Fade in/out для контента
- Slide для навигации
- Scale для hover эффектов

### Интеграция с существующим кодом
- Сохраняем всю бизнес-логику
- Меняем только UI слой
- Используем существующие сервисы
- Адаптируем ViewModels

## 📊 Метрики успеха

1. **Визуальное сходство с Perplexity** - 90%+
2. **Производительность** - 60 FPS анимации
3. **Размер приложения** - увеличение < 5MB
4. **Покрытие тестами** - 80%+ для новых компонентов

## 🚀 Deliverables

1. **Полностью переработанный UI**
2. **Новая дизайн-система**
3. **AI-поиск интеграция**
4. **Документация по компонентам**
5. **TestFlight Build 3.0.0**

## 📝 Риски

1. **Сложность миграции** - много экранов для обновления
2. **Совместимость** - поддержка iOS 17+
3. **Производительность** - сложные анимации
4. **Время** - амбициозный план на 5 дней

## 🎯 Definition of Done

- [ ] Все экраны переработаны в стиле Perplexity
- [ ] Темная тема работает везде
- [ ] Анимации плавные (60 FPS)
- [ ] AI поиск интегрирован
- [ ] Тесты написаны и проходят
- [ ] TestFlight build загружен

---

**Примечание**: Это амбициозный редизайн, который полностью изменит внешний вид приложения, сохранив при этом всю функциональность. 