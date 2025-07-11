# Notifications API Documentation

## Overview

The Notifications API provides endpoints for managing user notifications, preferences, and push tokens in the LMS system.

## Base URL

```
https://api.lms.example.com
```

## Authentication

All endpoints require authentication via Bearer token:

```
Authorization: Bearer <access_token>
```

## Endpoints

### 1. Get Notifications

Retrieve paginated list of notifications for the authenticated user.

```
GET /api/notifications
```

#### Query Parameters

| Parameter | Type | Required | Description | Default |
|-----------|------|----------|-------------|---------|
| page | integer | No | Page number | 1 |
| limit | integer | No | Items per page (max 100) | 20 |
| type | string | No | Filter by notification type | - |
| unread | boolean | No | Filter unread only | false |

#### Response

```json
{
  "items": [
    {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "userId": "789e4567-e89b-12d3-a456-426614174000",
      "type": "course_assigned",
      "title": "Новый курс назначен",
      "body": "Вам назначен курс 'iOS Development'",
      "data": {
        "courseId": "course-123"
      },
      "channels": ["in_app", "push"],
      "priority": 1,
      "isRead": false,
      "readAt": null,
      "createdAt": "2025-01-16T10:00:00Z",
      "expiresAt": null,
      "metadata": {
        "imageUrl": "https://example.com/course.jpg",
        "actionUrl": "/courses/course-123"
      }
    }
  ],
  "currentPage": 1,
  "totalPages": 5,
  "totalItems": 98
}
```

### 2. Get Single Notification

Retrieve a specific notification by ID.

```
GET /api/notifications/{id}
```

#### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | uuid | Yes | Notification ID |

#### Response

```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "userId": "789e4567-e89b-12d3-a456-426614174000",
  "type": "course_assigned",
  "title": "Новый курс назначен",
  "body": "Вам назначен курс 'iOS Development'",
  "data": {
    "courseId": "course-123"
  },
  "channels": ["in_app", "push"],
  "priority": 1,
  "isRead": false,
  "readAt": null,
  "createdAt": "2025-01-16T10:00:00Z",
  "expiresAt": null,
  "metadata": {
    "imageUrl": "https://example.com/course.jpg",
    "actionUrl": "/courses/course-123"
  }
}
```

### 3. Create Notification

Create a new notification (admin only).

```
POST /api/notifications
```

#### Request Body

```json
{
  "recipientIds": ["789e4567-e89b-12d3-a456-426614174000"],
  "type": "course_assigned",
  "title": "Новый курс назначен",
  "body": "Вам назначен курс 'iOS Development'",
  "data": {
    "courseId": "course-123"
  },
  "channels": ["in_app", "push"],
  "priority": 1,
  "metadata": {
    "imageUrl": "https://example.com/course.jpg",
    "actionUrl": "/courses/course-123"
  },
  "scheduledAt": "2025-01-17T10:00:00Z"
}
```

#### Response

Returns the created notification object (same as Get Single Notification).

### 4. Mark as Read

Mark a notification as read.

```
PUT /api/notifications/{id}/read
```

#### Response

Returns the updated notification object with `isRead: true` and `readAt` timestamp.

### 5. Delete Notification

Delete a notification.

```
DELETE /api/notifications/{id}
```

#### Response

```
204 No Content
```

### 6. Get Notification Preferences

Get notification preferences for the authenticated user.

```
GET /api/notifications/preferences
```

#### Response

```json
{
  "userId": "789e4567-e89b-12d3-a456-426614174000",
  "channelPreferences": {
    "course_assigned": ["in_app", "push", "email"],
    "test_deadline": ["in_app", "push"],
    "system_message": ["in_app"]
  },
  "isEnabled": true,
  "quietHours": {
    "isEnabled": true,
    "startTime": {
      "hour": 22,
      "minute": 0
    },
    "endTime": {
      "hour": 8,
      "minute": 0
    },
    "allowUrgent": true
  },
  "frequencyLimits": {
    "feed_activity": {
      "maxPerHour": 5,
      "maxPerDay": 20
    }
  },
  "updatedAt": "2025-01-16T10:00:00Z"
}
```

### 7. Update Notification Preferences

Update notification preferences.

```
PUT /api/notifications/preferences
```

#### Request Body

Same structure as Get Notification Preferences response.

### 8. Register Push Token

Register a device push token.

```
POST /api/push-tokens
```

#### Request Body

```json
{
  "token": "740f4707bebcf74f9b7c25d48e3358945f6aa01da5ddb387462c7eaf61bb78ad",
  "deviceId": "550e8400-e29b-41d4-a716-446655440000",
  "platform": "ios",
  "environment": "production"
}
```

#### Response

```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "userId": "789e4567-e89b-12d3-a456-426614174000",
  "token": "740f4707bebcf74f9b7c25d48e3358945f6aa01da5ddb387462c7eaf61bb78ad",
  "deviceId": "550e8400-e29b-41d4-a716-446655440000",
  "platform": "ios",
  "environment": "production",
  "isActive": true,
  "createdAt": "2025-01-16T10:00:00Z",
  "lastUsedAt": "2025-01-16T10:00:00Z"
}
```

### 9. Get Unread Count

Get count of unread notifications.

```
GET /api/notifications/unread-count
```

#### Response

```json
{
  "count": 12
}
```

### 10. Get Notification Statistics

Get notification analytics for a date range.

```
GET /api/notifications/stats
```

#### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| from | datetime | Yes | Start date (ISO 8601) |
| to | datetime | Yes | End date (ISO 8601) |

#### Response

```json
{
  "totalSent": 150,
  "totalDelivered": 145,
  "totalOpened": 98,
  "totalActioned": 45,
  "openRate": 0.65,
  "clickThroughRate": 0.31,
  "byType": {
    "course_assigned": {
      "sent": 50,
      "delivered": 48,
      "opened": 35,
      "actioned": 20,
      "openRate": 0.70,
      "clickThroughRate": 0.40
    }
  },
  "byChannel": {
    "push": {
      "sent": 100,
      "delivered": 95,
      "failed": 5,
      "deliveryRate": 0.95
    }
  },
  "timeline": [
    {
      "date": "2025-01-15T00:00:00Z",
      "sent": 75,
      "delivered": 73,
      "opened": 50,
      "actioned": 25
    }
  ]
}
```

## Notification Types

| Type | Description |
|------|-------------|
| course_assigned | Новый курс назначен |
| course_completed | Курс завершен |
| test_available | Доступен тест |
| test_deadline | Дедлайн теста |
| test_completed | Тест завершен |
| task_assigned | Задача назначена |
| achievement_unlocked | Достижение получено |
| certificate_issued | Сертификат выдан |
| system_message | Системное сообщение |
| admin_message | Сообщение администратора |
| feed_activity | Активность в ленте |
| feed_mention | Упоминание |
| onboarding_task | Задача онбординга |

## Notification Priorities

| Priority | Value | Description |
|----------|-------|-------------|
| low | 0 | Низкий приоритет |
| medium | 1 | Средний приоритет |
| high | 2 | Высокий приоритет |
| urgent | 3 | Срочное уведомление |

## Notification Channels

| Channel | Description |
|---------|-------------|
| in_app | В приложении |
| push | Push-уведомления |
| email | Email |
| sms | SMS |

## Error Responses

### 400 Bad Request

```json
{
  "error": "validation_error",
  "message": "Invalid request parameters",
  "details": {
    "page": "Must be a positive integer"
  }
}
```

### 401 Unauthorized

```json
{
  "error": "unauthorized",
  "message": "Authentication required"
}
```

### 404 Not Found

```json
{
  "error": "not_found",
  "message": "Notification not found"
}
```

### 500 Internal Server Error

```json
{
  "error": "internal_error",
  "message": "An unexpected error occurred"
}
```

## Rate Limiting

API endpoints are rate limited:

- 100 requests per minute for authenticated users
- 1000 requests per hour for authenticated users

Rate limit headers are included in responses:

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1642339200
```

## Webhooks

You can subscribe to notification events via webhooks:

### Events

- `notification.created` - New notification created
- `notification.read` - Notification marked as read
- `notification.deleted` - Notification deleted
- `push_token.registered` - New push token registered
- `push_token.failed` - Push token failed

### Webhook Payload

```json
{
  "event": "notification.created",
  "timestamp": "2025-01-16T10:00:00Z",
  "data": {
    // Event specific data
  }
}
```

## SDKs

Official SDKs are available for:

- Swift (iOS)
- Kotlin (Android)
- JavaScript/TypeScript (Web)

## Support

For API support, please contact:
- Email: api-support@lms.example.com
- Documentation: https://docs.lms.example.com/api/notifications 