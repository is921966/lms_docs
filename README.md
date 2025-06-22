# LMS "ЦУМ: Корпоративный университет"

Система корпоративного обучения для управления компетенциями, онбординга сотрудников и развития персонала.

## Технологический стек

- **Backend**: PHP 8.1+, Symfony 6.3
- **Database**: PostgreSQL 15
- **Cache**: Redis
- **Queue**: RabbitMQ
- **Authentication**: Microsoft Active Directory (LDAP/SAML)

## Структура проекта

```
lms/
├── config/           # Конфигурационные файлы
├── src/             # Исходный код
│   ├── Common/      # Общие компоненты
│   ├── User/        # User Management Service
│   ├── Competency/  # Competency Service
│   ├── Learning/    # Learning Service
│   ├── Program/     # Program Service
│   └── Notification/# Notification Service
├── database/        # Миграции БД
├── docker/          # Docker конфигурация
└── tests/          # Тесты
```

## 📁 Documentation Structure

The documentation is organized into the following sections:

## 🔄 Methodology Synchronization

This project uses a centralized TDD methodology that can be synchronized across projects:

```bash
# Update methodology in central repository
./sync-methodology.sh to-central

# Get latest methodology from central repository
./sync-methodology.sh from-central

# Or use Make commands
make update-methodology      # Push to central
make sync-methodology-pull   # Pull from central
```

**AI Command:** Just say "обнови методологию" and the AI will handle everything automatically!

See [METHODOLOGY_SYNC.md](METHODOLOGY_SYNC.md) for detailed information.

## 🚀 Quick Start

### Требования

- Docker и Docker Compose
- Git

### Установка

```bash
# Клонирование репозитория
git clone [repository-url]
cd lms

# Копирование environment файла
cp .env.example .env

# Запуск Docker окружения
docker-compose up -d

# Установка зависимостей
docker-compose exec app composer install

# Выполнение миграций
docker-compose exec app php bin/console doctrine:migrations:migrate
```

### Проверка работы

```bash
# Проверка статуса сервисов
docker-compose ps

# Просмотр логов
docker-compose logs -f app
```

## Разработка

### 🚨 ОБЯЗАТЕЛЬНО К ПРОЧТЕНИЮ
- [**ОБЯЗАТЕЛЬНОЕ РУКОВОДСТВО ПО TDD**](technical_requirements/TDD_MANDATORY_GUIDE.md) - критически важно!
- [Техническая документация](technical_requirements/v1.0/README.md) для деталей реализации
- [Руководство по тестированию](TESTING_GUIDE.md) для запуска тестов

### Основное правило разработки
**Код без запущенных тестов = код не существует**

Процесс разработки:
1. Написать тест → запустить → увидеть ошибку
2. Написать код → запустить тест → увидеть успех
3. Рефакторинг → запустить тест → убедиться в успехе
4. Только после этого - коммит

### Создание новой сущности

```bash
docker-compose exec app php bin/console make:entity
```

### Создание миграции

```bash
docker-compose exec app php bin/console make:migration
```

### Запуск тестов (ОБЯЗАТЕЛЬНО!)

```bash
# Быстрый запуск одного теста
make test-specific TEST=tests/Unit/YourTest.php

# Все unit тесты
make test-unit

# Все тесты
make test
```

## API Документация

API документация доступна по адресу: `http://localhost:8080/api/doc`

## Архитектура

Проект построен на микросервисной архитектуре с следующими сервисами:

1. **User Management Service** - управление пользователями и аутентификация
2. **Competency Service** - управление компетенциями
3. **Learning Service** - курсы, тесты, сертификаты
4. **Program Service** - программы развития и онбординг
5. **Notification Service** - уведомления
6. **Analytics Service** - аналитика и отчеты

## Лицензия

Proprietary - Все права защищены 