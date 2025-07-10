#!/bin/bash

# Скрипт для создания структуры Cmi5 курса
# Использование: ./create-cmi5-course.sh "Название курса" количество_модулей

COURSE_NAME="$1"
MODULE_COUNT="${2:-3}"
COURSE_DIR=$(echo "$COURSE_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
BASE_DIR="/Users/ishirokov/lms_docs/cmi5_courses/$COURSE_DIR"

if [ -z "$COURSE_NAME" ]; then
    echo "❌ Ошибка: Укажите название курса"
    echo "Использование: $0 \"Название курса\" [количество_модулей]"
    exit 1
fi

echo "🚀 Создаем Cmi5 курс: $COURSE_NAME"
echo "📁 Директория: $BASE_DIR"
echo "📚 Количество модулей: $MODULE_COUNT"

# Создаем структуру папок
mkdir -p "$BASE_DIR"/{content,assessments,media,assets}

# Создаем базовый cmi5.xml
cat > "$BASE_DIR/cmi5.xml" << EOF
<?xml version="1.0" encoding="utf-8"?>
<courseStructure xmlns="https://w3id.org/xapi/profiles/cmi5/v1/CourseStructure.xsd">
    <course id="course_${COURSE_DIR}_v1">
        <title>
            <langstring lang="ru">$COURSE_NAME</langstring>
        </title>
        <description>
            <langstring lang="ru">Описание курса $COURSE_NAME</langstring>
        </description>
EOF

# Генерируем модули
for i in $(seq 1 $MODULE_COUNT); do
    cat >> "$BASE_DIR/cmi5.xml" << EOF
        
        <block id="block_$i">
            <title>
                <langstring lang="ru">Модуль $i</langstring>
            </title>
            <description>
                <langstring lang="ru">Описание модуля $i</langstring>
            </description>
            
            <au id="au_${i}_1" moveOn="completed" masteryScore="0.8">
                <title>
                    <langstring lang="ru">Урок $i.1</langstring>
                </title>
                <description>
                    <langstring lang="ru">Введение в тему модуля $i</langstring>
                </description>
                <url>content/module${i}_lesson1.html</url>
                <launchMethod>AnyWindow</launchMethod>
                <activityType>http://adlnet.gov/expapi/activities/lesson</activityType>
            </au>
            
            <au id="au_${i}_test" moveOn="passed" masteryScore="0.75">
                <title>
                    <langstring lang="ru">Тест к модулю $i</langstring>
                </title>
                <description>
                    <langstring lang="ru">Проверка знаний по модулю $i</langstring>
                </description>
                <url>assessments/test${i}.html</url>
                <launchMethod>OwnWindow</launchMethod>
                <activityType>http://adlnet.gov/expapi/activities/assessment</activityType>
            </au>
        </block>
EOF

    # Создаем файлы уроков
    cat > "$BASE_DIR/content/module${i}_lesson1.html" << 'EOF'
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Урок</title>
    <script src="https://unpkg.com/@xapi/cmi5@latest/dist/cmi5.min.js"></script>
    <link rel="stylesheet" href="../assets/styles.css">
</head>
<body>
    <div class="container">
        <h1>[Заголовок урока]</h1>
        <div class="content">
            <p>[Добавьте ваш контент здесь]</p>
        </div>
        <div class="nav-buttons">
            <button onclick="complete()">Завершить урок</button>
        </div>
    </div>
    <script src="../assets/cmi5-handler.js"></script>
</body>
</html>
EOF

    # Создаем файлы тестов
    cat > "$BASE_DIR/assessments/test${i}.html" << 'EOF'
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Тест</title>
    <script src="https://unpkg.com/@xapi/cmi5@latest/dist/cmi5.min.js"></script>
    <link rel="stylesheet" href="../assets/styles.css">
</head>
<body>
    <div class="container">
        <h1>Тест к модулю</h1>
        <div class="question">
            <p>[Вопрос 1]</p>
            <div class="options">
                <label><input type="radio" name="q1" value="1"> Вариант 1</label>
                <label><input type="radio" name="q1" value="2"> Вариант 2</label>
                <label><input type="radio" name="q1" value="3"> Вариант 3</label>
                <label><input type="radio" name="q1" value="4"> Вариант 4</label>
            </div>
        </div>
        <button onclick="submitTest()">Отправить ответы</button>
    </div>
    <script src="../assets/cmi5-handler.js"></script>
</body>
</html>
EOF
done

# Завершаем cmi5.xml
cat >> "$BASE_DIR/cmi5.xml" << EOF
        
    </course>
    
    <vendor>
        <name>LMS Team</name>
        <url>https://lms.example.com</url>
        <email>support@lms.example.com</email>
    </vendor>
</courseStructure>
EOF

# Создаем CSS файл
cat > "$BASE_DIR/assets/styles.css" << 'EOF'
body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    line-height: 1.6;
    color: #333;
    max-width: 800px;
    margin: 0 auto;
    padding: 20px;
    background-color: #f5f5f5;
}

.container {
    background: white;
    padding: 30px;
    border-radius: 10px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

h1 {
    color: #2c3e50;
    border-bottom: 3px solid #3498db;
    padding-bottom: 10px;
}

button {
    background: #3498db;
    color: white;
    border: none;
    padding: 10px 20px;
    border-radius: 5px;
    cursor: pointer;
    font-size: 16px;
}

button:hover {
    background: #2980b9;
}

.question {
    margin: 20px 0;
    padding: 20px;
    background: #f8f9fa;
    border-radius: 10px;
}

.options {
    display: flex;
    flex-direction: column;
    gap: 10px;
    margin-top: 15px;
}

.options label {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 10px;
    background: white;
    border-radius: 5px;
    cursor: pointer;
}

.options label:hover {
    background: #e3f2fd;
}
EOF

# Создаем JS обработчик
cat > "$BASE_DIR/assets/cmi5-handler.js" << 'EOF'
let cmi5;

window.onload = function() {
    if (window.Cmi5) {
        cmi5 = new Cmi5();
        cmi5.initialize().then(() => {
            console.log('Cmi5 initialized');
            sendStatement('initialized');
        }).catch(err => {
            console.log('Running in standalone mode');
        });
    }
};

function complete() {
    sendStatement('completed');
    alert('Урок завершен!');
    if (cmi5) {
        cmi5.terminate();
    }
}

function submitTest() {
    // Здесь добавьте логику проверки ответов
    const score = 0.8; // Пример
    sendStatement('completed', { score: score, passed: score >= 0.75 });
    alert('Тест завершен! Результат: ' + (score * 100) + '%');
    if (cmi5) {
        cmi5.terminate();
    }
}

function sendStatement(verb, result = {}) {
    if (!cmi5) return;
    
    const statement = {
        verb: {
            id: `http://adlnet.gov/expapi/verbs/${verb}`,
            display: { "en-US": verb }
        },
        object: {
            id: window.location.href,
            definition: {
                name: { "ru": document.title }
            }
        }
    };
    
    if (verb === 'completed') {
        statement.result = {
            completion: true,
            success: result.passed !== undefined ? result.passed : true
        };
        if (result.score !== undefined) {
            statement.result.score = { scaled: result.score };
        }
    }
    
    cmi5.sendStatement(statement);
}
EOF

# Создаем README
cat > "$BASE_DIR/README.md" << EOF
# $COURSE_NAME

## Структура курса
- Количество модулей: $MODULE_COUNT
- Формат: Cmi5

## Как заполнить контентом

1. Откройте файлы в папке \`content/\`
2. Замените \`[Заголовок урока]\` и \`[Добавьте ваш контент здесь]\` на ваш материал
3. В папке \`assessments/\` добавьте вопросы в тесты
4. При необходимости добавьте изображения в \`media/\`

## Создание архива
\`\`\`bash
cd $(dirname "$BASE_DIR")
zip -r ${COURSE_DIR}.zip $COURSE_DIR/
\`\`\`

## Загрузка в LMS
1. Используйте созданный ZIP архив
2. Импортируйте через интерфейс Cmi5
EOF

echo "✅ Курс создан успешно!"
echo "📁 Расположение: $BASE_DIR"
echo ""
echo "📝 Следующие шаги:"
echo "1. Добавьте контент в HTML файлы"
echo "2. Создайте ZIP архив: cd $(dirname "$BASE_DIR") && zip -r ${COURSE_DIR}.zip $COURSE_DIR/"
echo "3. Загрузите в LMS" 