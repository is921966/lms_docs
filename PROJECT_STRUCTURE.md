# Структура проекта LMS "ЦУМ: Корпоративный университет"

## 🏗️ Основная структура

```
lms_docs/
├── 📱 LMS_App/LMS/              # iOS приложение (SwiftUI)
├── 🔧 src/                      # Backend (PHP, Domain-Driven Design)
├── 🧪 tests/                    # Тесты для backend
├── 📋 technical_requirements/   # Техническая документация
├── 📊 reports/                  # Отчеты о разработке
├── 🗄️ database/                 # Миграции и сиды БД
├── ⚙️ config/                   # Конфигурация приложения
├── 📚 docs/                     # Документация проекта
└── 🛠️ scripts/                  # Вспомогательные скрипты
```

## 📱 iOS приложение (LMS_App/LMS/)

```
LMS/
├── LMS/                         # Основной код приложения
│   ├── Features/               # Функциональные модули
│   │   ├── Auth/              # Аутентификация
│   │   ├── Courses/           # Управление курсами
│   │   ├── Learning/          # Процесс обучения
│   │   ├── Tests/             # Тестирование
│   │   ├── Analytics/         # Аналитика
│   │   ├── Competency/        # Компетенции
│   │   ├── Position/          # Должности
│   │   ├── Notifications/     # Уведомления
│   │   ├── Admin/             # Админ-панель
│   │   ├── Profile/           # Профиль пользователя
│   │   ├── Onboarding/        # Онбординг
│   │   └── Feedback/          # Обратная связь
│   ├── Services/              # Сервисный слой
│   │   ├── Auth/             # Сервис аутентификации
│   │   ├── Network/          # Сетевой слой
│   │   ├── MockServices/     # Моки для разработки
│   │   └── Feedback/         # Сервис обратной связи
│   └── Common/               # Общие компоненты
│       ├── Domain/           # Domain модели
│       ├── Data/             # Data слой (DTO, репозитории)
│       └── Models/           # Общие модели
├── LMSTests/                 # Unit тесты
├── LMSUITests/               # UI тесты
└── scripts/                  # Скрипты для iOS
```

## 🔧 Backend (src/)

### Реализованные модули (с тестами):

```
src/
├── ✅ User/                    # Управление пользователями (124 теста)
│   ├── Domain/                # Бизнес-логика
│   ├── Application/           # Use cases
│   ├── Infrastructure/        # Репозитории, сервисы
│   └── Http/                  # REST API
│
├── ✅ Auth/                    # Аутентификация (63 теста)
│   ├── Domain/                # JWT токены, сессии
│   ├── Application/           # Login/Logout команды
│   └── Infrastructure/        # JWT провайдер
│
├── ✅ Competency/              # Компетенции (92 теста)
│   ├── Domain/                # Модели компетенций
│   ├── Application/           # CRUD операции
│   └── Infrastructure/        # Хранение данных
│
├── ✅ Position/                # Должности (48 тестов)
│   ├── Domain/                # Модели должностей
│   ├── Application/           # Управление должностями
│   └── Infrastructure/        # Репозитории
│
├── ✅ Learning/                # Обучение (370 тестов)
│   ├── Domain/                # Курсы, модули, уроки
│   ├── Application/           # Прогресс обучения
│   └── Infrastructure/        # Хранение контента
│
├── ✅ Program/                 # Программы обучения (133 теста)
│   ├── Domain/                # Программы, треки
│   ├── Application/           # Enrollment, прогресс
│   └── Infrastructure/        # Управление программами
│
├── 🚧 Notification/            # Уведомления (51 тест - в разработке)
│   ├── Domain/                # Модели уведомлений
│   ├── Application/           # Отправка уведомлений
│   └── Infrastructure/        # Email, Push, In-app
│
└── Common/                     # Общие компоненты
    ├── Domain/                # Базовые классы
    ├── Exceptions/            # Исключения
    ├── Middleware/            # Middleware
    └── Traits/                # Переиспользуемые трейты
```

## 🧪 Тесты (tests/)

```
tests/
├── Unit/                      # Unit тесты (881 тест)
│   ├── User/                 # 124 теста
│   ├── Auth/                 # 63 теста
│   ├── Competency/           # 92 теста
│   ├── Position/             # 48 тестов
│   ├── Learning/             # 370 тестов
│   ├── Program/              # 133 теста
│   └── Notification/         # 51 тест
│
├── Integration/              # Интеграционные тесты
│   ├── User/
│   ├── Position/
│   └── Program/
│
└── Feature/                  # Feature тесты
    ├── Auth/
    ├── Competency/
    └── User/
```

## 📊 Статистика проекта

### Backend:
- **Модулей реализовано**: 6 из 7 (85.7%)
- **Всего тестов**: 881
- **Покрытие тестами**: >95%
- **Архитектура**: Domain-Driven Design
- **Паттерны**: Repository, Use Cases, Value Objects

### iOS:
- **Модулей**: 12+ функциональных модулей
- **UI тестов**: 50+
- **Unit тестов**: 20+
- **Версия**: iOS 17+
- **Архитектура**: MVVM + SwiftUI

### Инфраструктура:
- **CI/CD**: GitHub Actions + Xcode Cloud
- **TestFlight**: Build 52 (последний)
- **База данных**: PostgreSQL/MySQL
- **API**: REST + OpenAPI спецификации

## 🚀 Текущий статус

- **Sprint 25**: Notification Service (День 1/5)
- **Завершено спринтов**: 24
- **Дней разработки**: 119
- **Следующий модуль**: Frontend (после Notification)

## 📁 Важные файлы конфигурации

```
├── composer.json              # PHP зависимости
├── phpunit.xml               # Конфигурация тестов
├── .env                      # Переменные окружения
├── Makefile                  # Команды для разработки
├── docker-compose.yml        # Docker конфигурация
├── .cursorrules             # Правила для AI-разработки
└── test-quick.sh            # Быстрый запуск тестов
```

## 🔄 Методология разработки

- **TDD (Test-Driven Development)**: Тесты пишутся первыми
- **Vertical Slice**: Каждый спринт = работающий функционал
- **AI-Driven Development**: Использование LLM для ускорения
- **Continuous Testing**: Каждый тест запускается сразу после написания 