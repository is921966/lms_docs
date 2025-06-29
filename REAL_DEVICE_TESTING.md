# 📱 Настройка тестирования на реальном устройстве

## 🎯 Быстрый старт

### 1. Запустите сервер обратной связи:
```bash
cd LMS_App/LMS/scripts
./quick_start.sh your_github_token_here
```

### 2. Настройте Xcode для реального устройства:
```bash
./setup_real_device.sh
```

### 3. Подключите iPhone и запустите приложение

## 🔧 Детальная настройка

### Шаг 1: Настройка сервера
```bash
# Установите зависимости
pip3 install -r requirements.txt

# Запустите сервер с вашим GitHub токеном
export GITHUB_TOKEN='your_github_token_here'
python3 feedback_server.py
```

### Шаг 2: Обновление конфигурации приложения
Файл `LMS/Config/AppConfig.swift` автоматически переключается между:
- **Симулятор**: `http://localhost:5001`
- **Реальное устройство**: `http://YOUR_MAC_IP:5001`

### Шаг 3: Получение IP адреса Mac
```bash
# Скрипт автоматически определит ваш IP
./setup_real_device.sh

# Или вручную:
ipconfig getifaddr en0
```

### Шаг 4: Проверка Firewall
Убедитесь, что порт 5001 открыт:
- Системные настройки → Безопасность → Firewall
- Разрешите входящие соединения для Terminal/Python

## 📱 Тестирование функций обратной связи

### На реальном устройстве:
1. **Shake gesture**: Потрясите телефон
2. **Floating button**: Нажмите кнопку в правом нижнем углу
3. **Debug menu**: Settings → Debug → Send Test Feedback

### Проверка отправки:
```bash
# В терминале с сервером вы увидите:
✅ Received feedback: [ID]
📝 Created GitHub issue: https://github.com/...
```

## 🚨 Решение проблем

### "Could not connect to server"
1. Проверьте, что сервер запущен
2. Проверьте IP адрес в `AppConfig.swift`
3. Убедитесь, что iPhone и Mac в одной сети
4. Проверьте Firewall настройки

### "Failed to create GitHub issue"
1. Проверьте GitHub токен
2. Убедитесь, что токен имеет права `repo`
3. Проверьте логи сервера

## 🔄 Переключение между режимами

```bash
# Для симулятора
./switch_device_mode.sh simulator

# Для реального устройства
./switch_device_mode.sh device
```

## 📊 Мониторинг

### Dashboard обратной связи:
```
http://YOUR_MAC_IP:5001
```

### Логи сервера:
```bash
tail -f feedback_server.log
```

## ✅ Чек-лист готовности

- [ ] Сервер запущен с правильным токеном
- [ ] IP адрес Mac определен корректно
- [ ] Firewall разрешает соединения на порт 5001
- [ ] iPhone и Mac в одной Wi-Fi сети
- [ ] Приложение собрано с правильной конфигурацией
- [ ] GitHub токен имеет необходимые права

---

После настройки вы сможете тестировать систему обратной связи на реальном устройстве! 🎉 