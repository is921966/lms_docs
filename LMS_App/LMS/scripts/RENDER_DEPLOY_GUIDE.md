# 🚀 Render Deploy Guide для LMS Feedback Server

## 📋 Что включено в архив

Архив `lms_feedback_server_render.zip` содержит все необходимые файлы для развертывания:

- `feedback_server.py` - основной серверный код
- `requirements.txt` - Python зависимости
- `Procfile` - конфигурация для запуска
- `.env.example` - пример переменных окружения

## 🔧 Шаги развертывания

### 1. Создайте аккаунт на Render
Перейдите на [render.com](https://render.com) и зарегистрируйтесь (бесплатно).

### 2. Создайте новый Web Service

1. Нажмите **"New +"** → **"Web Service"**
2. Выберите **"Deploy an existing image from a registry"** если хотите использовать Docker
   ИЛИ выберите **"Build and deploy from a Git repository"** для GitHub

### 3. Настройка через загрузку файлов

Если у вас нет GitHub репозитория:
1. Распакуйте `lms_feedback_server_render.zip`
2. Создайте новый GitHub репозиторий
3. Загрузите файлы в репозиторий
4. Подключите репозиторий к Render

### 4. Конфигурация сервиса

- **Name**: `lms-feedback-server`
- **Environment**: `Python 3`
- **Build Command**: `pip install -r requirements.txt`
- **Start Command**: `python feedback_server.py`

### 5. Переменные окружения

В разделе **Environment** добавьте:

```
GITHUB_TOKEN = your_github_token_here
GITHUB_OWNER = is921966
GITHUB_REPO = lms_docs
```

⚠️ **ВАЖНО**: Замените `your_github_token_here` на ваш реальный GitHub токен!

### 6. Deploy

Нажмите **"Create Web Service"** и подождите 2-3 минуты.

## 🎯 После развертывания

### Получите URL вашего сервиса
После успешного развертывания Render предоставит URL вида:
```
https://lms-feedback-server-xxxx.onrender.com
```

### Обновите iOS приложение
В файле `ServerFeedbackService.swift` обновите URL:
```swift
private let baseURL = "https://lms-feedback-server-xxxx.onrender.com"
```

### Проверьте работоспособность
1. Откройте в браузере: `https://your-service.onrender.com`
2. Проверьте health endpoint: `https://your-service.onrender.com/health`

## 🚨 Troubleshooting

### Сервис не запускается
- Проверьте логи в Render Dashboard
- Убедитесь, что все переменные окружения установлены
- Проверьте, что `requirements.txt` содержит все зависимости

### GitHub Issues не создаются
- Проверьте, что `GITHUB_TOKEN` установлен правильно
- Убедитесь, что токен имеет права `repo`
- Проверьте логи на наличие ошибок API

### 503 Service Unavailable
- Бесплатный план Render "засыпает" после 15 минут неактивности
- Первый запрос может занять 30-50 секунд
- Рассмотрите апгрейд до платного плана для 24/7 доступности

## 💡 Советы

1. **Мониторинг**: Настройте алерты в Render для отслеживания ошибок
2. **Логи**: Регулярно проверяйте логи в Dashboard
3. **Бэкапы**: Экспортируйте feedback данные периодически
4. **Безопасность**: Никогда не коммитьте токены в репозиторий

## 🆘 Поддержка

Если возникли проблемы:
1. Проверьте [документацию Render](https://render.com/docs)
2. Создайте issue в репозитории проекта
3. Проверьте логи сервиса на наличие ошибок

---

🎉 После успешного развертывания ваш feedback сервер будет доступен для всех тестировщиков! 