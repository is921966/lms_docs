# TestFlight Feedback Automation

## Обзор

Поскольку я (AI-ассистент) не имею прямого доступа к TestFlight, вот инструкция по настройке автоматизации для работы с feedback от тестировщиков.

## Что может Screenshot Feedback в TestFlight

1. **Тестировщики могут**:
   - Делать скриншоты прямо в приложении (двойное нажатие двумя пальцами)
   - Добавлять комментарии к скриншотам
   - Отправлять отзывы с описанием проблем
   - Прикреплять информацию об устройстве и версии ОС

2. **Разработчики получают**:
   - Скриншоты с аннотациями
   - Текстовые комментарии
   - Метаданные (устройство, ОС, версия приложения)
   - Email тестировщика

## Настройка автоматизации

### 1. Получение API ключей App Store Connect

```bash
# В App Store Connect:
# 1. Users and Access → Keys → App Store Connect API
# 2. Generate API Key с правами "App Manager"
# 3. Скачайте .p8 файл (ВАЖНО: можно скачать только один раз!)
# 4. Запомните Key ID и Issuer ID
```

### 2. Настройка переменных окружения

```bash
# .env.local (НЕ коммитить!)
APP_STORE_CONNECT_API_KEY_ID=XXXXXXXXXX
APP_STORE_CONNECT_API_ISSUER_ID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
APP_STORE_CONNECT_API_KEY_PATH=./private_keys/AuthKey_XXXXXXXXXX.p8
```

### 3. Использование

```bash
# Получить все feedback
fastlane fetch_feedback

# Запускать автоматически каждый час (cron)
0 * * * * cd /path/to/project && fastlane fetch_feedback
```

## Альтернативные способы работы с feedback

### 1. Через веб-интерфейс App Store Connect
- Войдите в App Store Connect
- My Apps → Ваше приложение → TestFlight
- Вкладка "Feedback"

### 2. Через Xcode (частично)
- Window → Organizer → Crashes
- Показывает крэши, но не screenshot feedback

### 3. Через REST API напрямую

```bash
# Пример запроса к App Store Connect API
curl -H "Authorization: Bearer [JWT_TOKEN]" \
     "https://api.appstoreconnect.apple.com/v1/apps/{APP_ID}/betaTesters"
```

## Автоматизация обработки feedback

### GitHub Issues из feedback

```ruby
# Расширенная версия для создания issues
def create_issue_from_feedback(feedback)
  github_client.create_issue(
    repo: "your-org/your-repo",
    title: "TestFlight Feedback: #{feedback.summary}",
    body: <<~BODY
      ## Feedback от тестировщика
      
      **Email**: #{feedback.tester_email}
      **Дата**: #{feedback.timestamp}
      **Устройство**: #{feedback.device_model}
      **iOS**: #{feedback.os_version}
      
      ## Описание
      #{feedback.comment}
      
      ## Скриншоты
      ![Screenshot](#{uploaded_screenshot_url})
      
      ---
      *Автоматически создано из TestFlight feedback*
    BODY,
    labels: ['testflight-feedback', 'bug']
  )
end
```

### Slack уведомления

```ruby
# Отправка в Slack при получении критичного feedback
def notify_slack_critical_feedback(feedback)
  if feedback.comment.match?(/crash|critical|urgent/i)
    slack_webhook(
      text: "🚨 Критичный feedback в TestFlight!",
      attachments: [{
        color: "danger",
        fields: [
          { title: "От", value: feedback.tester_email },
          { title: "Комментарий", value: feedback.comment }
        ]
      }]
    )
  end
end
```

## Лучшие практики

1. **Регулярно проверяйте feedback** - настройте автоматизацию минимум раз в день
2. **Быстро отвечайте тестировщикам** - это мотивирует их продолжать тестирование
3. **Группируйте похожие отзывы** - часто разные тестировщики находят одну проблему
4. **Используйте метки в GitHub** - для категоризации feedback
5. **Архивируйте скриншоты** - сохраняйте их в S3 или другом хранилище

## Ограничения

- API может возвращать максимум 200 feedback за запрос
- Скриншоты доступны только 90 дней
- Нет webhook'ов - нужно использовать polling
- Нельзя отвечать тестировщикам через API

## Команды для быстрого доступа

```bash
# Открыть TestFlight feedback в браузере
open "https://appstoreconnect.apple.com/apps/YOUR_APP_ID/testflight/feedback"

# Скачать все feedback за последние 7 дней
fastlane fetch_feedback days:7

# Создать отчет по feedback
fastlane generate_feedback_report
``` 