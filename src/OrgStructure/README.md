# Модуль "Организационная структура"

## Описание

Модуль управления организационной структурой компании, включающий:
- Управление сотрудниками
- Управление подразделениями
- Управление должностями
- Импорт данных из CSV
- Интеграцию с LDAP/Active Directory

## Архитектура

Модуль построен по принципам Domain-Driven Design (DDD) и Clean Architecture.

### Структура каталогов

```
OrgStructure/
├── Domain/              # Бизнес-логика
│   ├── Models/         # Сущности и агрегаты
│   ├── ValueObjects/   # Объекты-значения
│   ├── Exceptions/     # Доменные исключения
│   └── Repositories/   # Интерфейсы репозиториев
├── Application/        # Сервисы приложения
│   ├── Services/       # Оркестраторы и сервисы
│   ├── DTO/           # Data Transfer Objects
│   └── Exceptions/    # Исключения уровня приложения
├── Infrastructure/     # Инфраструктура
│   ├── Repositories/  # Реализации репозиториев (PostgreSQL)
│   └── Services/      # Внешние сервисы (LDAP)
└── Http/              # HTTP слой
    └── Controllers/   # REST API контроллеры
```

## API Endpoints

### Сотрудники (Employees)

| Метод | Endpoint | Описание |
|-------|----------|----------|
| GET | `/api/v1/org/employees` | Список сотрудников |
| GET | `/api/v1/org/employees/{id}` | Информация о сотруднике |
| POST | `/api/v1/org/employees` | Создать сотрудника |
| PUT | `/api/v1/org/employees/{id}` | Обновить сотрудника |
| DELETE | `/api/v1/org/employees/{id}` | Удалить сотрудника |
| GET | `/api/v1/org/employees/search` | Поиск сотрудников |

### Подразделения (Departments)

| Метод | Endpoint | Описание |
|-------|----------|----------|
| GET | `/api/v1/org/departments` | Список подразделений |
| GET | `/api/v1/org/departments/{id}` | Информация о подразделении |
| POST | `/api/v1/org/departments` | Создать подразделение |
| PUT | `/api/v1/org/departments/{id}` | Обновить подразделение |
| DELETE | `/api/v1/org/departments/{id}` | Удалить подразделение |
| GET | `/api/v1/org/departments/{id}/hierarchy` | Иерархия подразделения |

### Должности (Positions)

| Метод | Endpoint | Описание |
|-------|----------|----------|
| GET | `/api/v1/org/positions` | Список должностей |
| GET | `/api/v1/org/positions/{id}` | Информация о должности |
| POST | `/api/v1/org/positions` | Создать должность |
| PUT | `/api/v1/org/positions/{id}` | Обновить должность |
| DELETE | `/api/v1/org/positions/{id}` | Удалить должность |

### Импорт данных

| Метод | Endpoint | Описание |
|-------|----------|----------|
| POST | `/api/v1/org/import` | Импорт из CSV файла |
| GET | `/api/v1/org/import/template` | Скачать шаблон CSV |
| POST | `/api/v1/org/import/validate` | Валидация CSV файла |

## Примеры использования

### Создание сотрудника

```bash
curl -X POST http://localhost/api/v1/org/employees \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "tabNumber": "EMP001",
    "fullName": "Иванов Иван Иванович",
    "email": "ivanov@company.ru",
    "phone": "+7-123-456-7890",
    "departmentId": "550e8400-e29b-41d4-a716-446655440000",
    "positionId": "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
    "hireDate": "2024-01-15"
  }'
```

### Импорт из CSV

```bash
curl -X POST http://localhost/api/v1/org/import \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "file=@employees.csv"
```

### Получение шаблона CSV

```bash
curl -O http://localhost/api/v1/org/import/template \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Формат CSV для импорта

CSV файл должен содержать следующие столбцы:

```csv
ФИО,Таб.номер,Email,Телефон,Подразделение,Должность,Руководитель
"Иванов Иван Иванович",EMP001,ivanov@company.ru,+7-123-456-7890,"Отдел разработки","Старший разработчик",
"Петров Петр Петрович",EMP002,petrov@company.ru,+7-123-456-7891,"Отдел разработки","Разработчик",EMP001
```

### Правила импорта

1. **Кодировка**: UTF-8 (с BOM или без)
2. **Разделители**: запятая (,) или точка с запятой (;)
3. **Обязательные поля**: ФИО, Таб.номер
4. **Руководитель**: указывается табельный номер руководителя
5. **Подразделения и должности**: создаются автоматически, если не существуют

### Обработка ошибок

- По умолчанию: импорт прерывается при первой ошибке
- С параметром `skipOnError=true`: ошибочные строки пропускаются

## Тестирование

### Unit тесты

```bash
# Все тесты модуля
./test-quick.sh tests/Unit/OrgStructure/

# Конкретный тест
./test-quick.sh tests/Unit/OrgStructure/Domain/Models/EmployeeTest.php
```

### Интеграционные тесты

```bash
./test-quick.sh tests/Integration/OrgStructure/ImportFlowTest.php
```

## База данных

### Миграции

```bash
# Применить миграции
php artisan migrate --path=database/migrations/024_create_departments_table.sql
php artisan migrate --path=database/migrations/025_create_positions_table.sql
php artisan migrate --path=database/migrations/026_create_employees_table.sql
```

### Структура таблиц

#### departments
- id (UUID)
- code (VARCHAR 50)
- name (VARCHAR 255)
- description (TEXT)
- parent_id (UUID, nullable)
- is_active (BOOLEAN)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)

#### positions
- id (UUID)
- code (VARCHAR 50)
- title (VARCHAR 255)
- category (VARCHAR 50)
- department_id (UUID, nullable)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)

#### employees
- id (UUID)
- tab_number (VARCHAR 50, unique)
- full_name (VARCHAR 255)
- email (VARCHAR 255)
- phone (VARCHAR 50)
- department_id (UUID)
- position_id (UUID)
- manager_id (UUID, nullable)
- is_active (BOOLEAN)
- hire_date (DATE)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)

## Конфигурация

### LDAP/Active Directory

```env
LDAP_HOST=ldap.company.com
LDAP_PORT=389
LDAP_BASE_DN=dc=company,dc=com
LDAP_USERNAME=cn=admin,dc=company,dc=com
LDAP_PASSWORD=secret
LDAP_USE_SSL=false
```

### Права доступа

Для работы с модулем требуются следующие права:
- `org.view` - просмотр структуры
- `org.manage` - управление структурой
- `org.import` - импорт данных

## Производительность

- Импорт поддерживает файлы до 10,000 строк
- Batch обработка по 100 записей
- Индексы на часто используемых полях
- Кеширование иерархии подразделений

## Известные ограничения

1. Циклические ссылки в иерархии подразделений запрещены
2. Сотрудник не может быть своим руководителем
3. Удаление подразделения с сотрудниками запрещено
4. Табельный номер должен быть уникальным

## Roadmap

- [ ] Массовые операции над сотрудниками
- [ ] История изменений (audit log)
- [ ] Экспорт в различные форматы
- [ ] Визуализация оргструктуры
- [ ] Интеграция с системой компетенций 