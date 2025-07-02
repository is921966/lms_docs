#!/bin/bash

echo "🧹 Очистка дублирующих файлов в модуле Competency..."

# Резервное копирование на всякий случай
echo "📦 Создаем резервную копию..."
mkdir -p backup/competency-entities
cp -r src/Competency/Domain/Entities backup/competency-entities/
cp -r tests/Unit/Competency/Domain/Entities backup/competency-entities/

# Удаляем дублирующие файлы
echo ""
echo "🗑️ Удаляем дублирующие файлы..."

# Domain/Entities версии
rm -f src/Competency/Domain/Entities/Competency.php
rm -f src/Competency/Domain/Entities/CompetencyCategory.php
echo "✅ Удалены дублирующие Domain entities"

# Тесты для Entities версии  
rm -f tests/Unit/Competency/Domain/Entities/CompetencyTest.php
rm -f tests/Unit/Competency/Domain/Entities/CompetencyCategoryTest.php
echo "✅ Удалены дублирующие тесты"

# Проверяем, что папка Entities пуста и удаляем её
if [ -z "$(ls -A src/Competency/Domain/Entities 2>/dev/null)" ]; then
    rmdir src/Competency/Domain/Entities 2>/dev/null
    echo "✅ Удалена пустая папка Entities"
fi

if [ -z "$(ls -A tests/Unit/Competency/Domain/Entities 2>/dev/null)" ]; then
    rmdir tests/Unit/Competency/Domain/Entities 2>/dev/null
    echo "✅ Удалена пустая папка тестов Entities"
fi

echo ""
echo "📊 Результат:"
echo "- Основная версия: src/Competency/Domain/Competency.php (DDD с событиями)"
echo "- Резервная копия сохранена в: backup/competency-entities/"
echo ""
echo "🧪 Запускаем тесты для проверки..."
./test-quick.sh tests/Unit/Competency/ 2>&1 | grep -E "(Tests:|OK|ERRORS)" 