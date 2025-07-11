#!/bin/bash

# Автоматическая загрузка на TestFlight с учетом лимитов (2 билда в день)
# Использование: ./auto-testflight.sh [morning|afternoon|check]

echo "🚀 LMS TestFlight Auto-Upload Script"
echo "===================================="
echo ""

# Файл для отслеживания загрузок
UPLOAD_LOG="$HOME/.lms_testflight_uploads.log"
TODAY=$(date +%Y-%m-%d)

# Функция для проверки количества загрузок за сегодня
check_daily_uploads() {
    if [ ! -f "$UPLOAD_LOG" ]; then
        echo 0
        return
    fi
    
    grep -c "^$TODAY" "$UPLOAD_LOG" || echo 0
}

# Функция для записи загрузки
log_upload() {
    echo "$TODAY $(date +%H:%M:%S) $1" >> "$UPLOAD_LOG"
}

# Функция для очистки старых записей (старше 7 дней)
cleanup_old_logs() {
    if [ -f "$UPLOAD_LOG" ]; then
        local WEEK_AGO=$(date -v-7d +%Y-%m-%d 2>/dev/null || date -d '7 days ago' +%Y-%m-%d)
        local TEMP_FILE=$(mktemp)
        awk -v cutoff="$WEEK_AGO" '$1 >= cutoff' "$UPLOAD_LOG" > "$TEMP_FILE"
        mv "$TEMP_FILE" "$UPLOAD_LOG"
    fi
}

# Функция для загрузки на TestFlight
upload_to_testflight() {
    local TIME_SLOT=$1
    
    echo "📊 Проверка лимитов..."
    local UPLOADS_TODAY=$(check_daily_uploads)
    
    if [ "$UPLOADS_TODAY" -ge 2 ]; then
        echo "❌ Достигнут дневной лимит загрузок (2/2)"
        echo "   Последние загрузки:"
        grep "^$TODAY" "$UPLOAD_LOG" | tail -2
        exit 1
    fi
    
    echo "✅ Загрузок сегодня: $UPLOADS_TODAY/2"
    echo ""
    
    # Подготовка changelog
    local CHANGELOG="Автоматическая сборка - $TIME_SLOT $(date +'%d.%m.%Y %H:%M')"
    if [ -f "TESTFLIGHT_CHANGELOG.md" ]; then
        CHANGELOG=$(cat TESTFLIGHT_CHANGELOG.md | sed 's/^#.*//g' | tr '\n' ' ')
    fi
    
    # Получаем следующий номер билда
    local CURRENT_BUILD=$(./scripts/get-next-build-number.sh increment)
    
    echo "🔨 Начинаю сборку и загрузку..."
    echo "   Build: $CURRENT_BUILD"
    echo "   Время: $TIME_SLOT"
    echo ""
    
    # Обновляем номер билда в проекте
    xcrun agvtool new-version -all $CURRENT_BUILD
    
    # Запуск fastlane
    export TESTFLIGHT_CHANGELOG="$CHANGELOG"
    export MANUAL_BUILD_NUMBER="$CURRENT_BUILD"
    
    # Сначала пробуем fastlane
    if command -v fastlane &> /dev/null; then
        fastlane beta
        RESULT=$?
    else
        # Если fastlane не работает, используем прямой метод
        echo "⚠️  Fastlane не настроен, использую прямой метод..."
        ./build-testflight-manual.sh
        RESULT=$?
    fi
    
    if [ $RESULT -eq 0 ]; then
        log_upload "SUCCESS $TIME_SLOT build:$CURRENT_BUILD"
        echo "✅ Загрузка успешна!"
        
        # Отправка уведомления (если настроено)
        if command -v terminal-notifier &> /dev/null; then
            terminal-notifier -title "TestFlight Upload" -message "✅ $TIME_SLOT билд $CURRENT_BUILD загружен успешно!" -sound default
        fi
    else
        log_upload "FAILED $TIME_SLOT build:$CURRENT_BUILD"
        echo "❌ Ошибка загрузки!"
        
        if command -v terminal-notifier &> /dev/null; then
            terminal-notifier -title "TestFlight Upload" -message "❌ Ошибка загрузки $TIME_SLOT билда!" -sound Basso
        fi
        exit 1
    fi
}

# Основная логика
case "${1:-check}" in
    morning)
        echo "☀️  Утренняя загрузка..."
        cleanup_old_logs
        upload_to_testflight "Morning"
        ;;
    afternoon)
        echo "🌅 Послеобеденная загрузка..."
        upload_to_testflight "Afternoon"
        ;;
    check)
        echo "📊 Статус загрузок:"
        echo ""
        UPLOADS_TODAY=$(check_daily_uploads)
        echo "Сегодня загружено: $UPLOADS_TODAY/2 билдов"
        
        if [ "$UPLOADS_TODAY" -gt 0 ]; then
            echo ""
            echo "Сегодняшние загрузки:"
            grep "^$TODAY" "$UPLOAD_LOG"
        fi
        
        echo ""
        echo "Текущий номер билда: $(./scripts/get-next-build-number.sh get)"
        echo ""
        echo "📅 История за последние 7 дней:"
        if [ -f "$UPLOAD_LOG" ]; then
            tail -14 "$UPLOAD_LOG" | sort -r
        else
            echo "Нет записей"
        fi
        ;;
    force)
        echo "⚠️  Принудительная загрузка (игнорирование лимитов)..."
        upload_to_testflight "Manual"
        ;;
    *)
        echo "Использование: $0 [morning|afternoon|check|force]"
        echo ""
        echo "  morning    - Утренняя загрузка (рекомендуется на 9:00)"
        echo "  afternoon  - Послеобеденная загрузка (рекомендуется на 15:00)"
        echo "  check      - Проверить статус загрузок"
        echo "  force      - Принудительная загрузка (осторожно!)"
        exit 1
        ;;
esac 