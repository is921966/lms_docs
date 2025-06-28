# Интеграция Shake SDK для feedback в LMS App

## Почему Shake?
- ✅ Бесплатный план до 100 отзывов/месяц
- ✅ Похож на TestFlight feedback
- ✅ API для автоматизации
- ✅ Простая интеграция (15 минут)

## Шаг 1: Регистрация и получение API ключа

1. Зайдите на https://www.shakebugs.com
2. Создайте аккаунт (бесплатно)
3. Создайте новое приложение "TSUM LMS"
4. Скопируйте API ключ

## Шаг 2: Установка через CocoaPods

```ruby
# Добавьте в Podfile
pod 'Shake-iOS'
```

```bash
cd /Users/ishirokov/lms_docs/LMS_App/LMS
pod install
```

## Шаг 3: Интеграция в код

### В LMSApp.swift:

```swift
import SwiftUI
import Shake

@main
struct LMSApp: App {
    init() {
        // Инициализация Shake
        #if DEBUG
        // Для тестирования используем staging окружение
        Shake.configuration.isInvokedByShakeDeviceEvent = true
        Shake.start(apiKey: "YOUR_STAGING_API_KEY")
        #else
        // Для production/TestFlight
        Shake.configuration.isInvokedByShakeDeviceEvent = true
        Shake.configuration.isFloatingReportButtonShown = true
        Shake.start(apiKey: "YOUR_PRODUCTION_API_KEY")
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### Добавление кастомных действий:

```swift
// В любом месте приложения можно вызвать
import Shake

// Программный вызов feedback
Shake.show()

// Добавление метаданных
Shake.metadata = [
    "user_id": currentUser.id,
    "build_version": Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "",
    "environment": "TestFlight"
]

// Добавление кастомной кнопки
struct FeedbackButton: View {
    var body: some View {
        Button(action: {
            Shake.show(reportType: .bug)
        }) {
            Label("Сообщить о проблеме", systemImage: "exclamationmark.bubble")
        }
    }
}
```

## Шаг 4: Настройка автоматизации

### Webhook в Slack:

1. В Shake Dashboard → Settings → Integrations
2. Добавьте Slack webhook
3. Выберите канал #testflight-feedback

### API интеграция:

```python
# fetch_shake_feedback.py
import requests
import json

SHAKE_API_KEY = "YOUR_API_KEY"
SHAKE_API_SECRET = "YOUR_API_SECRET"

def fetch_recent_feedback():
    headers = {
        "Authorization": f"Bearer {SHAKE_API_KEY}",
        "X-API-Secret": SHAKE_API_SECRET
    }
    
    response = requests.get(
        "https://api.shakebugs.com/v1/tickets",
        headers=headers,
        params={"status": "open", "limit": 50}
    )
    
    tickets = response.json()["data"]
    
    for ticket in tickets:
        # Получаем детали включая скриншоты
        details = requests.get(
            f"https://api.shakebugs.com/v1/tickets/{ticket['id']}",
            headers=headers
        ).json()
        
        # Создаем GitHub issue
        create_github_issue(
            title=details["title"],
            body=details["description"],
            screenshots=details["attachments"]
        )
```

## Шаг 5: Тестирование

1. Запустите приложение на устройстве
2. Потрясите устройство (shake gesture)
3. Появится форма отзыва
4. Добавьте текст и аннотации на скриншот
5. Отправьте

## Альтернатива: Простая кастомная форма

Если не хотите использовать SDK:

```swift
// SimpleFeedbackView.swift
struct SimpleFeedbackView: View {
    @State private var feedbackText = ""
    @State private var screenshot: UIImage?
    @State private var isSubmitting = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Ваш отзыв") {
                    TextEditor(text: $feedbackText)
                        .frame(minHeight: 100)
                }
                
                if let screenshot = screenshot {
                    Section("Скриншот") {
                        Image(uiImage: screenshot)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                    }
                }
                
                Section {
                    Button(action: submitFeedback) {
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Отправить")
                        }
                    }
                    .disabled(feedbackText.isEmpty || isSubmitting)
                }
            }
            .navigationTitle("Обратная связь")
            .navigationBarItems(
                leading: Button("Отмена") { dismiss() },
                trailing: Button(action: takeScreenshot) {
                    Image(systemName: "camera")
                }
            )
        }
        .onAppear {
            // Автоматический скриншот предыдущего экрана
            screenshot = captureScreen()
        }
    }
    
    func submitFeedback() {
        isSubmitting = true
        
        var request = URLRequest(url: URL(string: "https://your-api.com/feedback")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let feedback = [
            "text": feedbackText,
            "screenshot": screenshot?.pngData()?.base64EncodedString() ?? "",
            "device": UIDevice.current.model,
            "os_version": UIDevice.current.systemVersion,
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: feedback)
        
        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                isSubmitting = false
                dismiss()
            }
        }.resume()
    }
    
    func captureScreen() -> UIImage? {
        guard let window = UIApplication.shared.windows.first else { return nil }
        UIGraphicsBeginImageContextWithOptions(window.frame.size, false, 0)
        window.drawHierarchy(in: window.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func takeScreenshot() {
        screenshot = captureScreen()
    }
}
```

## Итоговые преимущества

### С Shake SDK:
- ✅ Работает из коробки
- ✅ Автоматические скриншоты
- ✅ Рисование на скриншотах
- ✅ Автоматический сбор device info
- ✅ Crash reports
- ✅ API для автоматизации

### С кастомной формой:
- ✅ Полный контроль
- ✅ Нет зависимостей
- ✅ Бесплатно
- ❌ Нужен backend
- ❌ Больше работы

## Рекомендация

Для быстрого старта используйте Shake SDK:
1. 15 минут на интеграцию
2. Бесплатно для небольших команд
3. Решает проблему screenshot feedback
4. Есть API для автоматизации 