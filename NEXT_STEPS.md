# Следующие шаги для завершения Sprint 2

## День 16-17: Тестирование и финализация

### 1. Unit тесты (День 16)

#### Domain слой:
```bash
tests/Unit/User/Domain/
├── UserTest.php
├── RoleTest.php
├── PermissionTest.php
└── ValueObjects/
    ├── EmailTest.php
    ├── PasswordTest.php
    └── UserIdTest.php
```

**Что тестировать:**
- Создание и валидация сущностей
- Бизнес-правила (например, системные роли)
- Value objects валидация
- Domain events

#### Application слой:
```bash
tests/Unit/User/Application/Service/
├── UserServiceTest.php
└── AuthServiceTest.php
```

**Что тестировать:**
- Сервисная логика
- Валидация входных данных
- Обработка исключений
- Взаимодействие с репозиториями (моки)

### 2. Integration тесты (День 16)

```bash
tests/Integration/User/
├── UserRepositoryTest.php
├── RoleRepositoryTest.php
└── LdapServiceTest.php
```

**Что тестировать:**
- Работа с реальной БД (тестовая)
- LDAP подключение (мок сервер)
- Транзакции и rollback
- Сложные запросы

### 3. Feature тесты (День 17)

```bash
tests/Feature/User/
├── AuthenticationTest.php
├── UserManagementTest.php
├── ProfileTest.php
└── LdapIntegrationTest.php
```

**Что тестировать:**
- HTTP endpoints
- Полный flow аутентификации
- CRUD операции через API
- Права доступа
- Валидация запросов

### 4. Doctrine Mappings (День 17)

```bash
src/User/Infrastructure/Persistence/Doctrine/
├── Mapping/
│   ├── User.orm.xml
│   ├── Role.orm.xml
│   └── Permission.orm.xml
└── Types/
    ├── UserIdType.php
    └── EmailType.php
```

### 5. Database Seeders (День 17)

```bash
database/seeders/
├── UserSeeder.php
├── RoleSeeder.php
└── PermissionSeeder.php
```

**Данные для seed:**
- 5 системных ролей
- 30+ permissions
- Тестовые пользователи
- Админ аккаунт

### 6. Финальная проверка

#### Checklist:
- [ ] Все тесты проходят
- [ ] API документация актуальна
- [ ] Нет критических TODO в коде
- [ ] Docker контейнеры стабильны
- [ ] Миграции применяются чисто
- [ ] Seeders работают корректно

#### Команды для проверки:
```bash
# Запуск всех тестов
make test

# Проверка покрытия
make test-coverage

# Статический анализ
make phpstan

# Code style
make cs-fix

# Полная проверка
make check-all
```

### 7. Документация для передачи

#### Создать/обновить:
1. `API_GUIDE.md` - руководство по использованию API
2. `DEPLOYMENT.md` - инструкция по развертыванию
3. `TESTING.md` - руководство по тестированию
4. Postman коллекция с примерами

## Приоритеты

### Критично (must have):
1. Unit тесты для основной логики
2. Feature тесты для API
3. Seeders для демо данных
4. Исправление найденных багов

### Важно (should have):
1. Integration тесты
2. Doctrine mappings
3. API документация
4. Postman коллекция

### Желательно (nice to have):
1. 80%+ test coverage
2. Performance тесты
3. Security audit
4. Load testing

## Временная оценка

### День 16 (8 часов):
- Unit тесты: 4 часа
- Integration тесты: 3 часа
- Исправление багов: 1 час

### День 17 (8 часов):
- Feature тесты: 4 часа
- Doctrine mappings: 2 часа
- Seeders: 1 час
- Финальная проверка: 1 час

## Результат

После выполнения всех задач:
1. **User Management Service** будет полностью готов
2. **Test coverage** минимум 70%
3. **API** протестирован и документирован
4. **Demo данные** для презентации
5. **Production-ready** код

## Команда для старта

```bash
# Начать с тестов
make test-init
cd tests/Unit/User/Domain
# Начать писать UserTest.php
``` 