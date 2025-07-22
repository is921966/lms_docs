# 🚂 Railway Quick Start - 5 минут до работающих серверов!

## Шаг 1: Авторизация (1 минута)

```bash
railway login
```
Откроется браузер - войдите через GitHub.

## Шаг 2: Деплой Log Server (2 минуты)

```bash
# 1. Создаем папку
cd /tmp && mkdir lms-log-server && cd lms-log-server

# 2. Копируем файлы одной командой
cp /Users/ishirokov/lms_docs/scripts/log_server_cloud.py . && \
cp /Users/ishirokov/lms_docs/scripts/requirements.txt . && \
echo 'web: gunicorn log_server_cloud:app --bind 0.0.0.0:$PORT' > Procfile

# 3. Инициализация и деплой
railway init --name lms-log-server
railway up

# 4. Получаем URL
railway domain
```

Запишите URL! Например: `lms-log-server-production-abc123.up.railway.app`

## Шаг 3: Деплой Feedback Server (2 минуты)

```bash
# 1. Создаем папку
cd /tmp && mkdir lms-feedback-server && cd lms-feedback-server

# 2. Копируем файлы одной командой
cp /Users/ishirokov/lms_docs/LMS_App/LMS/scripts/feedback_server.py . && \
cp /Users/ishirokov/lms_docs/scripts/requirements.txt . && \
echo 'web: gunicorn feedback_server:app --bind 0.0.0.0:$PORT' > Procfile

# 3. Инициализация
railway init --name lms-feedback-server

# 4. Устанавливаем переменные (замените на ваш токен!)
railway variables set GITHUB_TOKEN=ghp_ВАШ_ТОКЕН_ЗДЕСЬ \
  GITHUB_OWNER=is921966 \
  GITHUB_REPO=lms_docs

# 5. Деплой
railway up

# 6. Получаем URL
railway domain
```

## Шаг 4: Обновляем iOS приложение (30 секунд)

Откройте в Xcode:

### LogUploader.swift
```swift
private let serverEndpoint = "https://ВАШ-LOG-SERVER.up.railway.app/api/logs"
```

### ServerFeedbackService.swift
```swift
private let serverURL = "https://ВАШ-FEEDBACK-SERVER.up.railway.app/api/v1/feedback"
```

## ✅ Готово!

Проверьте работу:
- Log Dashboard: `https://ваш-log-server.up.railway.app`
- Feedback Dashboard: `https://ваш-feedback-server.up.railway.app`

## 🚨 Если что-то пошло не так

### "railway: command not found"
```bash
brew install railway
```

### "Project creation failed"
Имя проекта уже занято - используйте другое:
```bash
railway init --name lms-log-server-$(date +%s)
```

### Сервер не отвечает
```bash
railway logs  # Посмотрите логи
railway restart  # Перезапустите
```

## 💡 Полезные команды

```bash
# Посмотреть все проекты
railway list

# Переключиться между проектами
railway link

# Удалить проект
railway down

# Открыть веб-консоль
railway open
``` 