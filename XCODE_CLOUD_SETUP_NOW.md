# 🚀 Настройка Xcode Cloud - Пошаговая инструкция

**У вас есть доступ к Xcode Cloud!** Давайте настроим его прямо сейчас.

## 📋 Шаг 1: Начните создание Workflow

1. Вы уже в **Report Navigator** (⌘+9)
2. Кликните на вкладку **Cloud**
3. Нажмите кнопку:
   - **"Create Workflow..."** или
   - **"Get Started"** или
   - **"Set up Xcode Cloud"**

## 📋 Шаг 2: Выберите продукт

1. Выберите **LMS** (должен быть в списке)
2. Нажмите **Next**

## 📋 Шаг 3: Предоставьте доступ к GitHub

1. Появится окно **"Grant Access to Your Source Code"**
2. Выберите **GitHub**
3. Нажмите **Grant Access**
4. Откроется браузер - авторизуйтесь в GitHub
5. Разрешите доступ к репозиторию `is921966/lms_docs`
6. Вернитесь в Xcode

## 📋 Шаг 4: Настройте Workflow

### Название:
```
Workflow Name: Build and Test
```

### Настройте триггеры:
- ✅ **Branch Changes**
  - Branches: `master` (добавьте вручную)
  - Можно добавить: `develop`, `feature/*`
- ✅ **Pull Request Changes**
- ✅ **Tag Changes**
  - Pattern: `v*`

## 📋 Шаг 5: Настройте Actions

### Build Action:
- **Name**: Build
- **Platform**: iOS
- **Scheme**: LMS
- **Configuration**: Debug

### Test Action:
- **Name**: Test
- **Platform**: iOS Simulator
- **Devices**: 
  - iPhone 16 Pro (Latest iOS)
  - Можно добавить iPad Pro
- ✅ **Run Tests in Parallel**
- ✅ **Code Coverage**

### Archive Action (для master):
- **Name**: Archive
- **Platform**: iOS
- **Scheme**: LMS
- **Configuration**: Release
- **Condition**: Only on branch `master`

## 📋 Шаг 6: Post-Actions

### TestFlight Distribution:
- ✅ **Distribute to TestFlight**
- **Groups**: Internal Testers
- **Condition**: When Archive succeeds

## 📋 Шаг 7: Environment Configuration

### Custom Scripts:
- **Post-Clone Script**: `ci_scripts/ci_post_clone.sh`
- **Post-Build Script**: `ci_scripts/ci_post_xcodebuild.sh`

### Environment Variables (опционально):
- `MOCK_MODE`: `true`
- `API_BASE_URL`: `https://api.lms.example.com`

## 📋 Шаг 8: Сохранение и запуск

1. Нажмите **Save**
2. Xcode Cloud начнет настройку
3. Первая настройка может занять 5-10 минут

## 📋 Шаг 9: Первый запуск

После сохранения:
1. Workflow появится в списке
2. Нажмите **Start Build** для ручного запуска
3. Или сделайте commit - запустится автоматически

## ✅ Что произойдет после настройки:

1. **При каждом push в master**:
   - Запустятся тесты
   - Создастся сборка
   - Загрузится в TestFlight

2. **При Pull Request**:
   - Запустятся тесты
   - Покажется статус в GitHub

3. **При создании тега v*.**:
   - Создастся релизная сборка

## 🎯 Следующие шаги:

1. Дождитесь завершения первой сборки
2. Проверьте результаты во вкладке Cloud
3. Исправьте ошибки если есть
4. Настройте уведомления (опционально)

## 💡 Подсказки:

- Если появляются ошибки с подписью - Xcode Cloud сам их исправит
- Первая сборка может быть медленной (10-15 мин)
- Последующие будут быстрее (5-7 мин)

---

**Начните с клика на кнопку создания Workflow во вкладке Cloud!** 