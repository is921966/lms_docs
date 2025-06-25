# Инструкция по настройке VK ID для LMS

## Шаг 1: Регистрация в VK ID

1. Перейдите на https://id.vk.com
2. Нажмите "Моё пространство" → "Сервис авторизации"
3. Создайте новое приложение

## Шаг 2: Заполнение данных приложения

### Web-приложение:
- **Базовый домен**: `lms.tsum.ru` (или ваш домен)
- **Доверенный Redirect URL**: `https://lms.tsum.ru/vk_id_redirect`

### iOS-приложение:
- **Universal link**: `https://lms.tsum.ru/vk_id_redirect`

## Шаг 3: Настройка на сервере

1. Разместите файл `apple-app-site-association` на вашем сервере:
   - URL: `https://lms.tsum.ru/.well-known/apple-app-site-association`
   - Или: `https://lms.tsum.ru/apple-app-site-association`

2. Содержимое файла:
```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "N85286S93X.ru.tsum.lms.igor",
        "paths": [
          "/vk_id_redirect",
          "/vk_id_redirect/*"
        ]
      }
    ]
  }
}
```

3. Убедитесь, что файл доступен через HTTPS с правильным Content-Type: `application/json`

## Шаг 4: Настройка в Xcode

1. Откройте проект в Xcode
2. Выберите target вашего приложения
3. Перейдите в "Signing & Capabilities"
4. Нажмите "+ Capability"
5. Добавьте "Associated Domains"
6. Добавьте домен: `applinks:lms.tsum.ru`

## Шаг 5: Обновление конфигурации

В файле `AppConfig.swift` обновите:
```swift
static let vkAppId = "YOUR_VK_APP_ID" // ID из VK ID консоли
static let vkClientSecret = "YOUR_CLIENT_SECRET" // Секрет из VK ID консоли
```

## Проверка настройки

1. Установите приложение на устройство
2. Попробуйте авторизоваться через VK ID
3. После авторизации вы должны автоматически вернуться в приложение

## Возможные проблемы

1. **Universal Link не работает**:
   - Проверьте, что файл `apple-app-site-association` доступен
   - Убедитесь, что Team ID правильный (N85286S93X)
   - Проверьте, что Bundle ID совпадает (ru.tsum.lms.igor)

2. **VK ID не открывается**:
   - Проверьте URL схемы в Info.plist
   - Убедитесь, что VK приложение установлено на устройстве

3. **Ошибка авторизации**:
   - Проверьте правильность VK App ID и Client Secret
   - Убедитесь, что приложение одобрено в VK 