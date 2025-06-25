# LMS Documentation - ЦУМ: Корпоративный университет

**Версия:** 10.2.0  
**Статус проекта:** В активной разработке  
**Методология:** TDD v1.6.0

## 📊 Текущий прогресс

- ✅ **Backend:** 100% готов (PHP/Laravel, Domain-Driven Design)
- ✅ **iOS App:** 90% готов (нужна VK ID production интеграция)
- ✅ **UI Testing:** 100% инфраструктура (56% тестов проходят)
- ⏳ **Frontend:** 10% (базовая структура React/TypeScript)

## 🚀 Последние достижения

### Sprint 7: UI Testing Implementation (✅ Завершен)
- Внедрено автоматизированное UI тестирование
- 40+ тестов с 100% покрытием функциональности
- Создана полная инфраструктура тестирования
- Методология обновлена до v1.6.0

### Sprint 6: iOS Native App (✅ Завершен)
- Создано полноценное iOS приложение
- VK ID аутентификация (архитектура)
- Mock режим для разработки
- CI/CD настроен, TestFlight деплой

## 📁 Структура документации

### 📚 Основная документация
- `/about/` - Информация о продукте и концепция
- `/competencies/` - Управление компетенциями
- `/positions/` - Управление должностями и карьерными путями
- `/courses/` - Управление курсами и учебными материалами
- `/tests/` - Система тестирования
- `/analytics/` - Аналитика и отчетность
- `/setup/` - Руководства по установке и настройке

### 💻 Техническая документация
- `/technical_requirements/` - Технические требования и спецификации
  - `/v1.0/` - MVP версия с подробными контрактами API
  - `TDD_MANDATORY_GUIDE.md` - Обязательное руководство по TDD
  - `UI_TESTING_METHODOLOGY.md` - Методология UI тестирования

### 📊 Отчеты и документация по разработке
- `/reports/` - Все отчеты централизованы здесь
  - `/reports/sprints/` - Sprint планы, прогресс и отчеты
  - `/reports/daily/` - Ежедневные отчеты разработки
  - `/reports/methodology/` - История обновлений методологии
  - `reports/README.md` - Навигация по всем отчетам

### 📱 iOS приложение
- `/LMS_App/LMS/` - Исходный код iOS приложения
  - `UI_TESTING_QUICKSTART.md` - Быстрый старт с UI тестами
  - `test-quick-ui.sh` - Быстрый запуск тестов (3-5 сек)

## 🛠️ Быстрый старт для разработчиков

### Backend (PHP/Laravel)
```bash
# Запуск тестов
./test-quick.sh tests/Unit/User/Domain/UserTest.php

# Запуск всех тестов
composer test
```

### iOS App
```bash
cd LMS_App/LMS

# Быстрый UI тест
./test-quick-ui.sh SimpleSmokeTest/testAppLaunches

# Все UI тесты
./test-ui.sh
```

### Frontend (React)
```bash
cd frontend

# Установка зависимостей
npm install

# Запуск в dev режиме
npm run dev

# Тесты
npm test
```

## 🔧 Технологический стек

### Backend
- PHP 8.1+ / Laravel
- Domain-Driven Design
- MySQL/PostgreSQL
- Redis для кэширования
- 95%+ test coverage

### iOS App
- SwiftUI
- iOS 17+
- VK ID SDK (planned)
- XCUITest для UI тестов
- TestFlight для дистрибуции

### Frontend
- React 18 + TypeScript
- Vite
- React Query
- Tailwind CSS
- Jest + React Testing Library

## 📋 Методология разработки

Проект следует строгой TDD методологии v1.6.0:

1. **Написать тест** → Запустить → Увидеть красный
2. **Написать код** → Запустить тест → Увидеть зеленый
3. **Рефакторинг** → Запустить тест → Остается зеленый
4. **UI тесты** обязательны для всех user-facing функций

### Ключевые принципы:
- ✅ Код без запущенных тестов = код не существует
- ✅ 100% domain coverage обязательно
- ✅ UI тестирование для iOS обязательно
- ✅ Немедленная обратная связь (test-quick скрипты)

## 🎯 Roadmap

### Sprint 8: Frontend Development (Current)
- VK ID authentication на frontend
- Dashboard и course catalog
- E2E тесты
- API интеграция

### Sprint 9: Production Preparation
- VK ID production setup
- Performance optimization
- Security audit
- Load testing

### Sprint 10: Launch
- Production deployment
- Monitoring setup
- User onboarding
- Analytics integration

## 📞 Контакты и поддержка

- **Документация:** Этот репозиторий
- **Техническая поддержка:** См. `/setup/index.md`
- **API документация:** `/docs/api/openapi.yaml`

## 🏆 Статистика проекта

- **Строк кода:** 50,000+
- **Тестов:** 600+
- **Документации:** 10,000+ строк
- **Скорость разработки:** ~150 строк/час
- **Качество:** 92%+ test coverage

---

**Примечание:** Эта документация постоянно обновляется. Для последней версии всегда проверяйте master ветку. 