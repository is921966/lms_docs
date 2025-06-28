# Решения для доступа к TestFlight Feedback

## Проблема
Apple не предоставляет API для получения:
- Screenshot feedback (скриншоты с аннотациями)
- Текстовых отзывов тестировщиков
- Детальной информации о проблемах

## Варианты решения

### 1. 📧 Email уведомления (Быстрое решение)

**Настройка в App Store Connect:**
1. Войдите в [App Store Connect](https://appstoreconnect.apple.com)
2. Users and Access → выберите пользователя
3. Apps → выберите TSUM LMS
4. Включите "TestFlight Feedback" в Email Notifications

**Плюсы:**
- ✅ Мгновенные уведомления
- ✅ Скриншоты приходят в email
- ✅ Не требует дополнительных инструментов

**Минусы:**
- ❌ Ручная обработка
- ❌ Нет автоматизации
- ❌ Сложно систематизировать

### 2. 🤖 Сторонние сервисы автоматизации

#### AppFollow
- **Цена**: от $69/месяц
- **Функции**: 
  - Автоматический сбор отзывов
  - API для интеграции
  - Slack/Jira интеграция
- **Сайт**: https://appfollow.io

#### AppBot
- **Цена**: от $19/месяц
- **Функции**:
  - Sentiment анализ
  - Автоматические отчеты
  - Webhook интеграция
- **Сайт**: https://appbot.co

#### Appfigures
- **Цена**: от $12.99/месяц
- **Функции**:
  - Консолидация отзывов
  - API доступ
  - Email дайджесты
- **Сайт**: https://appfigures.com

### 3. 📱 Встроенные SDK для feedback (Рекомендуется)

#### Instabug
```swift
// Установка через SPM
dependencies: [
    .package(url: "https://github.com/Instabug/Instabug-iOS", from: "13.0.0")
]

// Инициализация
import Instabug
Instabug.start(withToken: "YOUR_TOKEN", invocationEvents: [.shake, .screenshot])
```

**Функции:**
- Screenshot аннотации прямо в приложении
- Автоматический сбор device logs
- Crash reporting
- In-app surveys

#### Shake
```swift
// Установка
pod 'Shake'

// Использование
import Shake
Shake.start(apiKey: "YOUR_API_KEY")
Shake.configuration.isInvokedByShakeDeviceEvent = true
```

**Функции:**
- Похож на TestFlight feedback
- API для получения отзывов
- Интеграция с Jira/Slack

### 4. 🔧 Гибридное решение (Оптимально)

Комбинация нескольких подходов:

1. **Для production**: Instabug/Shake SDK
2. **Для TestFlight**: Email уведомления + ручной мониторинг
3. **Для автоматизации**: Webhook из email в Slack/Discord

### 5. 📝 Создание собственного решения

#### Простой feedback форма в приложении:
```swift
// FeedbackViewController.swift
class FeedbackViewController: UIViewController {
    @IBOutlet weak var feedbackTextView: UITextView!
    @IBOutlet weak var screenshotImageView: UIImageView!
    
    var screenshot: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Автоматический скриншот предыдущего экрана
        screenshot = captureScreenshot()
        screenshotImageView.image = screenshot
    }
    
    @IBAction func sendFeedback() {
        let feedback = FeedbackModel(
            text: feedbackTextView.text,
            screenshot: screenshot,
            deviceInfo: DeviceInfo.current,
            buildVersion: Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        )
        
        // Отправка на ваш сервер
        FeedbackAPI.send(feedback) { success in
            if success {
                self.dismiss(animated: true)
            }
        }
    }
}
```

#### Backend API для сбора:
```python
# FastAPI endpoint
from fastapi import FastAPI, UploadFile
from datetime import datetime

app = FastAPI()

@app.post("/api/feedback")
async def receive_feedback(
    text: str,
    screenshot: UploadFile = None,
    device_info: dict = None,
    build_version: str = None
):
    # Сохранение в БД
    feedback_id = save_to_database({
        "text": text,
        "timestamp": datetime.utcnow(),
        "device_info": device_info,
        "build_version": build_version
    })
    
    # Сохранение скриншота
    if screenshot:
        file_path = f"screenshots/{feedback_id}.png"
        with open(file_path, "wb") as f:
            f.write(await screenshot.read())
    
    # Отправка в Slack
    send_to_slack(text, screenshot_url=file_path)
    
    return {"status": "success", "id": feedback_id}
```

### 6. 🔄 Автоматизация email → GitHub Issues

```python
# email_to_github.py
import imaplib
import email
from github import Github
import re

def fetch_testflight_emails():
    mail = imaplib.IMAP4_SSL('imap.gmail.com')
    mail.login('your-email@gmail.com', 'app-specific-password')
    mail.select('inbox')
    
    # Поиск писем от TestFlight
    _, messages = mail.search(None, 'FROM "noreply@email.apple.com"')
    
    for num in messages[0].split():
        _, data = mail.fetch(num, '(RFC822)')
        msg = email.message_from_bytes(data[0][1])
        
        if "TestFlight" in msg['Subject']:
            process_feedback_email(msg)

def process_feedback_email(msg):
    # Извлечение информации
    body = get_email_body(msg)
    screenshots = extract_attachments(msg)
    
    # Создание GitHub issue
    g = Github("your-github-token")
    repo = g.get_repo("your-org/your-repo")
    
    issue = repo.create_issue(
        title=f"TestFlight Feedback: {msg['Subject']}",
        body=body,
        labels=['testflight', 'feedback']
    )
    
    # Добавление скриншотов в комментарии
    for screenshot in screenshots:
        issue.create_comment(f"![Screenshot]({upload_to_imgur(screenshot)})")
```

## Рекомендуемый план действий

### Краткосрочное решение (1-2 дня):
1. ✅ Настройте email уведомления в App Store Connect
2. ✅ Создайте Slack webhook для важных уведомлений
3. ✅ Используйте Fastlane для базовой информации

### Среднесрочное решение (1-2 недели):
1. 🔧 Интегрируйте Instabug или Shake SDK
2. 🔧 Настройте автоматизацию email → GitHub/Jira
3. 🔧 Создайте дашборд для отслеживания

### Долгосрочное решение (1 месяц):
1. 🎯 Разработайте собственную систему feedback
2. 🎯 Интегрируйте с вашим bug tracker
3. 🎯 Настройте аналитику и метрики

## Сравнительная таблица решений

| Решение | Стоимость | Сложность | Автоматизация | Скриншоты |
|---------|-----------|-----------|---------------|-----------|
| Email уведомления | Бесплатно | ⭐ | ❌ | ✅ |
| AppFollow | $69+/мес | ⭐⭐ | ✅ | ✅ |
| Instabug | $124+/мес | ⭐⭐ | ✅ | ✅ |
| Shake | $50+/мес | ⭐⭐ | ✅ | ✅ |
| Собственное решение | Время разработки | ⭐⭐⭐⭐ | ✅ | ✅ |
| Email автоматизация | Бесплатно | ⭐⭐⭐ | ✅ | ✅ |

## Быстрый старт

Для немедленного решения:
1. Включите email уведомления прямо сейчас
2. Установите Shake SDK (есть бесплатный план)
3. Используйте созданный Fastlane action для базовой информации 