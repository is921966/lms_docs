#!/bin/bash

# Скрипт настройки автоматической загрузки на TestFlight
# Использование: ./setup-auto-upload.sh

echo "🔧 Настройка автоматической загрузки LMS на TestFlight"
echo "===================================================="
echo ""

# Текущая директория
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Проверка наличия необходимых скриптов
if [ ! -f "$SCRIPT_DIR/auto-testflight.sh" ]; then
    echo "❌ Не найден скрипт auto-testflight.sh"
    exit 1
fi

# Делаем скрипты исполняемыми
chmod +x "$SCRIPT_DIR/auto-testflight.sh"
chmod +x "$SCRIPT_DIR/local-test.sh"
chmod +x "$SCRIPT_DIR/build-testflight-manual.sh" 2>/dev/null || true
chmod +x "$SCRIPT_DIR/build-testflight-nosign.sh" 2>/dev/null || true

echo "✅ Скрипты готовы к использованию"
echo ""

# Настройка cron
echo "📅 Настройка расписания..."
echo ""
echo "Рекомендуемое расписание:"
echo "  - 09:00 - Утренняя сборка"
echo "  - 15:00 - Послеобеденная сборка"
echo ""

# Создание cron задач
CRON_MORNING="0 9 * * * cd $SCRIPT_DIR && ./auto-testflight.sh morning >> $HOME/lms_uploads.log 2>&1"
CRON_AFTERNOON="0 15 * * * cd $SCRIPT_DIR && ./auto-testflight.sh afternoon >> $HOME/lms_uploads.log 2>&1"

# Проверка существующих задач
EXISTING_CRON=$(crontab -l 2>/dev/null | grep -c "auto-testflight.sh" || echo 0)

if [ "$EXISTING_CRON" -gt 0 ]; then
    echo "⚠️  Обнаружены существующие задачи cron для TestFlight"
    echo ""
    crontab -l | grep "auto-testflight.sh"
    echo ""
    read -p "Заменить существующие задачи? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Отменено"
        exit 0
    fi
    
    # Удаляем старые задачи
    crontab -l | grep -v "auto-testflight.sh" | crontab -
fi

# Добавление новых задач
echo "📝 Добавление задач в cron..."
(crontab -l 2>/dev/null; echo "$CRON_MORNING") | crontab -
(crontab -l 2>/dev/null; echo "$CRON_AFTERNOON") | crontab -

echo "✅ Задачи добавлены в cron"
echo ""

# Установка terminal-notifier для уведомлений (опционально)
if ! command -v terminal-notifier &> /dev/null; then
    echo "💡 Рекомендация: установите terminal-notifier для уведомлений"
    echo "   brew install terminal-notifier"
    echo ""
fi

# Создание лог файла
touch "$HOME/lms_uploads.log"
echo "📋 Лог файл создан: $HOME/lms_uploads.log"
echo ""

# Проверка статуса
echo "📊 Текущий статус:"
"$SCRIPT_DIR/auto-testflight.sh" check

echo ""
echo "✅ Автоматизация настроена!"
echo ""
echo "📝 Полезные команды:"
echo "  ./local-test.sh              - Локальное тестирование на симуляторе"
echo "  ./auto-testflight.sh check   - Проверить статус загрузок"
echo "  ./auto-testflight.sh morning - Запустить утреннюю загрузку вручную"
echo "  tail -f ~/lms_uploads.log    - Смотреть логи в реальном времени"
echo "  crontab -l                   - Посмотреть расписание"
echo "  crontab -r                   - Удалить все задачи cron"
echo ""
echo "⚠️  Важно:"
echo "  - Компьютер должен быть включен в время запуска"
echo "  - Xcode должен быть авторизован с Apple ID"
echo "  - Максимум 2 загрузки в день!" 