#!/bin/bash

# Простой скрипт настройки CI/CD для iOS
# Запустите: ./setup-ios-cicd.sh

echo "🚀 Настройка CI/CD для iOS - Упрощенная версия"
echo "=============================================="
echo ""

# Проверяем, что мы в правильной директории
if [ ! -f "LMS_App/LMS/LMS.xcodeproj/project.pbxproj" ]; then
    echo "❌ Запустите скрипт из корня проекта lms_docs"
    exit 1
fi

# Создаем директорию для временных файлов
mkdir -p .temp-cicd

echo "📱 Шаг 1: Экспорт сертификата"
echo "------------------------------"
echo ""
echo "⚠️  ВАЖНО: Для получения .p12 файла нужно экспортировать сертификат ВМЕСТЕ с ключом!"
echo ""
echo "1. Откройте 'Связка ключей' (Keychain Access)"
echo "2. В левой панели выберите 'Мои сертификаты' (My Certificates)"
echo "3. Найдите 'Apple Distribution: Igor Shirokov'"
echo "4. Разверните его нажав на треугольник ▼"
echo "5. Выделите ОБА элемента (сертификат И приватный ключ) зажав Cmd"
echo "6. Правый клик → 'Экспортировать 2 объекта...'"
echo "7. Сохраните как 'cert.p12' на Рабочий стол"
echo "8. Задайте простой пароль (например: 123456)"
echo ""
echo "📖 Подробная инструкция с картинками: open EXPORT_CERTIFICATE_GUIDE.md"
echo ""
read -p "Нажмите Enter когда сохранили cert.p12 на Рабочий стол..."

# Копируем и кодируем сертификат
if [ -f ~/Desktop/cert.p12 ]; then
    cp ~/Desktop/cert.p12 .temp-cicd/
    base64 -i .temp-cicd/cert.p12 -o .temp-cicd/cert_base64.txt
    echo "✅ Сертификат обработан"
else
    echo "❌ Файл cert.p12 не найден на Рабочем столе"
    echo "   Убедитесь что:"
    echo "   - Вы выбрали ОБА элемента (сертификат + ключ)"
    echo "   - Файл сохранен именно как cert.p12"
    echo "   - Файл находится на Рабочем столе"
    exit 1
fi

echo ""
echo "🔑 Шаг 2: App Store Connect API"
echo "--------------------------------"
echo "1. Откройте https://appstoreconnect.apple.com"
echo "2. Перейдите в Users and Access → Keys"
echo "3. Нажмите '+' для создания нового ключа"
echo "4. Name: 'CI', Access: 'App Manager'"
echo "5. Скачайте .p8 файл (скачается в Загрузки)"
echo ""
read -p "Нажмите Enter когда скачали .p8 файл..."

# Находим последний скачанный .p8 файл
P8_FILE=$(ls -t ~/Downloads/AuthKey_*.p8 2>/dev/null | head -1)
if [ -f "$P8_FILE" ]; then
    cp "$P8_FILE" .temp-cicd/
    base64 -i "$P8_FILE" -o .temp-cicd/api_key_base64.txt
    # Извлекаем Key ID из имени файла
    KEY_ID=$(basename "$P8_FILE" | sed 's/AuthKey_//' | sed 's/.p8//')
    echo "✅ API Key обработан (Key ID: $KEY_ID)"
else
    echo "❌ .p8 файл не найден в Загрузках"
    exit 1
fi

echo ""
echo "📝 Шаг 3: Введите данные"
echo "------------------------"
read -p "Issuer ID (скопируйте из App Store Connect): " ISSUER_ID
read -p "Пароль от cert.p12 (который вы задали): " P12_PASSWORD

echo ""
echo "📦 Шаг 4: Provisioning Profile"
echo "-------------------------------"
echo "Получаем автоматически из Xcode..."

# Открываем Xcode для скачивания profiles
open -a Xcode

echo "В Xcode:"
echo "1. Settings → Accounts"
echo "2. Выберите ваш аккаунт"
echo "3. Нажмите 'Download Manual Profiles'"
echo ""
read -p "Нажмите Enter после скачивания профилей..."

# Находим нужный provisioning profile
PROFILE=$(find ~/Library/MobileDevice/Provisioning\ Profiles -name "*.mobileprovision" -exec grep -l "ru.tsum.lms.igor" {} \; | head -1)
if [ -f "$PROFILE" ]; then
    cp "$PROFILE" .temp-cicd/profile.mobileprovision
    base64 -i .temp-cicd/profile.mobileprovision -o .temp-cicd/profile_base64.txt
    echo "✅ Provisioning Profile найден"
else
    echo "⚠️  Profile не найден, CI будет использовать автоматическое управление"
fi

echo ""
echo "📋 Создаю файл с инструкциями..."

# Создаем простой файл с инструкциями
cat > github-secrets.txt << EOF
🎯 ПРОСТАЯ ИНСТРУКЦИЯ ДЛЯ GITHUB

1. Откройте ваш репозиторий на GitHub
2. Нажмите Settings → Secrets and variables → Actions
3. Для каждого секрета ниже:
   - Нажмите "New repository secret"
   - Введите Name и Value
   - Нажмите "Add secret"

СЕКРЕТЫ ДЛЯ ДОБАВЛЕНИЯ:
======================

Name: APP_STORE_CONNECT_API_KEY_ID
Value: $KEY_ID

Name: APP_STORE_CONNECT_API_KEY_ISSUER_ID
Value: $ISSUER_ID

Name: APP_STORE_CONNECT_API_KEY_KEY
Value: [Скопируйте всё содержимое файла .temp-cicd/api_key_base64.txt]

Name: BUILD_CERTIFICATE_BASE64
Value: [Скопируйте всё содержимое файла .temp-cicd/cert_base64.txt]

Name: P12_PASSWORD
Value: $P12_PASSWORD

Name: BUILD_PROVISION_PROFILE_BASE64
Value: [Скопируйте всё содержимое файла .temp-cicd/profile_base64.txt]

Name: KEYCHAIN_PASSWORD
Value: temp_ci_keychain_pwd

ГОТОВО! После добавления всех секретов, сделайте любой коммит в main ветку.
EOF

echo ""
echo "✅ ВСЁ ГОТОВО!"
echo ""
echo "📄 Откройте файл 'github-secrets.txt' и следуйте инструкциям"
echo ""
echo "🧹 После настройки GitHub можете удалить временные файлы:"
echo "   rm -rf .temp-cicd github-secrets.txt ~/Desktop/cert.p12"
echo ""
open github-secrets.txt 