# 📋 Шаг 7: Environment Configuration - Детальная инструкция

## 🔧 Где найти настройки Environment:

### Вариант 1: В процессе создания Workflow
Если вы всё ещё в мастере создания:
1. После настройки Actions должна быть секция **"Environment"**
2. Или кнопка **"Advanced"** / **"Environment Settings"**

### Вариант 2: Редактирование существующего Workflow
Если уже сохранили:
1. Во вкладке **Cloud** найдите ваш Workflow
2. Нажмите на него
3. Нажмите **"Edit Workflow..."**
4. Найдите секцию **"Environment"**

## 📝 Custom Build Scripts:

### Post-Clone Script:
1. Найдите поле **"Post-Clone Script"** или **"Custom Build Script"**
2. Введите путь: `ci_scripts/ci_post_clone.sh`
3. Или нажмите **"Browse"** и выберите файл

**Что делает этот скрипт:**
- Устанавливает Ruby зависимости
- Генерирует конфигурацию
- Подготавливает окружение

### Post-Build Script (опционально):
1. Если есть поле **"Post-Build Script"**
2. Введите: `ci_scripts/ci_post_xcodebuild.sh`

## 🔐 Environment Variables (опционально):

Если есть секция **"Environment Variables"**:

| Name | Value | Secret |
|------|-------|--------|
| MOCK_MODE | true | ❌ |
| API_BASE_URL | https://api.lms.example.com | ❌ |

## 💡 Если не видите эти опции:

### Альтернатива 1: Пропустите
- Xcode Cloud часто работает и без custom scripts
- Можно добавить позже

### Альтернатива 2: В самом Workflow
- После сохранения откройте Workflow
- Ищите **"Settings"** или **"Configuration"**
- Там могут быть дополнительные опции

## ✅ Завершение настройки:

### Если всё настроено:
1. Нажмите **"Save"** или **"Create Workflow"**
2. Подождите пока Xcode Cloud создаст workflow

### Что произойдет дальше:
1. Xcode Cloud начнет настройку (~2-3 минуты)
2. Автоматически запустится первая сборка
3. Вы увидите прогресс во вкладке Cloud

## 🚀 После сохранения:

### Проверьте статус:
1. Во вкладке **Cloud** появится ваш workflow
2. Статус должен быть:
   - 🟡 **"Setting up"** - настраивается
   - 🟢 **"Building"** - уже строится
   - ✅ **"Succeeded"** - успешно

### Если видите ошибки:
- **Signing errors** - Xcode Cloud исправит автоматически
- **Script not found** - можно удалить из настроек
- **Test failures** - нормально для первого запуска

---

**Вопрос**: Видите ли вы опции для Custom Scripts? Или просто сохраните workflow как есть? 