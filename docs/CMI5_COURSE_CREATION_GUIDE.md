# Руководство по созданию Cmi5 курсов для LMS

## 📚 Содержание
1. [Введение](#введение)
2. [Структура Cmi5 пакета](#структура-cmi5-пакета)
3. [Создание манифеста](#создание-манифеста)
4. [Разработка контента](#разработка-контента)
5. [Интеграция xAPI](#интеграция-xapi)
6. [Тестирование](#тестирование)
7. [Упаковка и развертывание](#упаковка-и-развертывание)
8. [Лучшие практики](#лучшие-практики)

## 🎯 Введение

Cmi5 (Computer Managed Instruction, версия 5) - это современный стандарт для создания и доставки образовательного контента. Он основан на xAPI и обеспечивает:

- Детальное отслеживание прогресса обучения
- Поддержку офлайн режима
- Гибкую структуру курсов
- Богатую аналитику

## 📁 Структура Cmi5 пакета

Типичный Cmi5 пакет имеет следующую структуру:

```
course-package/
├── cmi5.xml              # Манифест курса (обязательный)
├── package.json          # Метаданные пакета
├── content/              # HTML контент
│   ├── module1.html
│   ├── module2.html
│   └── ...
├── assets/               # Ресурсы (CSS, JS, изображения)
│   ├── styles.css
│   ├── cmi5-handler.js
│   └── images/
├── assessments/          # Тесты и оценки
│   ├── test1.html
│   └── test2.html
└── media/               # Видео и аудио файлы
    ├── intro.mp4
    └── audio/
```

## 📋 Создание манифеста

### Базовая структура cmi5.xml:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<courseStructure xmlns="https://w3id.org/xapi/profiles/cmi5/v1/CourseStructure.xsd">
    <course id="course-001">
        <title>
            <langstring lang="ru">Название курса</langstring>
            <langstring lang="en">Course Title</langstring>
        </title>
        <description>
            <langstring lang="ru">Описание курса</langstring>
        </description>
        
        <!-- Блоки курса -->
        <block id="block-001">
            <title>
                <langstring lang="ru">Модуль 1: Введение</langstring>
            </title>
            
            <!-- Активности (AU - Assignable Units) -->
            <au id="au-001" launchMethod="OwnWindow" moveOn="Passed">
                <title>
                    <langstring lang="ru">Урок 1.1: Основы</langstring>
                </title>
                <url>content/module1_lesson1.html</url>
                <activityType>http://adlnet.gov/expapi/activities/lesson</activityType>
                <launchParameters>?mode=normal</launchParameters>
            </au>
            
            <au id="au-002" launchMethod="OwnWindow" moveOn="Completed">
                <title>
                    <langstring lang="ru">Тест: Проверка знаний</langstring>
                </title>
                <url>assessments/test1.html</url>
                <activityType>http://adlnet.gov/expapi/activities/assessment</activityType>
                <masteryScore>0.8</masteryScore>
            </au>
        </block>
    </course>
</courseStructure>
```

### Важные атрибуты:

- **launchMethod**: `OwnWindow` (новое окно) или `AnyWindow` (любое окно)
- **moveOn**: условие перехода к следующей активности
  - `Passed` - после успешного прохождения
  - `Completed` - после завершения
  - `CompletedAndPassed` - после завершения и успеха
  - `CompletedOrPassed` - после завершения или успеха
  - `NotApplicable` - без ограничений
- **masteryScore**: минимальный балл для успешного прохождения (0-1)

## 🎨 Разработка контента

### HTML шаблон для активности:

```html
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Урок 1: Основы</title>
    <link rel="stylesheet" href="../assets/styles.css">
    <script src="../assets/cmi5-handler.js"></script>
</head>
<body>
    <div class="lesson-container">
        <header>
            <h1>Урок 1: Основы</h1>
            <div class="progress-bar">
                <div class="progress" id="progress"></div>
            </div>
        </header>
        
        <main>
            <section class="content" data-section="1">
                <h2>Введение</h2>
                <p>Содержание урока...</p>
                <button class="next-btn" onclick="nextSection()">Далее</button>
            </section>
            
            <section class="content hidden" data-section="2">
                <h2>Основные концепции</h2>
                <p>Детальное объяснение...</p>
                <button class="next-btn" onclick="nextSection()">Далее</button>
            </section>
            
            <section class="content hidden" data-section="3">
                <h2>Заключение</h2>
                <p>Итоги урока...</p>
                <button class="complete-btn" onclick="completeLesson()">Завершить урок</button>
            </section>
        </main>
    </div>
</body>
</html>
```

### CSS стили (styles.css):

```css
:root {
    --primary-color: #007AFF;
    --success-color: #34C759;
    --background: #F2F2F7;
    --text-primary: #000000;
    --text-secondary: #8E8E93;
}

body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    margin: 0;
    padding: 0;
    background: var(--background);
    color: var(--text-primary);
}

.lesson-container {
    max-width: 800px;
    margin: 0 auto;
    padding: 20px;
}

.progress-bar {
    width: 100%;
    height: 4px;
    background: #E5E5EA;
    border-radius: 2px;
    overflow: hidden;
    margin: 20px 0;
}

.progress {
    height: 100%;
    background: var(--primary-color);
    transition: width 0.3s ease;
    width: 0%;
}

.content {
    background: white;
    padding: 30px;
    border-radius: 12px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    margin-bottom: 20px;
}

.hidden {
    display: none;
}

button {
    background: var(--primary-color);
    color: white;
    border: none;
    padding: 12px 24px;
    border-radius: 8px;
    font-size: 16px;
    cursor: pointer;
    transition: all 0.2s;
}

button:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(0,122,255,0.3);
}

.complete-btn {
    background: var(--success-color);
}
```

## 🔗 Интеграция xAPI

### JavaScript обработчик (cmi5-handler.js):

```javascript
// Глобальные переменные
let cmi5Controller;
let currentSection = 1;
let totalSections = 3;

// Инициализация при загрузке
window.onload = function() {
    // Проверяем, запущены ли мы через cmi5
    if (window.cmi5) {
        initializeCmi5();
    } else {
        console.log('Running in standalone mode');
        // Можно добавить fallback для автономной работы
    }
};

// Инициализация cmi5
function initializeCmi5() {
    cmi5Controller = window.cmi5;
    
    cmi5Controller.initialize().then(function() {
        // Отправляем statement "initialized"
        sendStatement('initialized');
        
        // Загружаем сохраненный прогресс
        loadProgress();
    }).catch(function(error) {
        console.error('Cmi5 initialization failed:', error);
    });
}

// Отправка xAPI statements
function sendStatement(verb, result = null) {
    if (!cmi5Controller) return;
    
    const statement = {
        verb: {
            id: `http://adlnet.gov/expapi/verbs/${verb}`,
            display: { "en-US": verb }
        },
        object: {
            id: cmi5Controller.getActivityId(),
            definition: {
                name: { "ru": document.title },
                type: "http://adlnet.gov/expapi/activities/lesson"
            }
        }
    };
    
    if (result) {
        statement.result = result;
    }
    
    cmi5Controller.sendStatement(statement);
}

// Переход к следующей секции
function nextSection() {
    if (currentSection < totalSections) {
        // Скрываем текущую секцию
        document.querySelector(`[data-section="${currentSection}"]`).classList.add('hidden');
        
        // Показываем следующую
        currentSection++;
        document.querySelector(`[data-section="${currentSection}"]`).classList.remove('hidden');
        
        // Обновляем прогресс
        updateProgress();
        
        // Отправляем statement о прогрессе
        sendStatement('progressed', {
            extensions: {
                "http://example.com/progress": currentSection / totalSections
            }
        });
    }
}

// Обновление прогресс-бара
function updateProgress() {
    const progress = (currentSection / totalSections) * 100;
    document.getElementById('progress').style.width = progress + '%';
}

// Завершение урока
function completeLesson() {
    // Отправляем statement "completed"
    sendStatement('completed', {
        completion: true,
        duration: "PT5M", // ISO 8601 duration
        success: true
    });
    
    // Завершаем сессию cmi5
    if (cmi5Controller) {
        cmi5Controller.terminate();
    }
    
    // Показываем сообщение об успехе
    alert('Урок успешно завершен!');
}

// Загрузка сохраненного прогресса
function loadProgress() {
    // Здесь можно загрузить прогресс из LRS
    // Для примера просто начинаем с первой секции
    updateProgress();
}
```

## 🧪 Тестирование

### Создание интерактивного теста:

```html
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>Тест: Проверка знаний</title>
    <link rel="stylesheet" href="../assets/styles.css">
    <script src="../assets/cmi5-handler.js"></script>
</head>
<body>
    <div class="test-container">
        <h1>Тест: Проверка знаний</h1>
        
        <div id="question-container">
            <!-- Вопросы будут добавлены динамически -->
        </div>
        
        <button id="submit-btn" onclick="submitTest()" style="display:none;">
            Завершить тест
        </button>
        
        <div id="results" class="hidden">
            <h2>Результаты теста</h2>
            <p>Ваш результат: <span id="score"></span>%</p>
        </div>
    </div>
    
    <script>
        const questions = [
            {
                id: 1,
                text: "Что такое Cmi5?",
                options: [
                    "Стандарт для e-learning",
                    "Язык программирования",
                    "База данных",
                    "Операционная система"
                ],
                correct: 0
            },
            {
                id: 2,
                text: "Какой протокол использует Cmi5?",
                options: [
                    "HTTP",
                    "FTP",
                    "xAPI",
                    "SMTP"
                ],
                correct: 2
            }
        ];
        
        let currentQuestion = 0;
        let answers = [];
        
        function showQuestion(index) {
            const q = questions[index];
            const container = document.getElementById('question-container');
            
            container.innerHTML = `
                <div class="question">
                    <h3>Вопрос ${index + 1} из ${questions.length}</h3>
                    <p>${q.text}</p>
                    <div class="options">
                        ${q.options.map((opt, i) => `
                            <label>
                                <input type="radio" name="q${q.id}" value="${i}">
                                ${opt}
                            </label>
                        `).join('')}
                    </div>
                    <button onclick="nextQuestion()">Далее</button>
                </div>
            `;
        }
        
        function nextQuestion() {
            // Сохраняем ответ
            const selected = document.querySelector(`input[name="q${questions[currentQuestion].id}"]:checked`);
            if (selected) {
                answers.push(parseInt(selected.value));
            }
            
            currentQuestion++;
            
            if (currentQuestion < questions.length) {
                showQuestion(currentQuestion);
            } else {
                document.getElementById('question-container').style.display = 'none';
                document.getElementById('submit-btn').style.display = 'block';
            }
        }
        
        function submitTest() {
            // Подсчет результатов
            let correct = 0;
            answers.forEach((answer, index) => {
                if (answer === questions[index].correct) {
                    correct++;
                }
            });
            
            const score = Math.round((correct / questions.length) * 100);
            
            // Показываем результаты
            document.getElementById('score').textContent = score;
            document.getElementById('submit-btn').style.display = 'none';
            document.getElementById('results').classList.remove('hidden');
            
            // Отправляем результат в xAPI
            if (window.cmi5Controller) {
                const passed = score >= 80; // 80% для прохождения
                
                window.cmi5Controller.sendStatement({
                    verb: {
                        id: passed ? "http://adlnet.gov/expapi/verbs/passed" : "http://adlnet.gov/expapi/verbs/failed",
                        display: { "en-US": passed ? "passed" : "failed" }
                    },
                    result: {
                        score: {
                            scaled: score / 100,
                            raw: correct,
                            max: questions.length
                        },
                        success: passed,
                        completion: true
                    }
                });
                
                window.cmi5Controller.terminate();
            }
        }
        
        // Начинаем тест
        showQuestion(0);
    </script>
</body>
</html>
```

## 📦 Упаковка и развертывание

### Автоматизация создания пакета:

```bash
#!/bin/bash
# create-cmi5-package.sh

COURSE_NAME=$1
VERSION=${2:-1.0.0}

# Создаем структуру
mkdir -p "$COURSE_NAME"/{content,assets,assessments,media}

# Копируем шаблоны
cp templates/cmi5_template.xml "$COURSE_NAME/cmi5.xml"
cp templates/styles.css "$COURSE_NAME/assets/"
cp templates/cmi5-handler.js "$COURSE_NAME/assets/"

# Создаем package.json
cat > "$COURSE_NAME/package.json" << EOF
{
  "name": "$COURSE_NAME",
  "version": "$VERSION",
  "description": "Cmi5 course package",
  "main": "cmi5.xml",
  "author": "Your Organization",
  "license": "MIT"
}
EOF

# Создаем README
cat > "$COURSE_NAME/README.md" << EOF
# $COURSE_NAME

Cmi5 курс версии $VERSION

## Установка
1. Импортируйте ZIP файл в LMS
2. Назначьте пользователям
3. Отслеживайте прогресс через xAPI

## Структура
- /content - HTML контент уроков
- /assets - Стили и скрипты
- /assessments - Тесты
- /media - Медиафайлы
EOF

echo "✅ Структура курса создана в папке $COURSE_NAME"
```

### Создание ZIP архива:

```bash
# Упаковка курса
cd course-folder
zip -r ../my-course-v1.0.zip . -x "*.DS_Store" -x "__MACOSX/*"
```

## ✅ Лучшие практики

### 1. Оптимизация производительности
- Минимизируйте размер изображений
- Используйте lazy loading для медиа
- Кешируйте статические ресурсы
- Оптимизируйте JavaScript

### 2. Доступность
- Добавляйте alt-тексты к изображениям
- Используйте семантическую разметку
- Обеспечьте навигацию с клавиатуры
- Поддерживайте screen readers

### 3. Мобильная адаптация
- Используйте responsive дизайн
- Тестируйте на разных устройствах
- Оптимизируйте touch-взаимодействия
- Учитывайте ограниченную пропускную способность

### 4. Офлайн поддержка
```javascript
// Service Worker для офлайн режима
if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('/sw.js').then(function(registration) {
        console.log('ServiceWorker registered');
    });
}

// В sw.js
self.addEventListener('fetch', function(event) {
    event.respondWith(
        caches.match(event.request).then(function(response) {
            return response || fetch(event.request);
        })
    );
});
```

### 5. Аналитика и отчетность
- Отправляйте детальные xAPI statements
- Используйте extensions для дополнительных данных
- Отслеживайте время на каждой секции
- Собирайте данные о взаимодействиях

## 🔍 Отладка

### Инструменты для тестирования:
1. **xAPI Statement Viewer** - для просмотра отправленных statements
2. **Cmi5 Test Suite** - для валидации пакета
3. **Browser DevTools** - для отладки JavaScript
4. **LRS (Learning Record Store)** - для проверки сохраненных данных

### Частые проблемы:
1. **CORS ошибки** - настройте правильные заголовки на сервере
2. **Неверный формат манифеста** - используйте XML валидатор
3. **Потеря контекста cmi5** - проверьте инициализацию
4. **Проблемы с кодировкой** - используйте UTF-8 везде

## 📚 Дополнительные ресурсы

- [Cmi5 Specification](https://github.com/AICC/CMI-5_Spec_Current)
- [xAPI Specification](https://github.com/adlnet/xAPI-Spec)
- [Примеры курсов](https://github.com/adlnet/cmi5-examples)
- [Валидатор манифеста](https://cmi5.com/validator)

---

Это руководство поможет вам создавать качественные Cmi5 курсы для LMS. При возникновении вопросов обращайтесь к технической поддержке. 