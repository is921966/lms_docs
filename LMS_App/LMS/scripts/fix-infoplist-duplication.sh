#!/bin/bash

# Скрипт для исправления дублирования Info.plist в Copy Bundle Resources

echo "🔧 Исправление дублирования Info.plist..."
echo "========================================"

PROJECT_FILE="LMS.xcodeproj/project.pbxproj"

if [ ! -f "$PROJECT_FILE" ]; then
    echo "❌ Файл проекта не найден: $PROJECT_FILE"
    exit 1
fi

# Создаем резервную копию
echo "📋 Создаем резервную копию project.pbxproj..."
cp "$PROJECT_FILE" "$PROJECT_FILE.backup_$(date +%Y%m%d_%H%M%S)"

# Удаляем Info.plist из Copy Bundle Resources
echo "🗑️  Удаляем Info.plist из Copy Bundle Resources..."

# Используем Python для безопасного редактирования
python3 << 'EOF'
import re

project_file = "LMS.xcodeproj/project.pbxproj"

# Читаем файл
with open(project_file, 'r') as f:
    content = f.read()

# Ищем и удаляем Info.plist из Copy Bundle Resources
# Паттерн для поиска Info.plist в секции Copy Bundle Resources
pattern = r'(\s*[A-F0-9]+ /\* Info\.plist in Resources \*/,?\s*\n)'

# Удаляем все вхождения
modified_content = re.sub(pattern, '', content)

# Сохраняем изменения
with open(project_file, 'w') as f:
    f.write(modified_content)

print("✅ Info.plist удален из Copy Bundle Resources")
EOF

echo ""
echo "✅ Исправление завершено!"
echo ""
echo "📝 Проверьте изменения:"
echo "   git diff LMS.xcodeproj/project.pbxproj"
echo ""
echo "🔄 Если что-то пошло не так, восстановите из резервной копии:"
echo "   cp $PROJECT_FILE.backup_* $PROJECT_FILE" 