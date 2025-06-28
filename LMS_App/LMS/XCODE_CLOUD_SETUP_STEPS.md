# 🚀 Настройка Xcode Cloud - Шаги выполнения

**Дата**: 2025-06-28  
**Статус**: В процессе

## ✅ Выполненные шаги:

1. ✅ Создана документация по миграции
2. ✅ Созданы CI скрипты (ci_post_clone.sh, ci_post_xcodebuild.sh)
3. ✅ Создана директория для shared схем

## 📋 Следующие шаги (выполните вручную в Xcode):

### Шаг 1: Открыть проект
```bash
open LMS.xcodeproj
```

### Шаг 2: Сделать схему shared
1. В Xcode: **Product → Scheme → Manage Schemes**
2. Найдите схему **LMS**
3. Поставьте галочку **Shared** ✅
4. Нажмите **Close**

### Шаг 3: Начать настройку Xcode Cloud
1. **Product → Xcode Cloud → Create Workflow**
2. Выберите **LMS** как primary app
3. Нажмите **Grant Access** для GitHub репозитория
4. Войдите в Apple ID (если требуется)

### Шаг 4: Настроить Workflow
**Название**: Build and Test

**Триггеры**:
- ✅ Branch Changes: main, develop, feature/*  
- ✅ Pull Request Changes
- ✅ Tag Changes: v*

### Шаг 5: Настроить Actions

**Build Action**:
- Platform: iOS
- Scheme: LMS
- Configuration: Debug

**Test Action**:
- Platform: iOS Simulator
- Devices: iPhone 16 Pro
- ✅ Run Tests in Parallel
- ✅ Collect Code Coverage

### Шаг 6: Environment Settings
**Post-Clone Script**: ci_scripts/ci_post_clone.sh
**Post-Build Script**: ci_scripts/ci_post_xcodebuild.sh

### Шаг 7: Запустить первую сборку
1. Нажмите **Save** 
2. Нажмите **Start Build**

## 🔄 Текущий статус:
- [ ] Схема сделана shared
- [ ] Workflow создан
- [ ] Первая сборка запущена

## 📝 Заметки:
- Убедитесь, что у вас есть доступ к Apple Developer аккаунту
- GitHub репозиторий должен быть доступен
- Первая настройка может занять 10-15 минут 