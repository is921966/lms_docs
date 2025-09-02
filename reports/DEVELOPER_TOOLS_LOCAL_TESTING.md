# 🧪 Тестирование Developer Tools с локальными серверами

## ✅ Текущий статус

Developer Tools успешно интегрированы и работают! На скриншоте видно:
- ✅ Cloud Servers View открывается корректно
- ✅ Переключение между Log и Feedback Dashboard работает
- ✅ Отображается информация о серверах
- ⚠️ Ошибка подключения к production URL - это нормально

## 🚀 Запуск локальных серверов

### 1. Log Server (порт 5000):
```bash
cd /Users/ishirokov/lms_docs/scripts
PORT=5000 python3 log_server_cloud.py
```

### 2. Feedback Server (порт 5001):
```bash
cd /Users/ishirokov/lms_docs/LMS_App/LMS/scripts
python3 feedback_server_cloud.py
```

### 3. Проверка работы:
```bash
curl http://localhost:5000/health  # Log Server
curl http://localhost:5001/health  # Feedback Server
```

## 📱 Настройки в приложении

Временно настроено для работы с localhost:
- **Log Server**: `http://localhost:5000`
- **Feedback Server**: `http://localhost:5001`

Info.plist обновлен для разрешения HTTP подключений к localhost.

## 🔄 Переключение на production

После деплоя на Railway:
1. Обновите URL в `CloudServerManager.swift`
2. Уберите временные localhost URL
3. Верните production URLs

## 📝 Использование

1. Запустите оба сервера (см. выше)
2. Откройте приложение в Xcode
3. Запустите на симуляторе (Cmd+R)
4. Перейдите в Настройки → Developer Tools → Cloud Servers
5. Теперь вместо ошибки вы увидите:
   - Log Dashboard с реальными логами
   - Feedback Dashboard с отзывами

## 🎯 Что можно делать:

- Просматривать логи в реальном времени
- Фильтровать логи по категориям
- Просматривать отзывы пользователей
- Переключаться между серверами свайпом
- Открывать dashboards в Safari
- Настраивать URL серверов

---

**Developer Tools готовы к использованию с локальными серверами!** 🚀 