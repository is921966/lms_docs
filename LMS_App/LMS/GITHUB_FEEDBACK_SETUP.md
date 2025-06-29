# 🔧 Настройка GitHub интеграции для Feedback

## 🚨 Проблема
Feedback из приложения не создают GitHub Issues автоматически.

## ✅ Решение за 5 минут

### Шаг 1: Создайте GitHub Personal Access Token

1. Откройте https://github.com/settings/tokens/new
2. Дайте имя токену: "LMS Feedback Integration"
3. Выберите права:
   - ✅ `repo` (для приватных репозиториев)
   - ✅ `public_repo` (для публичных)
4. Нажмите "Generate token"
5. **ВАЖНО**: Скопируйте токен сразу! (начинается с `ghp_`)

### Шаг 2: Настройте сервер

```bash
cd /Users/ishirokov/lms_docs/LMS_App/LMS/scripts

# Установите токен в переменную окружения
export GITHUB_TOKEN='ghp_ваш_токен_здесь'

# Запустите скрипт конфигурации
./github_feedback_config.sh
```

### Шаг 3: Запустите feedback server

```bash
# Остановите старый сервер если запущен
pkill -f feedback_server.py

# Запустите новый
python3 feedback_server.py
```

### Шаг 4: Проверьте работу

1. Откройте http://localhost:5000 - увидите Dashboard
2. В iOS приложении потрясите устройство
3. Отправьте тестовый feedback
4. Проверьте GitHub Issues: https://github.com/is921966/lms_docs/issues

## 📱 Как это работает

```
iOS App → Shake gesture → Feedback form → Send
    ↓
Feedback Server (localhost:5000)
    ↓
Автоматически создает GitHub Issue с:
- Описанием проблемы
- Информацией об устройстве  
- Версией приложения
- Скриншотом (если есть)
```

## 🎯 Результат

Каждый feedback из приложения автоматически появится как GitHub Issue с лейблами:
- `feedback` - все отзывы
- `mobile-app` - из мобильного приложения
- `ios` - платформа
- `bug` / `enhancement` / `question` - тип

## 🔒 Безопасность

- GitHub токен хранится только на сервере
- iOS приложение не имеет прямого доступа к GitHub
- Все запросы идут через ваш локальный сервер

## 🚀 Production настройка

Для production разверните feedback_server.py на вашем сервере:

1. Используйте HTTPS
2. Настройте nginx reverse proxy
3. Используйте переменные окружения для токена
4. Добавьте аутентификацию если нужно

## ❓ Troubleshooting

**Feedback не создает Issue:**
- Проверьте токен: `echo $GITHUB_TOKEN`
- Проверьте логи сервера в консоли
- Убедитесь что сервер запущен

**Ошибка 401 Unauthorized:**
- Токен неверный или истек
- Создайте новый токен

**Ошибка 404 Not Found:**
- Проверьте название репозитория в конфигурации
- Убедитесь что у токена есть доступ к репозиторию 