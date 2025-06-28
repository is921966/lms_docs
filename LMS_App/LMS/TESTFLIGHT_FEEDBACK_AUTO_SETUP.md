# 🤖 TestFlight Feedback - Автоматическая настройка выполнена!

## ✅ Что было настроено автоматически

### 1. **Структура директорий**
```
LMS_App/LMS/
├── scripts/                    # Скрипты автоматизации
│   ├── fetch_testflight_feedback.py
│   ├── fetch-feedback.sh
│   ├── requirements.txt
│   ├── env.example
│   └── .env.local             # Ваша конфигурация (создана)
├── fastlane/
│   └── actions/
│       └── fetch_testflight_feedback.rb
├── private_keys/              # Для хранения .p8 ключей
├── setup-testflight-feedback.sh
├── get-api-keys.sh           # Помощник получения ключей
└── testflight-feedback       # Helper команда
```

### 2. **Python окружение**
- ✅ Python 3.9.6 обнаружен
- ✅ pip установлен
- ✅ Зависимости установлены:
  - PyJWT 2.8.0
  - cryptography 41.0.7
  - requests 2.31.0

### 3. **Fastlane**
- ✅ Fastlane обнаружен и работает
- ✅ Custom action `fetch_testflight_feedback` готов

### 4. **Конфигурация**
- ✅ Файл `.env.local` создан из шаблона
- ⚠️ **Требуется заполнить API ключи**

### 5. **Helper команды**
- ✅ `./testflight-feedback` - главная команда
- ✅ `./get-api-keys.sh` - помощник получения ключей

## 🚀 Что делать дальше

### Вариант 1: Интерактивное получение ключей
```bash
./get-api-keys.sh
```
Этот скрипт:
- Откроет App Store Connect в браузере
- Проведет вас через все шаги
- Поможет заполнить конфигурацию
- Переместит .p8 файл в нужное место

### Вариант 2: Ручное заполнение
1. Откройте файл конфигурации:
   ```bash
   nano scripts/.env.local
   # или
   code scripts/.env.local
   ```

2. Заполните значения:
   ```env
   APP_STORE_CONNECT_API_KEY_ID=ваш_key_id
   APP_STORE_CONNECT_API_ISSUER_ID=ваш_issuer_id
   APP_STORE_CONNECT_API_KEY_PATH=./private_keys/AuthKey_XXX.p8
   APP_ID=ваш_app_id
   ```

3. Скопируйте .p8 файл:
   ```bash
   cp ~/Downloads/AuthKey_*.p8 private_keys/
   ```

## 🧪 Проверка настройки

```bash
# Проверить, что все работает
./testflight-feedback test

# Получить feedback
./testflight-feedback fetch

# Показать справку
./testflight-feedback help
```

## 📱 Использование

### Через helper команду:
```bash
# Получить feedback за последние 7 дней
./testflight-feedback fetch

# Получить feedback за последние 14 дней
cd scripts && ./fetch-feedback.sh 14
```

### Через Fastlane:
```bash
# Базовое использование
fastlane fetch_feedback

# С созданием GitHub issues
fastlane fetch_feedback create_issues:true
```

### Через Python напрямую:
```bash
cd scripts
python3 fetch_testflight_feedback.py
```

## 🤖 GitHub Actions

Для автоматизации добавьте секреты в репозиторий:

1. Откройте: Settings → Secrets and variables → Actions
2. Добавьте:
   - `APP_STORE_CONNECT_API_KEY_ID`
   - `APP_STORE_CONNECT_API_ISSUER_ID`  
   - `APP_STORE_CONNECT_API_KEY` (содержимое .p8 файла)
   - `APP_ID`

GitHub Action будет автоматически:
- Запускаться каждый день в 12:00 MSK
- Создавать issues для критичных отзывов
- Сохранять отчеты

## 📊 Что вы получите

После запуска создается папка с отчетами:
```
testflight_reports_20250628_173456/
├── feedback_report.json    # JSON с полными данными
├── summary.txt            # Читаемое резюме
└── screenshots/           # Скриншоты от тестировщиков
```

## ❓ Решение проблем

### "Private key file not found"
```bash
# Проверьте путь к файлу
ls -la private_keys/

# Обновите путь в конфигурации
nano scripts/.env.local
```

### "No feedback found"
- Проверьте, есть ли активные тестировщики
- Убедитесь в правильности APP_ID
- Проверьте права доступа API ключа

### Python модули не найдены
```bash
cd scripts
pip3 install -r requirements.txt
```

## 🎉 Готово!

Система полностью настроена и готова к использованию.
Осталось только добавить API ключи!

**Быстрый старт:**
```bash
# 1. Получите ключи
./get-api-keys.sh

# 2. Проверьте настройку
./testflight-feedback test

# 3. Получите feedback!
./testflight-feedback fetch
```

---
*Автоматическая настройка выполнена $(date)* 