# 🚀 Инструкция по развертыванию на Render

## Проблема
Render не может найти файлы, потому что они находятся в подпапке `LMS_App/LMS/scripts/`.

## Решение

### Вариант 1: Через GitHub (рекомендуется)

1. **Создайте новый репозиторий** специально для feedback сервера:
   ```bash
   # В локальной папке
   cd /tmp
   mkdir lms-feedback-server
   cd lms-feedback-server
   
   # Копируем файлы
   cp ~/lms_docs/LMS_App/LMS/scripts/render_deploy/* .
   
   # Инициализируем git
   git init
   git add .
   git commit -m "Initial commit"
   
   # Создайте репозиторий на GitHub и свяжите
   git remote add origin https://github.com/is921966/lms-feedback-server.git
   git push -u origin main
   ```

2. **В Render Dashboard:**
   - Нажмите "New +" → "Web Service"
   - Выберите "Build and deploy from a Git repository"
   - Подключите новый репозиторий
   - Render автоматически найдет все файлы

### Вариант 2: Изменить Root Directory (текущий сервис)

1. **В вашем текущем сервисе на Render:**
   - Перейдите в Settings
   - Найдите "Root Directory"
   - Измените на: `LMS_App/LMS/scripts/render_deploy`
   - Нажмите "Save Changes"

2. **Trigger новый deploy:**
   - Перейдите во вкладку "Events"
   - Нажмите "Manual Deploy" → "Deploy latest commit"

### Вариант 3: Использовать Blueprint (автоматическая конфигурация)

1. **Создайте файл `render.yaml` в корне репозитория:**
   ```yaml
   services:
     - type: web
       name: lms-feedback-server
       env: python
       buildCommand: "cd LMS_App/LMS/scripts/render_deploy && pip install -r requirements.txt"
       startCommand: "cd LMS_App/LMS/scripts/render_deploy && python feedback_server.py"
       envVars:
         - key: GITHUB_TOKEN
           sync: false
         - key: GITHUB_OWNER
           value: is921966
         - key: GITHUB_REPO
           value: lms_docs
   ```

2. **Commit и push в GitHub**

3. **В Render создайте новый Blueprint:**
   - New + → Blueprint
   - Выберите ваш репозиторий
   - Render автоматически найдет `render.yaml`

## ⚠️ Важно: Переменные окружения

После развертывания обязательно установите `GITHUB_TOKEN`:
1. Dashboard → ваш сервис → Environment
2. Add Environment Variable
3. Key: `GITHUB_TOKEN`
4. Value: ваш GitHub токен
5. Save Changes

## 🔍 Проверка

После успешного развертывания:
- Откройте URL вашего сервиса
- Вы должны увидеть "LMS Feedback Dashboard"
- Проверьте `/health` endpoint для статуса 