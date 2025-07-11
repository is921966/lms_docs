# Sprint 42: Стартовый чек-лист

**Дата начала**: 20 января 2025 (Понедельник)  
**Критический документ**: ОБЯЗАТЕЛЬНО выполнить ВСЕ пункты перед началом работы

## 🔴 КРИТИЧЕСКОЕ НАПОМИНАНИЕ

**Sprint 41 потерял 80% времени из-за отклонения от плана!**  
Sprint 42 - последний шанс завершить Cmi5. БЕЗ ОТКЛОНЕНИЙ!

## ✅ Чек-лист на утро понедельника (09:00)

### 1. Проверка окружения
```bash
cd /Users/ishirokov/lms_docs
git checkout feature/cmi5-support
git pull origin feature/cmi5-support
```

### 2. Проверка плана
```bash
# Прочитать и запомнить
cat reports/sprints/SPRINT_42_PLAN.md
cat reports/sprints/SPRINT_42_RECOVERY_GUIDE.md
```

### 3. Создание записи дня в БД
```bash
./scripts/report.sh start-day
# или если не работает:
python3 scripts/project-time.py set-day 188
```

### 4. Проверка текущего состояния Cmi5
```bash
cd LMS_App/LMS
# Посмотреть что уже есть
ls -la LMS/Features/Cmi5/
```

### 5. План на День 1 (20 января)
**ТОЛЬКО xAPI Statement Tracking!**

Файлы для создания:
- [ ] `LMS/Features/Cmi5/Services/StatementProcessor.swift`
- [ ] `LMS/Features/Cmi5/Services/StatementQueue.swift`
- [ ] `LMS/Features/Cmi5/Services/StatementValidator.swift`
- [ ] `LMSTests/Features/Cmi5/Services/StatementProcessorTests.swift`
- [ ] `LMSTests/Features/Cmi5/Services/StatementQueueTests.swift`

Функциональность:
- [ ] Statement validation
- [ ] Batch processing
- [ ] Retry механизм
- [ ] Real-time UI updates
- [ ] Progress integration

## 📋 Ежедневная рутина

### Утро (09:00)
1. Прочитать план дня
2. НЕ отклоняться от плана
3. Создать DAY_XXX_PLAN.md

### День (09:30-17:00)
1. Писать код по плану
2. Писать тесты для каждой функции
3. Коммитить каждые 2 часа

### Вечер (17:00-18:00)
1. Создать DAY_XXX_SUMMARY.md
2. Обновить SPRINT_42_PROGRESS.md
3. Commit & Push

## ⚠️ Красные флаги

Если вы думаете о:
- ❌ Notifications
- ❌ Новых фичах
- ❌ Изменении плана
- ❌ "Быстрых улучшениях"

**ОСТАНОВИТЕСЬ!** Вернитесь к плану Sprint 42.

## 🎯 Цели недели

1. **Понедельник**: xAPI tracking ✅
2. **Вторник**: Офлайн поддержка ✅
3. **Среда**: Аналитика ✅
4. **Четверг**: Оптимизация ✅
5. **Пятница**: TestFlight 2.0.0 ✅

## 🔧 Полезные команды

```bash
# Быстрый тест Cmi5
./scripts/test-cmi5-quick.sh

# Проверка компиляции
xcodebuild -scheme LMS -destination 'platform=iOS Simulator,name=iPhone 16' build

# Создание отчета дня
./scripts/report.sh daily-create

# Проверка прогресса
grep "TODO\|FIXME" LMS/Features/Cmi5/**/*.swift
```

## 📞 Эскалация

Если возникают вопросы о приоритетах:
1. Смотрите SPRINT_42_PLAN.md
2. Смотрите SPRINT_42_RECOVERY_GUIDE.md
3. Фокус ТОЛЬКО на Cmi5

## 💭 Мантра Sprint 42

> "План священен. Cmi5 - единственная цель. TestFlight 24 января."

Повторять каждое утро перед началом работы.

---

**ВАЖНО**: Распечатайте этот чек-лист или держите открытым весь день!  
**КРИТИЧНО**: НЕ НАЧИНАЙТЕ РАБОТУ без выполнения ВСЕХ пунктов!

*Создан: 17 января 2025, для использования 20 января 2025* 