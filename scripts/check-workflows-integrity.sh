#!/bin/bash

# Скрипт для проверки целостности GitHub Actions workflows
# Сравнивает текущие workflows с эталонными копиями

echo "🔍 Проверка целостности GitHub Actions workflows..."
echo "=================================================="

WORKFLOWS_DIR=".github/workflows"
GOLDEN_COPY_DIR=".github/workflows-golden-copy"
DIFFERENCES_FOUND=0

# Проверяем наличие эталонной папки
if [ ! -d "$GOLDEN_COPY_DIR" ]; then
    echo "❌ ОШИБКА: Папка с эталонными workflows не найдена!"
    echo "   Путь: $GOLDEN_COPY_DIR"
    exit 1
fi

# Список критических workflows
CRITICAL_WORKFLOWS=(
    "ios-testflight-deploy.yml"
    "ios-test.yml"
    "quick-status.yml"
)

echo ""
echo "📋 Проверка критических workflows:"
echo "----------------------------------"

for workflow in "${CRITICAL_WORKFLOWS[@]}"; do
    if [ ! -f "$WORKFLOWS_DIR/$workflow" ]; then
        echo "❌ $workflow - НЕ НАЙДЕН в рабочей папке!"
        DIFFERENCES_FOUND=1
        continue
    fi
    
    if [ ! -f "$GOLDEN_COPY_DIR/$workflow" ]; then
        echo "⚠️  $workflow - нет эталонной копии"
        continue
    fi
    
    # Сравниваем файлы
    if diff -q "$WORKFLOWS_DIR/$workflow" "$GOLDEN_COPY_DIR/$workflow" > /dev/null; then
        echo "✅ $workflow - соответствует эталону"
    else
        echo "❌ $workflow - ОТЛИЧАЕТСЯ от эталона!"
        DIFFERENCES_FOUND=1
        
        # Показываем различия
        echo "   Различия:"
        diff -u "$GOLDEN_COPY_DIR/$workflow" "$WORKFLOWS_DIR/$workflow" | head -20
        echo "   ..."
    fi
done

echo ""
echo "📊 Общая проверка всех workflows:"
echo "---------------------------------"

# Проверяем все yml файлы
for golden_file in "$GOLDEN_COPY_DIR"/*.yml; do
    filename=$(basename "$golden_file")
    current_file="$WORKFLOWS_DIR/$filename"
    
    if [ ! -f "$current_file" ]; then
        echo "⚠️  $filename - есть в эталоне, но отсутствует в рабочей папке"
    fi
done

# Проверяем новые workflows
for current_file in "$WORKFLOWS_DIR"/*.yml; do
    filename=$(basename "$current_file")
    golden_file="$GOLDEN_COPY_DIR/$filename"
    
    if [ ! -f "$golden_file" ]; then
        echo "🆕 $filename - новый workflow (нет в эталонной копии)"
    fi
done

echo ""
echo "=================================================="

if [ $DIFFERENCES_FOUND -eq 0 ]; then
    echo "✅ Все критические workflows соответствуют эталонным копиям"
    exit 0
else
    echo "❌ Обнаружены различия в критических workflows!"
    echo ""
    echo "Для восстановления эталонной конфигурации выполните:"
    echo "  cp $GOLDEN_COPY_DIR/*.yml $WORKFLOWS_DIR/"
    echo ""
    echo "Или для восстановления конкретного workflow:"
    echo "  cp $GOLDEN_COPY_DIR/workflow-name.yml $WORKFLOWS_DIR/"
    exit 1
fi 