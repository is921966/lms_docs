# 🚀 TestFlight Feedback - Быстрый старт

## За 5 минут настройте автоматическое получение feedback из TestFlight!

### Шаг 1: Получите API ключи (2 минуты)

1. Откройте [App Store Connect](https://appstoreconnect.apple.com)
2. Перейдите в **Users and Access** → **Keys** → **App Store Connect API**
3. Нажмите **Generate API Key**
   - Name: `TestFlight Feedback Bot`
   - Access: `App Manager`
4. **ВАЖНО**: Скачайте `.p8` файл (можно только один раз!)
5. Запомните:
   - **Key ID**: `XXXXXXXXXX`
   - **Issuer ID**: `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`

### Шаг 2: Настройте окружение (1 минута)

```bash
cd LMS_App/LMS/scripts

# Скопируйте пример конфигурации
cp env.example .env.local

# Откройте для редактирования
open .env.local  # или используйте любой редактор
```

Заполните:
```env
APP_STORE_CONNECT_API_KEY_ID=ваш_key_id
APP_STORE_CONNECT_API_ISSUER_ID=ваш_issuer_id
APP_STORE_CONNECT_API_KEY_PATH=./AuthKey_XXXXXXXXXX.p8
APP_ID=ваш_app_id
```

### Шаг 3: Поместите ключ в нужное место (30 секунд)

```bash
# Переместите скачанный .p8 файл
mv ~/Downloads/AuthKey_XXXXXXXXXX.p8 ./
```

### Шаг 4: Запустите! (30 секунд)

```bash
# Через удобный скрипт
./fetch-feedback.sh

# Или через Fastlane (из папки LMS_App/LMS)
cd .. && fastlane fetch_feedback

# Или напрямую через Python
python3 fetch_testflight_feedback.py
```

## 📊 Что вы получите

После запуска будет создана папка `testflight_reports_YYYYMMDD_HHMMSS/` с:

```
testflight_reports_20250628_120000/
├── feedback_report.json    # Полный отчет в JSON
├── summary.txt            # Читаемое резюме
└── screenshots/           # Скачанные скриншоты
    ├── feedback_1_screenshot_0.png
    └── feedback_1_screenshot_1.png
```

## 🎯 Полезные команды

```bash
# Получить feedback за последние 14 дней
./fetch-feedback.sh 14

# Запустить с созданием GitHub issues
cd .. && fastlane fetch_feedback create_issues:true

# Проверить последний отчет
open testflight_reports_*/feedback_report.json
```

## 🤖 Автоматизация через GitHub Actions

1. Добавьте секреты в репозиторий:
   - `Settings` → `Secrets and variables` → `Actions`
   - Добавьте все переменные из `.env.local`

2. GitHub Action уже настроен и будет:
   - Запускаться каждый день в 12:00 MSK
   - Создавать issues для критичных отзывов
   - Сохранять отчеты как артефакты

3. Запустите вручную:
   - `Actions` → `Fetch TestFlight Feedback` → `Run workflow`

## ❓ Частые вопросы

**Q: Где найти APP_ID?**
A: В App Store Connect → Apps → Ваше приложение → App Information → Apple ID

**Q: Ошибка "Private key file not found"?**
A: Проверьте путь в `APP_STORE_CONNECT_API_KEY_PATH` - должен быть относительно папки scripts

**Q: Не находит feedback?**
A: Проверьте:
- Есть ли активные тестировщики в TestFlight
- Правильный ли APP_ID
- Достаточные ли права у API ключа

**Q: Как добавить Slack уведомления?**
A: Добавьте в `.env.local`:
```env
SLACK_WEBHOOK=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
```

## 🎉 Готово!

Теперь вы можете:
- ✅ Автоматически получать все отзывы из TestFlight
- ✅ Скачивать скриншоты с аннотациями
- ✅ Создавать GitHub issues для критичных проблем
- ✅ Получать уведомления о новых отзывах

**Совет**: Настройте cron job для ежедневного запуска:
```bash
# Добавьте в crontab
0 10 * * * cd /path/to/LMS_App/LMS/scripts && ./fetch-feedback.sh
``` 