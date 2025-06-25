# Онбординг в MVP (Версия 1.0)

## 🎯 Цели онбординга в первой версии

1. **Быстрая адаптация** новых сотрудников
2. **Стандартизация** процесса введения в должность
3. **Снижение нагрузки** на HR и руководителей
4. **Отслеживание прогресса** новичков

## 📱 Функционал iOS приложения

### Первый запуск для нового сотрудника

```swift
// Экран приветствия
- Персональное приветствие с именем
- Краткая информация о компании
- Видео-обращение CEO (опционально)
```

### Структура онбординга

#### 1. **Чек-листы по периодам**

**Первый день:**
- [ ] Получить пропуск
- [ ] Настроить рабочее место
- [ ] Познакомиться с командой
- [ ] Прочитать правила внутреннего распорядка (PDF)
- [ ] Пройти инструктаж по технике безопасности

**Первая неделя:**
- [ ] Изучить организационную структуру (PDF)
- [ ] Пройти вводный курс о продуктах компании
- [ ] Настроить корпоративную почту
- [ ] Встретиться с наставником
- [ ] Изучить основные процессы отдела (PDF)

**Первый месяц:**
- [ ] Пройти обязательные курсы
- [ ] Выполнить первое тестовое задание
- [ ] Получить обратную связь от руководителя
- [ ] Заполнить анкету адаптации

#### 2. **Обязательные материалы**

- 📄 Корпоративная культура и ценности (PDF)
- 📄 Политика безопасности (PDF)
- 📄 Должностная инструкция (PDF)
- 📄 Регламенты и процедуры (PDF)
- 📹 Видео о компании (опционально)

#### 3. **Интерактивные элементы**

- **Progress Bar** - визуализация прогресса онбординга
- **Achievements** - награды за выполнение этапов
- **Countdown** - обратный отсчет до дедлайнов
- **Quick Actions** - быстрые действия (позвонить HR, написать наставнику)

### UI/UX особенности

```swift
// Главный экран онбординга
TabView {
    ChecklistView()      // Текущие задачи
    MaterialsView()      // Учебные материалы
    ProgressView()       // Общий прогресс
    ContactsView()       // Важные контакты
}
```

## 💼 Функционал Web-админки

### Настройка программ онбординга

#### 1. **Шаблоны по должностям**

```javascript
// Предустановленные шаблоны
- Разработчик
- Менеджер по продажам
- Бухгалтер
- Маркетолог
- Универсальный шаблон
```

#### 2. **Конструктор онбординга**

- Drag & Drop для создания чек-листов
- Установка сроков для каждого этапа
- Привязка PDF-материалов к задачам
- Назначение ответственных
- Настройка уведомлений

#### 3. **Автоматизация**

```yaml
Триггеры:
  - Создание нового сотрудника → Запуск онбординга
  - Выбор должности → Применение шаблона
  - Истечение срока задачи → Push-уведомление
  - Завершение этапа → Уведомление HR
```

#### 4. **Мониторинг и отчеты**

**Dashboard HR:**
- Количество новых сотрудников
- Средний прогресс по онбордингу
- Проблемные зоны (незавершенные задачи)
- Время прохождения этапов

**Индивидуальные отчеты:**
- Прогресс конкретного сотрудника
- История выполнения задач
- Результаты тестов
- Обратная связь

## 🔧 Техническая реализация

### iOS приложение

```swift
// Core Data модель
@Entity
class OnboardingTask {
    @Attribute var id: UUID
    @Attribute var title: String
    @Attribute var deadline: Date
    @Attribute var isCompleted: Bool
    @Attribute var category: TaskCategory
    @Relationship var materials: [Material]
}

// Push-уведомления
func scheduleOnboardingReminder(task: OnboardingTask) {
    let content = UNMutableNotificationContent()
    content.title = "Напоминание об онбординге"
    content.body = task.title
    content.sound = .default
    
    let trigger = UNTimeIntervalNotificationTrigger(
        timeInterval: task.deadline.timeIntervalSinceNow,
        repeats: false
    )
    // ...
}
```

### Backend API

```python
# FastAPI endpoints
@app.post("/api/v1/onboarding/start")
async def start_onboarding(employee_id: int, template_id: int):
    """Запуск программы онбординга для нового сотрудника"""
    
@app.get("/api/v1/onboarding/{employee_id}/progress")
async def get_onboarding_progress(employee_id: int):
    """Получение прогресса онбординга"""
    
@app.put("/api/v1/onboarding/task/{task_id}/complete")
async def complete_task(task_id: int):
    """Отметка задачи как выполненной"""
```

### База данных

```sql
-- Основные таблицы
CREATE TABLE onboarding_templates (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    position_id INTEGER,
    created_at TIMESTAMP
);

CREATE TABLE onboarding_tasks (
    id SERIAL PRIMARY KEY,
    template_id INTEGER REFERENCES onboarding_templates(id),
    title VARCHAR(255),
    description TEXT,
    day_offset INTEGER, -- День от начала работы
    required BOOLEAN DEFAULT true
);

CREATE TABLE employee_onboarding (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER,
    template_id INTEGER,
    started_at TIMESTAMP,
    completed_at TIMESTAMP
);
```

## 📊 Метрики успеха онбординга

1. **Completion Rate** - % завершенных программ онбординга
2. **Time to Productivity** - время до полной продуктивности
3. **Retention Rate** - % сотрудников, прошедших испытательный срок
4. **Satisfaction Score** - оценка программы новыми сотрудниками
5. **Task Completion Time** - среднее время выполнения задач

## 🚀 Быстрый старт

### Для HR:
1. Создать шаблон онбординга для должности
2. Загрузить необходимые PDF-материалы
3. Настроить чек-листы и сроки
4. Активировать автоматический запуск

### Для нового сотрудника:
1. Скачать iOS приложение
2. Войти с корпоративными данными
3. Начать выполнение задач первого дня
4. Отслеживать прогресс в приложении 