#!/bin/bash

echo "🚀 Подготовка нового билда для TestFlight..."
echo "==========================================="
echo ""

# Параметры
NEW_VERSION="2.1.1"
NEW_BUILD="205"
RELEASE_DATE=$(date +"%d.%m.%Y")

echo "📱 Новая версия: $NEW_VERSION (Build $NEW_BUILD)"
echo ""

# 1. Обновляем версию
echo "1️⃣ Обновление версии..."
agvtool new-marketing-version $NEW_VERSION
agvtool new-version -all $NEW_BUILD

echo "✅ Версия обновлена"
echo ""

# 2. Создаем release notes
echo "2️⃣ Создание Release Notes..."

RELEASE_NOTES_FILE="/Users/ishirokov/lms_docs/docs/releases/TESTFLIGHT_RELEASE_v${NEW_VERSION}.md"

cat > "$RELEASE_NOTES_FILE" << EOF
# TestFlight Release v${NEW_VERSION}

**Дата релиза**: ${RELEASE_DATE}
**Build**: ${NEW_BUILD}

## 🎯 Основные изменения

### ✅ Исправлена тестовая инфраструктура
- Удалены дубликаты файлов тестов
- Исправлены все ошибки компиляции UI тестов
- Обновлена инфраструктура для 43 UI тестов
- 100% успех всех протестированных тестов

### 🔧 Технические улучшения
- Оптимизирована навигация в тестах
- Добавлена поддержка разных UI структур
- Улучшена стабильность тестов
- Исправлены проблемы с MockCmi5Service

### 📱 Обновленные модули
- Feed UI - улучшена стабильность
- Cmi5 - исправлены модели данных
- Course Management - упрощена навигация
- E2E тесты - создана полная инфраструктура

## 📋 Что нового для тестировщиков

### Проверьте следующие функции:
1. **Feed (Новости)**
   - Отображение списка новостей
   - Навигация между новостями
   - Обновление ленты свайпом вниз

2. **Cmi5 курсы**
   - Просмотр списка пакетов
   - Загрузка новых пакетов
   - Запуск активностей

3. **Управление курсами**
   - Создание нового курса
   - Просмотр деталей курса
   - Запись на курс

## 🐛 Известные проблемы
- Некоторые UI тесты могут показывать предупреждения о симуляторе (не влияет на функциональность)

## 📊 Статистика тестов
- Всего UI тестов: 43
- Протестировано: 20
- Успешно: 20 (100%)

## 🔍 Фокус тестирования
Пожалуйста, обратите особое внимание на:
- Стабильность навигации между модулями
- Корректность отображения данных в Feed
- Работу с Cmi5 пакетами
- Процесс создания и управления курсами

---

**Техническая информация**:
- iOS минимальная версия: 17.0
- Рекомендуемая версия: iOS 18.5
- Размер приложения: ~45 MB

EOF

echo "✅ Release Notes созданы: $RELEASE_NOTES_FILE"
echo ""

# 3. Очистка DerivedData
echo "3️⃣ Очистка DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/LMS-*
echo "✅ DerivedData очищена"
echo ""

# 4. Создание архива
echo "4️⃣ Создание архива..."
echo ""
echo "📦 Начинаю сборку архива..."

xcodebuild archive \
    -scheme LMS \
    -configuration Release \
    -archivePath ~/Desktop/LMS_v${NEW_VERSION}_build${NEW_BUILD}.xcarchive \
    -allowProvisioningUpdates \
    CODE_SIGN_STYLE=Automatic \
    DEVELOPMENT_TEAM=8Y7XSRU6LB

ARCHIVE_RESULT=$?

if [ $ARCHIVE_RESULT -eq 0 ]; then
    echo "✅ Архив успешно создан!"
    echo "📍 Расположение: ~/Desktop/LMS_v${NEW_VERSION}_build${NEW_BUILD}.xcarchive"
else
    echo "❌ Ошибка при создании архива!"
    echo "Проверьте настройки подписи и сертификаты"
    exit 1
fi

echo ""
echo "5️⃣ Следующие шаги:"
echo "==================="
echo "1. Откройте Xcode Organizer (Window → Organizer)"
echo "2. Выберите архив LMS v${NEW_VERSION} (${NEW_BUILD})"
echo "3. Нажмите 'Distribute App'"
echo "4. Выберите 'App Store Connect'"
echo "5. Следуйте инструкциям для загрузки в TestFlight"
echo ""
echo "📝 Release Notes сохранены в:"
echo "   $RELEASE_NOTES_FILE"
echo ""
echo "🎉 Подготовка к TestFlight завершена!" 