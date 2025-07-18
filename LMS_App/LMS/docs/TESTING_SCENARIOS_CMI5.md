# 🎯 Сценарии тестирования Cmi5 для TestFlight

## 📋 Сценарий 1: Базовый импорт и запуск Cmi5 пакета

### Контекст
> **Важно**: В текущей версии Cmi5 контент доступен только через уроки курсов. Для тестирования необходимо, чтобы администратор предварительно создал курс с Cmi5 уроком.

### Предусловия
- Вы авторизованы как студент или преподаватель
- Существует курс с хотя бы одним Cmi5 уроком
- У вас есть доступ к этому курсу

### Шаги
1. **Найти курс с Cmi5 контентом**
   - Перейти в раздел "Курсы" (нижняя панель)
   - Найти курс с пометкой о наличии интерактивного контента
   - Открыть курс

2. **Перейти к Cmi5 уроку**
   - В списке модулей найти урок с иконкой куба (🎲)
   - Нажать на урок для просмотра

3. **Запустить Cmi5 активность**
   - На экране урока нажать кнопку "Начать интерактивный урок"
   - Дождаться загрузки Cmi5 Player

4. **Пройти контент**
   - Взаимодействовать с контентом согласно инструкциям
   - Обратить внимание на индикатор прогресса
   - Завершить активность

### Ожидаемые результаты
- ✅ Cmi5 Player загружается без ошибок
- ✅ Контент отображается корректно
- ✅ Прогресс сохраняется при выходе
- ✅ После завершения урок отмечается как пройденный

### Что проверить
- [ ] Время загрузки контента (должно быть < 5 секунд)
- [ ] Плавность навигации внутри контента
- [ ] Корректность отображения мультимедиа
- [ ] Сохранение прогресса при сворачивании приложения

## 🎯 Тестовый сценарий #2: Офлайн режим

### Предусловия:
- Cmi5 контент уже импортирован
- Устройство подключено к интернету

### Шаги:
1. Запустить Cmi5 активность
2. Начать прохождение курса
3. Включить "Авиарежим" на устройстве
4. Продолжить взаимодействие с контентом
5. Проверить индикатор офлайн режима
6. Завершить активность
7. Выключить "Авиарежим"
8. Проверить синхронизацию

### Ожидаемый результат:
- ✅ Контент продолжает работать офлайн
- ✅ Появляется индикатор офлайн режима
- ✅ Statements сохраняются локально
- ✅ При восстановлении сети происходит синхронизация
- ✅ Счетчик несинхронизированных statements обновляется

## 🎯 Тестовый сценарий #3: Прерывание и возобновление

### Предусловия:
- Cmi5 контент запущен

### Шаги:
1. Начать прохождение курса
2. Пройти 50% контента
3. Свернуть приложение (Home button)
4. Подождать 30 секунд
5. Вернуться в приложение
6. Проверить состояние плеера
7. Продолжить с места остановки
8. Завершить курс

### Ожидаемый результат:
- ✅ Прогресс сохраняется при сворачивании
- ✅ Можно продолжить с места остановки
- ✅ Отправляется resumed statement
- ✅ Финальный прогресс корректно записан

## 🎯 Тестовый сценарий #4: Аналитика и отчеты

### Предусловия:
- Несколько пользователей прошли Cmi5 курсы
- Есть данные за последнюю неделю

### Шаги:
1. Перейти в "Analytics Dashboard"
2. Выбрать временной диапазон "Last 7 days"
3. Проверить общие метрики
4. Переключиться на "Learning Time"
5. Проверить график времени обучения
6. Перейти к "Performance Metrics"
7. Экспортировать отчет в PDF

### Ожидаемый результат:
- ✅ Отображаются корректные метрики
- ✅ Графики интерактивные
- ✅ Данные соответствуют реальной активности
- ✅ PDF отчет генерируется и сохраняется

## 🎯 Тестовый сценарий #5: Невалидный контент

### Предусловия:
- Подготовлен невалидный Cmi5 пакет (без cmi5.xml)

### Шаги:
1. Попытаться импортировать невалидный пакет
2. Проверить сообщение об ошибке
3. Попытаться загрузить не-zip файл
4. Проверить валидацию
5. Загрузить пакет > 100MB
6. Проверить ограничения

### Ожидаемый результат:
- ✅ Показывается понятное сообщение об ошибке
- ✅ Указывается причина невалидности
- ✅ Система не крашится
- ✅ Можно попробовать другой файл

## 🎯 Тестовый сценарий #6: Множественные AU

### Предусловия:
- Cmi5 пакет с 5+ AU

### Шаги:
1. Импортировать пакет с несколькими AU
2. Пройти первую AU полностью
3. Проверить статус первой AU
4. Начать вторую AU
5. Пройти 50% и выйти
6. Начать третью AU
7. Вернуться ко второй AU
8. Проверить сохранение прогресса

### Ожидаемый результат:
- ✅ Каждая AU имеет независимый прогресс
- ✅ Можно переключаться между AU
- ✅ Прогресс сохраняется для каждой AU
- ✅ Статусы отображаются корректно

## 🎯 Тестовый сценарий #7: Производительность

### Предусловия:
- 1000+ xAPI statements в базе
- Cmi5 контент с тяжелой графикой

### Шаги:
1. Открыть Analytics Dashboard
2. Загрузить данные за месяц
3. Измерить время загрузки
4. Запустить тяжелый Cmi5 контент
5. Проверить FPS при прокрутке
6. Переключаться между вкладками
7. Проверить использование памяти

### Ожидаемый результат:
- ✅ Dashboard загружается < 3 сек
- ✅ Прокрутка плавная (60 FPS)
- ✅ Нет утечек памяти
- ✅ Приложение не крашится

## 🎯 Тестовый сценарий #8: Граничные случаи

### Шаги:
1. **Двойной запуск**: Быстро нажать "Launch" два раза
2. **Длинные названия**: AU с названием 200+ символов
3. **Спецсимволы**: AU с emoji и unicode в названии
4. **Нулевой прогресс**: Запустить и сразу закрыть
5. **Максимальный score**: Получить 100% результат
6. **Отрицательный score**: Проверить обработку
7. **Будущая дата**: Statement с датой из будущего

### Ожидаемый результат:
- ✅ Система корректно обрабатывает все случаи
- ✅ Нет дублирования statements
- ✅ UI не ломается от длинных строк
- ✅ Валидация работает корректно

## 📋 Чек-лист проверки xAPI Statements

### Launched Statement:
- [ ] Содержит корректный verb: "launched"
- [ ] Actor соответствует текущему пользователю
- [ ] Object ссылается на правильную AU
- [ ] Context содержит sessionId
- [ ] Timestamp корректный

### Initialized Statement:
- [ ] Отправляется после launched
- [ ] Содержит те же actor и object
- [ ] SessionId совпадает

### Terminated Statement:
- [ ] Отправляется при закрытии
- [ ] Содержит duration
- [ ] Result если применимо

### Completed Statement:
- [ ] Отправляется при 100% прохождении
- [ ] Содержит score если есть
- [ ] Success = true

## 🔍 Инструменты для тестирования

### Подготовка тестовых данных:
```bash
# Генерация тестовых statements
./scripts/generate-test-statements.sh 1000

# Создание тестового Cmi5 пакета
./scripts/create-test-cmi5-package.sh
```

### Мониторинг:
- Xcode Console для просмотра логов
- Charles Proxy для отслеживания сетевых запросов
- Instruments для профилирования производительности

## 📊 Метрики успешности тестирования

### Покрытие:
- [ ] 100% критических сценариев
- [ ] 80%+ edge cases
- [ ] Все типы statements

### Производительность:
- [ ] Импорт пакета < 5 сек
- [ ] Запуск плеера < 2 сек
- [ ] Синхронизация < 1 сек на 100 statements

### Стабильность:
- [ ] 0 крашей
- [ ] 0 потерь данных
- [ ] 100% успешная синхронизация 