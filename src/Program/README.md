# Program Management Module

## Описание

Модуль управления программами обучения (Program Management) отвечает за создание, управление и отслеживание учебных программ в LMS.

## Основные компоненты

### Domain Layer

#### Value Objects
- **ProgramId** - уникальный идентификатор программы (UUID)
- **ProgramCode** - код программы в формате XXXX-NNN (например, PROG-001)
- **ProgramStatus** - статус программы (draft, active, archived)
- **TrackId** - идентификатор трека
- **TrackOrder** - порядковый номер трека в программе
- **CompletionCriteria** - критерии завершения программы

#### Entities
- **Program** - основная сущность программы обучения
- **Track** - трек (последовательность курсов) в программе
- **ProgramEnrollment** - запись о зачислении пользователя на программу
- **TrackProgress** - прогресс прохождения трека

#### Events
- **ProgramCreated** - событие создания программы
- **ProgramPublished** - событие публикации программы
- **TrackAdded** - событие добавления трека
- **UserEnrolledInProgram** - событие зачисления пользователя

### Application Layer

#### Use Cases
- **CreateProgramUseCase** - создание новой программы
- **UpdateProgramUseCase** - обновление информации о программе
- **PublishProgramUseCase** - публикация программы
- **EnrollUserUseCase** - зачисление пользователя на программу

#### DTOs
- **ProgramDTO** - передача данных о программе
- **TrackDTO** - передача данных о треке
- **ProgramEnrollmentDTO** - передача данных о зачислении

### Infrastructure Layer

#### Repositories
- **InMemoryProgramRepository** - хранение программ в памяти
- **InMemoryTrackRepository** - хранение треков в памяти
- **InMemoryProgramEnrollmentRepository** - хранение записей о зачислении

#### HTTP Controllers
- **ProgramController** - REST API для управления программами

## API Endpoints

### Programs
- `GET /api/v1/programs` - получить список программ
- `POST /api/v1/programs` - создать программу
- `GET /api/v1/programs/{id}` - получить программу по ID
- `PUT /api/v1/programs/{id}` - обновить программу
- `POST /api/v1/programs/{id}/publish` - опубликовать программу
- `POST /api/v1/programs/{programId}/enroll` - записать пользователя

## Бизнес-правила

1. **Создание программы**:
   - Код программы должен быть уникальным
   - Код должен соответствовать формату XXXX-NNN
   - Новая программа создается в статусе "draft"

2. **Публикация программы**:
   - Программа должна содержать хотя бы один трек
   - Только программы в статусе "draft" могут быть опубликованы
   - После публикации программа переходит в статус "active"

3. **Обновление программы**:
   - Можно обновлять только программы в статусе "draft"
   - Нельзя изменить код программы после создания

4. **Зачисление пользователей**:
   - Можно записываться только на активные программы
   - Пользователь должен существовать и быть активным
   - Нельзя записаться на программу дважды

## Тестирование

### Unit Tests (118 тестов)
```bash
./test-quick.sh tests/Unit/Program/
```

### Integration Tests (21 тест)
```bash
./test-quick.sh tests/Integration/Program/
```

### Все тесты модуля (139 тестов)
```bash
./test-quick.sh tests/Unit/Program/ tests/Integration/Program/
```

## Примеры использования

### Создание программы
```php
$useCase = new CreateProgramUseCase($repository);
$request = new CreateProgramRequest(
    'PROG-001',
    'Основы программирования',
    'Базовый курс по программированию для начинающих'
);
$programDto = $useCase->execute($request);
```

### Публикация программы
```php
$useCase = new PublishProgramUseCase($programRepo, $trackRepo);
$useCase->execute($programId);
```

### Зачисление пользователя
```php
$useCase = new EnrollUserUseCase($programRepo, $enrollmentRepo, $userRepo);
$request = new EnrollUserRequest($userId, $programId);
$enrollmentDto = $useCase->execute($request);
```

## Интеграция с другими модулями

- **Learning Module**: использует CourseId для связи курсов с треками
- **User Module**: использует UserId для записи пользователей на программы
- **Notification Module**: будет отправлять уведомления о зачислении и прогрессе

## Статус разработки

✅ **Завершено**:
- Domain Layer (100%)
- Application Layer (100%)
- Infrastructure Layer (100%)
- HTTP Controllers (100%)
- Маршруты Symfony (100%)
- OpenAPI документация (100%)

🔄 **В планах**:
- Интеграция с базой данных (Doctrine)
- Добавление Track management endpoints
- Отслеживание прогресса прохождения
- Сертификаты об окончании программы 