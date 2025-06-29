# 🚀 Быстрые команды для настройки Imgur

## 1️⃣ Добавить IMGUR_CLIENT_ID в Render

1. Откройте: https://dashboard.render.com
2. Выберите: `lms-feedback-server`
3. Перейдите: `Environment` → `Add Environment Variable`
4. Добавьте:
   - Key: `IMGUR_CLIENT_ID`
   - Value: `ваш_client_id_от_imgur`
5. Нажмите: `Save`

## 2️⃣ Обновить код сервера

### Вариант А: Автоматически (рекомендуется)
```bash
cd /Users/ishirokov/lms_docs/LMS_App/LMS
./scripts/update-feedback-server.sh
```

### Вариант Б: Вручную
```bash
cd /Users/ishirokov/lms_docs/LMS_App/LMS
cp scripts/feedback_server_updated.py scripts/feedback_server.py
git add scripts/feedback_server.py
git commit -m "feat: Add Imgur support for screenshot uploads"
git push origin master
```

## 3️⃣ Проверить статус

### Проверка health сервера:
```bash
curl https://lms-feedback-server.onrender.com/health | jq
```

Должны увидеть:
```json
{
  "imgur_configured": true
}
```

### Тест через curl:
```bash
curl -X POST https://lms-feedback-server.onrender.com/api/v1/feedback \
  -H "Content-Type: application/json" \
  -d '{
    "type": "bug",
    "text": "Test with screenshot",
    "screenshot": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==",
    "deviceInfo": {
      "model": "iPhone",
      "osVersion": "18.0",
      "appVersion": "2.0.1"
    }
  }'
```

## 4️⃣ Проверить результат

1. GitHub Issues: https://github.com/is921966/lms_docs/issues
2. Найдите новый issue с заголовком `🐛 [bug] Test with screenshot`
3. Проверьте наличие изображения в разделе "📸 Скриншот"

## 🔍 Troubleshooting

### Если не работает:
```bash
# Проверить логи в Render
# Dashboard → Logs

# Проверить переменные окружения
# Dashboard → Environment

# Проверить статус деплоя
# Dashboard → Events
```

### Типичные проблемы:
- ❌ `imgur_configured: false` → проверьте IMGUR_CLIENT_ID
- ❌ Нет скриншота в issue → проверьте логи сервера
- ❌ 500 ошибка → неверный Client ID

## ✅ Все работает, если:

1. Health check показывает `"imgur_configured": true`
2. В логах видно `✅ Uploaded screenshot to Imgur`
3. GitHub Issue содержит изображение

---

💡 **Помните**: После push изменений подождите 2-5 минут для автодеплоя в Render 