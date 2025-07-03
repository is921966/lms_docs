# Notification Service

Модуль управления уведомлениями в LMS системе.

## Обзор

Notification Service предоставляет функциональность для создания, отправки и управления уведомлениями пользователей через различные каналы доставки (email, push, SMS, in-app).

## Архитектура

Модуль следует принципам Domain-Driven Design и состоит из следующих слоев:

### Domain Layer
- **Entities**: `Notification` - основная сущность уведомления
- **Value Objects**: 
  - `NotificationId` - уникальный идентификатор
  - `NotificationType` - тип уведомления (course_assigned, course_completed, etc.)
  - `NotificationChannel` - канал доставки (email, push, sms, in_app)
  - `NotificationPriority` - приоритет (low, medium, high)
  - `NotificationStatus` - статус (pending, sent, delivered, read, failed)
  - `RecipientId` - идентификатор получателя
- **Events**: `NotificationCreated`, `NotificationSent`, `NotificationFailed`
- **Repository Interface**: `NotificationRepositoryInterface`

### Application Layer
- **Use Cases**:
  - `SendNotificationUseCase` - отправка одного уведомления
  - `SendBulkNotificationsUseCase` - массовая отправка
  - `MarkAsReadUseCase` - отметка как прочитанное
- **DTOs**: `NotificationDTO`, `BulkNotificationDTO`
- **Services**: `NotificationDispatcher`, `TemplateRenderer`

### Infrastructure Layer
- **Persistence**: `InMemoryNotificationRepository` (для MVP)
- **Email**: `EmailNotificationSender`, `SmtpEmailProvider`
- **Dispatcher**: `CompositeNotificationDispatcher` - управление различными каналами

### HTTP Layer
- **Controllers**: `NotificationController`
- **Requests**: `SendNotificationHttpRequest`
- **Responses**: `NotificationResponse`

## API Endpoints

### Отправка уведомлений
```
POST /api/v1/notifications
Content-Type: application/json

{
  "recipientId": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "type": "course_assigned",
  "channel": "email",
  "subject": "Новый курс назначен",
  "content": "Вам назначен курс 'PHP Advanced'",
  "priority": "medium",
  "metadata": {
    "courseId": "123",
    "courseName": "PHP Advanced"
  }
}
```

### Массовая отправка
```
POST /api/v1/notifications/bulk
Content-Type: application/json

{
  "recipientIds": [
    "f47ac10b-58cc-4372-a567-0e02b2c3d479",
    "a47ac10b-58cc-4372-a567-0e02b2c3d479"
  ],
  "type": "system_announcement",
  "channel": "email",
  "subject": "Системное обновление",
  "content": "Система будет недоступна с 02:00 до 04:00",
  "priority": "high"
}
```

### Получение уведомлений пользователя
```
GET /api/v1/users/{userId}/notifications?limit=50&offset=0
```

### Отметка как прочитанное
```
PUT /api/v1/notifications/{notificationId}/read
```

### Отметить все как прочитанные
```
PUT /api/v1/users/{userId}/notifications/read
```

### Количество непрочитанных
```
GET /api/v1/users/{userId}/notifications/unread/count
```

## Статусы уведомлений

1. **pending** - создано, ожидает отправки
2. **sent** - отправлено провайдеру доставки
3. **delivered** - доставлено получателю
4. **read** - прочитано получателем
5. **failed** - ошибка при отправке

## Типы уведомлений

- `course_assigned` - назначен новый курс
- `course_completed` - курс завершен
- `deadline_reminder` - напоминание о дедлайне
- `system_announcement` - системное объявление

## Каналы доставки

- `email` - электронная почта (реализовано)
- `push` - push-уведомления (планируется)
- `sms` - SMS сообщения (планируется)
- `in_app` - внутренние уведомления (планируется)

## Приоритеты

- `high` - высокий приоритет, отправляется первым
- `medium` - обычный приоритет
- `low` - низкий приоритет

## Тестирование

Модуль имеет полное покрытие тестами:
- **Unit тесты**: 118 тестов
- **Integration тесты**: 5 тестов

Запуск тестов:
```bash
# Все тесты модуля
./test-quick.sh tests/Unit/Notification/
./test-quick.sh tests/Integration/Notification/

# Конкретный тест
./test-quick.sh tests/Unit/Notification/Domain/NotificationTest.php
```

## Расширение функциональности

### Добавление нового канала доставки

1. Создайте новый sender класс, реализующий отправку:
```php
class PushNotificationSender
{
    public function send(Notification $notification): void
    {
        // Логика отправки push уведомления
    }
    
    public function supports(Notification $notification): bool
    {
        return $notification->getChannel()->equals(NotificationChannel::push());
    }
}
```

2. Зарегистрируйте sender в CompositeNotificationDispatcher:
```php
$dispatcher->addSender($pushSender);
```

### Добавление нового типа уведомления

1. Добавьте новый тип в NotificationType:
```php
public static function newType(): self
{
    return new self('new_type');
}
```

2. Обновите валидацию в SendNotificationHttpRequest
3. Создайте шаблон для нового типа

## Планы развития

1. **Реальная отправка email** через SMTP
2. **Push уведомления** через Firebase/APNS
3. **SMS интеграция** через Twilio/другие провайдеры
4. **Шаблонизатор** для email (Twig)
5. **Очередь отправки** для асинхронной обработки
6. **Повторные попытки** при ошибках
7. **Аналитика** по доставке и прочтению
8. **Персонализация** на основе предпочтений пользователя 