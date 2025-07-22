#!/bin/bash

# Агрессивное исправление проблемы с Info.plist

echo "🔧 Агрессивное исправление дублирования Info.plist..."
echo "=================================================="

PROJECT_FILE="LMS.xcodeproj/project.pbxproj"

if [ ! -f "$PROJECT_FILE" ]; then
    echo "❌ Файл проекта не найден: $PROJECT_FILE"
    exit 1
fi

# Создаем резервную копию
echo "📋 Создаем резервную копию project.pbxproj..."
cp "$PROJECT_FILE" "$PROJECT_FILE.backup_aggressive_$(date +%Y%m%d_%H%M%S)"

# Используем Python для более точного редактирования
python3 << 'EOF'
import re

project_file = "LMS.xcodeproj/project.pbxproj"

# Читаем файл
with open(project_file, 'r') as f:
    content = f.read()

# Находим секцию Copy Bundle Resources
copy_resources_pattern = r'(/\* Copy Bundle Resources \*/ = \{[^}]+files = \([^)]+\);[^}]+\})'

def remove_info_plist_from_resources(match):
    section = match.group(0)
    # Удаляем все строки с Info.plist
    lines = section.split('\n')
    filtered_lines = []
    for line in lines:
        if 'Info.plist in Resources' not in line and 'Info.plist in Copy Bundle Resources' not in line:
            filtered_lines.append(line)
    return '\n'.join(filtered_lines)

# Заменяем секцию
modified_content = re.sub(copy_resources_pattern, remove_info_plist_from_resources, content, flags=re.DOTALL)

# Также удаляем отдельные ссылки на Info.plist в Resources
info_plist_pattern = r'[A-F0-9]+ /\* Info\.plist in (Resources|Copy Bundle Resources) \*/,?\s*\n'
modified_content = re.sub(info_plist_pattern, '', modified_content)

# Сохраняем изменения
with open(project_file, 'w') as f:
    f.write(modified_content)

print("✅ Info.plist удален из всех Copy Bundle Resources")

# Проверяем результат
with open(project_file, 'r') as f:
    content = f.read()
    if 'Info.plist in Resources' in content:
        print("⚠️  Предупреждение: Найдены остаточные ссылки на Info.plist in Resources")
    else:
        print("✅ Все ссылки на Info.plist in Resources удалены")
EOF

echo ""
echo "🧹 Очищаем DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/LMS-*

echo ""
echo "✅ Исправление завершено!"
echo ""
echo "📝 Теперь попробуйте создать архив снова" 