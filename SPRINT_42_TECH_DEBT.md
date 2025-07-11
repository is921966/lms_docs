# Sprint 42: Технический долг после экстренной корректировки

**Создан**: 17 января 2025  
**Критичность**: 🔴 ВЫСОКАЯ

## 🚨 Проблемы из GitHub Actions

### iOS Tests провалились:
- Exit code: 128
- Проблемы с компиляцией в Notification модуле
- Несовместимость API интерфейсов

### PHP Tests провалились:
- Exit code: 255 и 128
- Backend тесты не запускаются

## 📋 Обязательные задачи для Sprint 42

### День 1 (20 января) - ДОПОЛНИТЕЛЬНО к плану:

**Первые 2 часа (09:00-11:00):**
1. Исправить критические ошибки компиляции
2. Временно отключить/изолировать Notification код
3. Убедиться что Cmi5 компилируется отдельно

```bash
# Проверка компиляции только Cmi5
xcodebuild -scheme LMS -destination 'platform=iOS Simulator,name=iPhone 16' \
  build -only-testing:LMSTests/Cmi5 CODE_SIGNING_REQUIRED=NO
```

### Стратегия изоляции Notifications:

1. **Временное отключение**:
   ```swift
   // В FeatureRegistry.swift
   // .notifications(enabled: false), // ВРЕМЕННО отключено
   ```

2. **Условная компиляция**:
   ```swift
   #if ENABLE_NOTIFICATIONS
   // Notification код
   #endif
   ```

3. **Mock заглушки**:
   - Заменить реальные сервисы на mock
   - Минимальные интерфейсы для компиляции

## ⚠️ Критические файлы с ошибками:

### iOS:
- `NotificationAPIService.swift` - проблемы с cache и типами
- `APNsPushNotificationService.swift` - logger API
- `NotificationEndpoints.swift` - headers
- `LessonView.swift` - исправлено ✅
- `LRSService.swift` - исправлено ✅

### Backend:
- Проверить миграции БД
- Убедиться в совместимости версий PHP

## 🎯 План действий:

### Вариант A (Рекомендуемый):
1. Изолировать Notifications полностью
2. Сфокусироваться только на Cmi5
3. Вернуться к Notifications в Sprint 43

### Вариант B (Рискованный):
1. Быстро исправить ошибки компиляции
2. Минимальные mock для прохождения тестов
3. Продолжить с Cmi5

## 📊 Метрики для отслеживания:

```yaml
Начало Sprint 42:
  - Компилируется: ❌
  - Тесты проходят: ❌
  - CI/CD зеленый: ❌

Цель День 1:
  - Компилируется: ✅ (хотя бы Cmi5)
  - Тесты Cmi5: ✅
  - CI/CD: 🟡 (может быть желтым)

Цель Sprint 42:
  - Все компилируется: ✅
  - Все тесты Cmi5: ✅
  - TestFlight готов: ✅
```

## 🔧 Полезные команды:

```bash
# Проверка только Cmi5 файлов
find LMS/Features/Cmi5 -name "*.swift" -exec swiftc -parse {} \;

# Запуск только Cmi5 тестов
xcodebuild test -scheme LMS \
  -only-testing:LMSTests/Cmi5 \
  -destination 'platform=iOS Simulator,name=iPhone 16'

# Временное игнорирование Notifications
mv LMS/Features/Notifications LMS/Features/Notifications.disabled
```

## 💡 Важные решения:

1. **НЕ тратить больше 2 часов** на исправление Notifications
2. **Приоритет - работающий Cmi5**, даже если CI красный
3. **TestFlight может содержать заглушки** для Notifications

## 📝 Для документирования:

В начале Sprint 42 обязательно задокументировать:
- Какие части кода временно отключены
- Какие тесты пропущены
- План восстановления в Sprint 43

---

**ПОМНИТЕ**: Цель Sprint 42 - завершить Cmi5, а не исправить все проблемы проекта! 