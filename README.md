# LMS - Learning Management System

[![iOS CI](https://github.com/[USERNAME]/lms_docs/actions/workflows/ios-ci.yml/badge.svg)](https://github.com/[USERNAME]/lms_docs/actions/workflows/ios-ci.yml)
[![codecov](https://codecov.io/gh/[USERNAME]/lms_docs/branch/main/graph/badge.svg)](https://codecov.io/gh/[USERNAME]/lms_docs)
[![Swift Version](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-iOS%2018.5+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

**ЦУМ: Корпоративный университет**

[![Build Status](https://img.shields.io/badge/build-pending-yellow)](https://github.com/yourusername/lms)
[![Test Coverage](https://img.shields.io/badge/coverage-55%25-orange)](https://github.com/yourusername/lms)
[![MVP Progress](https://img.shields.io/badge/MVP-80%25-green)](https://github.com/yourusername/lms)

## 📋 О проекте

Корпоративная система управления обучением (LMS) для ЦУМ, включающая:
- 🖥️ **Backend**: PHP 8.1+ микросервисы с Domain-Driven Design
- 📱 **iOS приложение**: Native SwiftUI для iOS 17+
- 🧪 **Тестирование**: TDD с 80%+ покрытием кода
- 🚀 **CI/CD**: GitHub Actions (в разработке)

## 🏗️ Архитектура

### Backend микросервисы
- **User Service** - Управление пользователями
- **Auth Service** - Аутентификация и авторизация
- **Competency Service** - Управление компетенциями
- **Learning Service** - Курсы и материалы
- **Program Service** - Учебные программы
- **Position Service** - Должности и роли
- **Notification Service** - Уведомления
- **API Gateway** - Единая точка входа

### iOS модули (18)
- User Management
- Authentication
- Learning & Courses
- Competencies
- Tests & Assessments
- Analytics & Reports
- Onboarding
- Notifications
- И другие...

## 🚀 Quick Start

### Требования
- PHP 8.1+
- MySQL 8.0+
- Xcode 15+
- iOS 17+ SDK

### Backend установка
```bash
# Клонировать репозиторий
git clone https://github.com/yourusername/lms.git
cd lms

# Установить зависимости
composer install

# Настроить окружение
cp .env.example .env
php artisan key:generate

# Запустить миграции
php artisan migrate

# Запустить тесты
./vendor/bin/phpunit
```

### iOS установка
```bash
# Перейти в директорию iOS
cd LMS_App/LMS

# Открыть в Xcode
open LMS.xcodeproj

# Запустить тесты
./scripts/test-quick-ui.sh

# Собрать приложение
xcodebuild -scheme LMS -configuration Release
```

## 📊 Текущий статус

**Sprint**: 29 (завершен)  
**MVP Progress**: ~80%  
**Ожидаемый релиз**: 31 июля 2025

### Что готово ✅
- Backend архитектура и основные сервисы
- iOS приложение с 18 модулями
- 100+ unit тестов
- Полная документация
- Mock режим для демонстрации

### В работе 🚧
- Исправление тестов (45% осталось)
- CI/CD pipeline
- Production конфигурация
- Monitoring и alerting

### Roadmap 🗺️
- **Sprint 30**: Тесты + CI/CD
- **Sprint 31**: Production setup
- **Sprint 32**: Performance & Monitoring
- **Sprint 33**: Final QA & Launch

## 🧪 Тестирование

### Запуск тестов
```bash
# Backend тесты
./test-quick.sh

# iOS тесты
cd LMS_App/LMS
./scripts/test-quick-ui.sh

# Все тесты с покрытием
make test-coverage
```

### Текущее покрытие
- Backend: 85%
- iOS: 55% (в процессе исправления)
- Цель: >80% для всего проекта

## 📚 Документация

- [Техническая архитектура](technical_requirements/v1.0/technical_architecture.md)
- [API документация](docs/api/)
- [Руководство разработчика](technical_requirements/v1.0/llm_development_guide.md)
- [TDD Guide](technical_requirements/TDD_MANDATORY_GUIDE.md)
- [MVP Roadmap](docs/project/MVP_ROADMAP.md)

## 🤝 Вклад в проект

1. Fork репозитория
2. Создайте feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit изменения (`git commit -m 'Add some AmazingFeature'`)
4. Push в branch (`git push origin feature/AmazingFeature`)
5. Откройте Pull Request

### Правила
- Все новые функции должны иметь тесты
- Следуйте TDD подходу
- Документируйте изменения
- Проверяйте локальную компиляцию перед push

## 📞 Контакты

- **Project Lead**: AI Agent
- **Email**: [TBD]
- **Slack**: [TBD]

## 📄 Лицензция

[TBD]

---

*Последнее обновление: 3 июля 2025* 