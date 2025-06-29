# 🚀 Быстрое развертывание в облаке

## Railway - 2 минуты до запуска

```bash
# 1. Установите Railway CLI
brew install railway

# 2. Войдите
railway login

# 3. В папке scripts выполните
railway init

# 4. Деплой с токеном
./deploy_to_railway.sh your_github_token_here

# 5. Получите URL
railway domain
```

## Render - через веб-интерфейс

1. Распакуйте `lms_feedback_server_render.zip`
2. Загрузите на GitHub
3. Подключите к Render
4. Добавьте GITHUB_TOKEN
5. Deploy!

## После развертывания

Обновите URL в `ServerFeedbackService.swift`:
```swift
private let serverURL = "https://your-app.railway.app/api/v1/feedback"
```

Готово! 🎉

## 📊 Проверка:
- **Dashboard**: https://lms-feedback.up.railway.app
- **Health**: https://lms-feedback.up.railway.app/health
- **Логи**: `railway logs`

## �� Альтернативы:

### Google Cloud Run (одной командой):
```bash
# Создайте Dockerfile
echo 'FROM python:3.9-slim
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
CMD gunicorn --bind :$PORT feedback_server:app' > Dockerfile

# Деплой
gcloud run deploy feedback-server --source . --allow-unauthenticated
```

## 🆘 Помощь:
- Полная документация: `CLOUD_DEPLOYMENT.md`
- Railway статус: `railway status`
- Railway дашборд: `railway open` 