# 📸 Настройка поддержки скриншотов через Imgur

**Дата создания**: 2025-06-29
**Статус**: 📋 ИНСТРУКЦИЯ

## ✅ Шаг 1: Регистрация на Imgur (ВЫПОЛНЕНО)

Вы уже выполнили этот шаг и получили Client ID. Отлично!

## 📝 Шаг 2: Обновление облачного сервера

### 2.1. Войдите в Render Dashboard

1. Откройте https://dashboard.render.com
2. Войдите в свой аккаунт
3. Найдите сервис `lms-feedback-server`

### 2.2. Добавьте переменную окружения IMGUR_CLIENT_ID

1. В настройках сервиса нажмите на вкладку **Environment**
2. Нажмите кнопку **Add Environment Variable**
3. Добавьте новую переменную:
   - **Key**: `IMGUR_CLIENT_ID`
   - **Value**: Ваш Client ID от Imgur (например: `a1b2c3d4e5f6g7h`)
4. Нажмите **Save**

### 2.3. Обновите код сервера

#### Вариант А: Через GitHub (рекомендуется)

1. Замените содержимое файла `scripts/feedback_server.py` на содержимое `scripts/feedback_server_updated.py`:

```bash
# В локальном репозитории
cd /Users/ishirokov/lms_docs/LMS_App/LMS
cp scripts/feedback_server_updated.py scripts/feedback_server.py
git add scripts/feedback_server.py
git commit -m "feat: Add Imgur support for screenshot uploads"
git push origin master
```

2. Render автоматически подхватит изменения и передеплоит сервер

#### Вариант Б: Через Render Shell (если нет автодеплоя)

1. В Render Dashboard нажмите **Shell**
2. Выполните команды:
```bash
# Создайте резервную копию
cp feedback_server.py feedback_server_backup.py

# Обновите файл
cat > feedback_server.py << 'EOF'
# Вставьте сюда содержимое feedback_server_updated.py
EOF
```

3. Перезапустите сервис через **Manual Deploy** → **Deploy latest commit**

### 2.4. Проверьте статус развертывания

1. Перейдите в раздел **Events**
2. Дождитесь сообщения "Deploy live"
3. Проверьте логи на наличие ошибок

## 🧪 Шаг 3: Тестирование

### 3.1. Проверка здоровья сервера

Откройте в браузере:
```
https://lms-feedback-server.onrender.com/health
```

Вы должны увидеть:
```json
{
  "status": "healthy",
  "github_configured": true,
  "imgur_configured": true,  // ← Это должно быть true
  "feedback_count": 0
}
```

### 3.2. Тестирование через iOS приложение

1. **Откройте приложение LMS** в TestFlight
2. **Перейдите на любой экран** (например, Компетенции)
3. **Потрясите устройство** или нажмите на плавающую кнопку обратной связи
4. **Заполните форму**:
   - Выберите тип: "Ошибка"
   - Введите текст: "Тест скриншотов через Imgur"
   - Убедитесь, что скриншот отображается (должен быть экран Компетенций, а не форма)
5. **Отправьте отзыв**

### 3.3. Проверка результата

1. **Откройте GitHub Issues**:
   ```
   https://github.com/is921966/lms_docs/issues
   ```

2. **Найдите новый Issue** с заголовком:
   ```
   🐛 [bug] Тест скриншотов через Imgur
   ```

3. **Проверьте содержимое Issue**:
   - Должен быть раздел "📸 Скриншот"
   - Под ним должно быть изображение с Imgur
   - Изображение должно показывать экран приложения (не форму обратной связи)

### 3.4. Тестирование через curl (опционально)

```bash
curl -X POST https://lms-feedback-server.onrender.com/api/v1/feedback \
  -H "Content-Type: application/json" \
  -d '{
    "type": "bug",
    "text": "Test feedback with screenshot",
    "screenshot": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==",
    "deviceInfo": {
      "model": "iPhone",
      "osVersion": "18.0",
      "appVersion": "2.0.1"
    }
  }'
```

## 🔍 Возможные проблемы и решения

### Проблема 1: "imgur_configured": false в health check

**Причина**: Переменная окружения не установлена
**Решение**: 
1. Проверьте правильность имени переменной (IMGUR_CLIENT_ID)
2. Убедитесь, что сохранили изменения в Render
3. Перезапустите сервис

### Проблема 2: Скриншот не появляется в GitHub Issue

**Возможные причины**:
1. **Неверный Client ID** - проверьте в Imgur настройках
2. **Превышен лимит Imgur** - бесплатный аккаунт имеет лимиты
3. **Слишком большой скриншот** - Imgur ограничивает размер

**Решение**: Проверьте логи сервера в Render Dashboard

### Проблема 3: Issue создается, но без скриншота

**Причина**: Скриншот не передается с клиента
**Решение**: 
1. Убедитесь, что используете последнюю версию приложения из TestFlight
2. Проверьте, что скриншот отображается в форме перед отправкой

## 📊 Мониторинг

### Где смотреть логи:
1. **Render Dashboard** → **Logs** - для серверных ошибок
2. **GitHub Issues** - для проверки результатов
3. **Imgur Dashboard** - для статистики использования API

### Что искать в логах:
- `✅ Uploaded screenshot to Imgur: https://i.imgur.com/xxxxx.png` - успешная загрузка
- `❌ Failed to upload to Imgur` - ошибка загрузки
- `⚠️ Imgur client ID не настроен` - не установлена переменная окружения

## ✅ Чек-лист готовности

- [ ] IMGUR_CLIENT_ID добавлен в Render Environment Variables
- [ ] Сервер обновлен с feedback_server_updated.py
- [ ] Health check показывает "imgur_configured": true
- [ ] Тестовый отзыв создает Issue со скриншотом
- [ ] Скриншот корректно отображается в GitHub Issue

## 🎯 Результат

После выполнения всех шагов:
1. Пользователи смогут отправлять отзывы со скриншотами
2. Скриншоты будут автоматически загружаться на Imgur
3. В GitHub Issues будут отображаться полноценные изображения
4. Команда разработки получит визуальный контекст для каждой проблемы

---

*При возникновении проблем проверьте логи сервера и убедитесь, что все переменные окружения установлены правильно.* 