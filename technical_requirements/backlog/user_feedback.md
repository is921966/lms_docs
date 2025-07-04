# User Feedback Log

## Формат записи feedback

```markdown
### [Дата] - [Источник] - [Пользователь/Роль]
**Тема:** [Краткое описание]
**Приоритет:** High/Medium/Low
**Категория:** UX | Функциональность | Производительность | Баг | Запрос фичи

**Описание:**
[Детальное описание обратной связи]

**Предложенное решение:**
[Если пользователь предложил решение]

**Статус:** New | In Review | Planned | Implemented | Rejected
**Связанные задачи:** [JIRA/GitHub issues]
```

---

## Feedback Log

### 2025-03-15 - Пилотное тестирование - HR Manager (Компания А)
**Тема:** Сложность создания компетенций
**Приоритет:** Medium
**Категория:** UX

**Описание:**
При создании компетенций приходится много кликать для добавления уровней. Хотелось бы иметь возможность быстро создать стандартные 5 уровней одной кнопкой.

**Предложенное решение:**
Добавить кнопку "Создать стандартные уровни (1-5)" которая автоматически создаст 5 уровней с шаблонными описаниями.

**Статус:** Planned
**Связанные задачи:** UI-234

---

### 2025-03-18 - User Interview - Сотрудник отдела продаж
**Тема:** Мобильный доступ
**Приоритет:** High
**Категория:** Запрос фичи

**Описание:**
Часто нахожусь в командировках и хочу проходить курсы с телефона. Сейчас интерфейс не адаптирован под мобильные устройства, приходится постоянно масштабировать.

**Предложенное решение:**
Сделать адаптивную верстку или мобильное приложение.

**Статус:** Planned (v1.2)
**Связанные задачи:** MOBILE-001

---

### 2025-03-20 - Support Ticket - IT Admin
**Тема:** Ошибка синхронизации с Active Directory
**Приоритет:** High
**Категория:** Баг

**Описание:**
При первичной синхронизации пользователей из AD не подтягиваются пользователи из отключенных OU (Organizational Units), хотя учетные записи активны.

**Предложенное решение:**
Добавить опцию включения/исключения отключенных OU при синхронизации.

**Статус:** In Review
**Связанные задачи:** BUG-156

---

### 2025-03-22 - Фокус-группа - Руководители отделов
**Тема:** Дашборд для руководителя
**Приоритет:** Medium
**Категория:** Функциональность

**Описание:**
Хотим видеть на одном экране:
- Кто из сотрудников отстает по обучению
- Средний прогресс по отделу
- Сравнение с другими отделами
- Топ-3 проблемных курса

**Предложенное решение:**
Создать отдельный дашборд "Обучение моей команды" с виджетами.

**Статус:** New
**Связанные задачи:** -

---

### 2025-03-25 - Email - HR Director
**Тема:** Экспорт отчетов
**Приоритет:** High
**Категория:** Запрос фичи

**Описание:**
Необходима возможность выгружать отчеты в Excel с графиками для презентаций руководству. Сейчас приходится делать скриншоты и вставлять в презентацию.

**Предложенное решение:**
Добавить кнопку "Экспорт в Excel" с опциями:
- Включить графики
- Выбрать период
- Выбрать метрики

**Статус:** Implemented (v1.0)
**Связанные задачи:** REPORT-089

---

### 2025-03-28 - Slack - Внутренний тренер
**Тема:** Версионность курсов
**Приоритет:** Low
**Категория:** Запрос фичи

**Описание:**
Когда обновляю курс, старая версия теряется. Хотелось бы иметь историю изменений и возможность откатиться к предыдущей версии.

**Предложенное решение:**
Система версий как в Google Docs или Git.

**Статус:** New
**Связанные задачи:** -

---

## Статистика feedback

### По категориям:
- UX: 15%
- Функциональность: 35%
- Производительность: 10%
- Баги: 25%
- Запросы фич: 15%

### По приоритетам:
- High: 40%
- Medium: 45%
- Low: 15%

### По источникам:
- Пилотное тестирование: 30%
- Support tickets: 25%
- User interviews: 20%
- Фокус-группы: 15%
- Прямая связь: 10%

## Топ-5 запрашиваемых функций

1. **Мобильное приложение** (упоминаний: 23)
2. **Геймификация** (упоминаний: 18)
3. **Интеграция с Teams/Slack** (упоминаний: 15)
4. **AI-рекомендации курсов** (упоминаний: 12)
5. **Офлайн режим** (упоминаний: 10)

## Основные pain points

1. **Неудобство на мобильных устройствах**
   - Влияет на 60% пользователей
   - Снижает engagement на 40%

2. **Отсутствие push-уведомлений**
   - Пользователи забывают про назначенные курсы
   - Просят напоминания

3. **Ограниченная аналитика**
   - Руководители хотят больше insights
   - HR просит predictive analytics

4. **Сложность первоначальной настройки**
   - Создание компетенций занимает много времени
   - Нет шаблонов для быстрого старта

## Action Items

### Immediate (Sprint 13-14):
- [ ] Исправить баг синхронизации с Active Directory
- [ ] Добавить шаблоны создания компетенций
- [ ] Улучшить мобильную версию (responsive)

### Short-term (v1.1):
- [ ] Реализовать push-уведомления
- [ ] Создать дашборд для руководителей
- [ ] Добавить bulk операции

### Long-term (v2.0+):
- [ ] Разработать нативные мобильные приложения
- [ ] Внедрить базовую геймификацию
- [ ] Добавить AI-рекомендации 