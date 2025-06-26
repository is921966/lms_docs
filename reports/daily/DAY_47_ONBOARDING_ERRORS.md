# День 47: Ошибки компиляции модуля Onboarding

**Дата**: 27 января 2025
**Статус**: Исправление ошибок компиляции

## 🔴 Текущая ситуация

После реализации модуля Onboarding обнаружено множество ошибок компиляции. Согласно методологии v1.7.0, push в GitHub запрещен до успешной локальной компиляции.

## 📋 Основные проблемы

### 1. OnboardingTemplate структура
- `taskTemplates` отсутствует в `OnboardingTemplateStage`
- `name` отсутствует в `OnboardingTemplate` (есть `title`)
- `durationInDays` отсутствует (есть `duration`)

### 2. Дублирование типов
- `StatCard` дублируется в `ProfileView` и `OnboardingDashboard`
- `MetricCard` дублируется в `PositionDetailView` и `OnboardingReportsView`

### 3. Несоответствие типов
- UserResponse.id это String, а нужен UUID
- position и department в UserResponse это опциональные String?
- roles это массив, а не строка

### 4. Отсутствующие компоненты
- `CreateProgramViewModel` не определен
- Неправильные параметры в OnboardingTask конструкторе

### 5. CreateProgramFromTemplateView
- NavigationLink в OnboardingDashboard не передает template
- filteredEmployees это computed property, нельзя присваивать
- Form инициализатор требует FormStyleConfiguration

## 🛠️ План исправления

1. **Исправить структуру OnboardingTemplate**
   - Переименовать taskTemplates в tasks
   - Использовать title вместо name
   - Использовать duration вместо durationInDays

2. **Устранить дублирование**
   - Переименовать StatCard в разных файлах
   - Переименовать MetricCard в разных файлах

3. **Исправить типы**
   - Конвертировать String ID в UUID
   - Обработать опциональные поля
   - Правильно работать с массивом roles

4. **Упростить CreateProgramFromTemplateView**
   - Убрать лишнюю сложность
   - Исправить computed properties
   - Обновить вызовы методов

## ⏱️ Затраченное время
- Реализация модуля: ~2 часа
- Обнаружение ошибок: ~30 минут
- Начало исправления: в процессе

## 📊 Статус MVP
- Модули 1-7: ✅ Полностью готовы
- Модуль 8 (Onboarding): 🔴 Ошибки компиляции
- Общий прогресс: ~95%

## 🎯 Следующие шаги
1. Систематически исправить все ошибки компиляции
2. Запустить локальную сборку
3. После успешной сборки - push в GitHub
4. Проверить CI/CD pipeline
5. Развернуть на TestFlight

## 💡 Уроки
- Важность регулярного запуска компиляции во время разработки
- Необходимость проверки структур данных перед использованием
- Польза от правила обязательной локальной компиляции 