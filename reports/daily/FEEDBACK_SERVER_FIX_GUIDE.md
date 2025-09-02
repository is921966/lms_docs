# 🔧 Исправление Feedback Server на Railway

**Дата**: 22 июля 2025  
**Проблема**: 502 Bad Gateway на lms-feedback-server

## 🔍 Найденная проблема

Feedback Server не был правильно настроен для работы с gunicorn:
- В Procfile указан запуск через gunicorn
- Но оригинальный feedback_server.py использовал `app.run()` вместо экспорта приложения
- Это приводило к невозможности запуска через gunicorn

## ✅ Решение

Создана специальная версия `feedback_server_railway.py`:
1. Убран `if __name__ == '__main__'` блок
2. Приложение Flask доступно на уровне модуля для gunicorn
3. Добавлена обработка ошибок и логирование
4. Оптимизирован для работы в Railway окружении

## 🚀 Инструкция по деплою

### Вариант 1: Через Railway CLI

```bash
# Перейдите в папку scripts
cd LMS_App/LMS/scripts

# Логин в Railway (если еще не залогинены)
railway login

# Выберите проект lms-feedback-server
railway link

# Проверьте переменные окружения
railway variables

# Убедитесь что установлен GITHUB_TOKEN!
# Если нет, установите:
railway variables set GITHUB_TOKEN="your_github_token_here"

# Деплой обновлений
railway up
```

### Вариант 2: Через GitHub (если настроен автодеплой)

```bash
# Добавьте изменения
git add LMS_App/LMS/scripts/feedback_server.py
git commit -m "fix: Railway-compatible feedback server"
git push
```

### Вариант 3: Через веб-интерфейс Railway

1. Откройте [railway.app](https://railway.app)
2. Найдите проект `lms-feedback-server`
3. Перейдите в Settings → Deploy
4. Нажмите "Redeploy"

## 🔍 Проверка

После деплоя проверьте:

1. **Health endpoint**:
   ```bash
   curl https://lms-feedback-server-production.up.railway.app/health
   ```

2. **Dashboard**:
   Откройте https://lms-feedback-server-production.up.railway.app

3. **Логи Railway**:
   ```bash
   railway logs
   ```

## ⚠️ Важные моменты

1. **GitHub Token** - убедитесь что переменная `GITHUB_TOKEN` установлена в Railway
2. **Gunicorn** - сервер теперь запускается через gunicorn, не через flask run
3. **Memory storage** - feedback хранится в памяти (до 1000 последних записей)
4. **Auto-restart** - Railway автоматически перезапустит сервер при сбое

## 📱 Обновление iOS приложения

Убедитесь что в `ServerFeedbackService.swift` правильный URL:
```swift
private let serverURL = "https://lms-feedback-server-production.up.railway.app/api/v1/feedback"
```

## 🎯 Результат

После применения исправлений:
- ✅ Feedback Server должен отвечать 200 OK
- ✅ Dashboard должен открываться
- ✅ Health check должен показывать статус
- ✅ Feedback из приложения должен приниматься

---

**Статус**: Исправления применены, требуется деплой на Railway 