#!/bin/bash

echo "🔧 Настройка автоматического UI тестирования..."

# Проверяем, что мы в правильной директории
if [ ! -f "LMS.xcodeproj/project.pbxproj" ]; then
    echo "❌ Ошибка: Запустите скрипт из директории LMS_App/LMS/"
    exit 1
fi

# Создаем git hook если его нет
if [ ! -f "../../.git/hooks/pre-commit" ]; then
    echo "📝 Создаю pre-commit hook..."
    
    cat > ../../.git/hooks/pre-commit << 'EOF'
#!/bin/bash

# Pre-commit hook для запуска UI тестов
# Запускается автоматически перед каждым коммитом

# Проверяем, есть ли изменения в iOS файлах
if git diff --cached --name-only | grep -E 'LMS_App/.*\.(swift|xib|storyboard)$' > /dev/null; then
    echo "🧪 Обнаружены изменения в iOS файлах. Запускаю UI тесты..."
    
    # Переходим в директорию iOS приложения
    cd LMS_App/LMS || exit 1
    
    # Запускаем быстрый тест
    echo "⏱️  Запуск быстрой проверки..."
    
    # Компилируем только (без запуска) для быстрой проверки
    if xcodebuild build-for-testing \
        -scheme LMS \
        -destination 'platform=iOS Simulator,name=iPhone 16' \
        -quiet; then
        echo "✅ Код компилируется успешно!"
        
        # Опционально: запускаем один быстрый тест
        echo "🚀 Запуск smoke теста..."
        if xcodebuild test \
            -scheme LMS \
            -destination 'platform=iOS Simulator,name=iPhone 16' \
            -only-testing:LMSUITests/LMSUITests/testMockLogin_AsStudent_ShouldSucceed \
            -quiet; then
            echo "✅ Smoke тест прошел!"
        else
            echo "❌ Smoke тест провалился!"
            echo "💡 Подсказка: Запустите ./test-ui.sh для полного прогона тестов"
            exit 1
        fi
    else
        echo "❌ Ошибка компиляции!"
        exit 1
    fi
fi

exit 0
EOF
    
    chmod +x ../../.git/hooks/pre-commit
    echo "✅ Pre-commit hook создан!"
else
    echo "ℹ️  Pre-commit hook уже существует"
fi

# Создаем быстрый алиас для запуска тестов
echo "📝 Создаю алиас для быстрого запуска тестов..."

if ! grep -q "alias uitest=" ~/.zshrc 2>/dev/null; then
    echo 'alias uitest="cd $(pwd) && ./test-ui.sh"' >> ~/.zshrc
    echo "✅ Алиас 'uitest' добавлен в ~/.zshrc"
    echo "   Выполните 'source ~/.zshrc' или откройте новый терминал"
fi

# Проверяем симулятор
echo "🔍 Проверяю наличие симулятора iPhone 16..."
if xcrun simctl list devices | grep -q "iPhone 16"; then
    echo "✅ Симулятор iPhone 16 найден"
else
    echo "⚠️  Симулятор iPhone 16 не найден"
    echo "   Создайте его через Xcode: Window -> Devices and Simulators"
fi

echo """
🎉 Настройка завершена!

Теперь вы можете:
1. Запустить все UI тесты: ./test-ui.sh
2. Использовать алиас: uitest (после перезагрузки терминала)
3. Тесты будут автоматически запускаться перед коммитом

Дополнительные команды:
- Отключить pre-commit hook: rm ../../.git/hooks/pre-commit
- Запустить конкретный тест: xcodebuild test -scheme LMS -only-testing:LMSUITests/TestClass/testMethod

Удачного тестирования! 🚀
""" 