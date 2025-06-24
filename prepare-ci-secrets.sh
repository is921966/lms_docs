#!/bin/bash

# Script to prepare secrets for GitHub Actions CI/CD
# Usage: ./prepare-ci-secrets.sh

set -e

echo "🔐 Подготовка секретов для CI/CD"
echo "================================="
echo ""

# Create output directory
OUTPUT_DIR="ci-secrets"
mkdir -p "$OUTPUT_DIR"

# Function to encode file to base64
encode_file() {
    local file=$1
    local output=$2
    
    if [ -f "$file" ]; then
        base64 -i "$file" -o "$OUTPUT_DIR/$output"
        echo "✅ Закодирован: $file → $OUTPUT_DIR/$output"
    else
        echo "❌ Файл не найден: $file"
        return 1
    fi
}

echo "📝 Инструкции:"
echo ""
echo "1. Экспортируйте Distribution сертификат из Keychain:"
echo "   - Откройте Keychain Access"
echo "   - Найдите 'Apple Distribution: Igor Shirokov'"
echo "   - Правый клик → Export"
echo "   - Сохраните как 'distribution.p12' с паролем"
echo ""
echo "2. Скачайте Distribution Provisioning Profile:"
echo "   - Xcode → Preferences → Accounts → Download Manual Profiles"
echo "   - Найдите profile в ~/Library/MobileDevice/Provisioning Profiles/"
echo "   - Или скачайте с developer.apple.com"
echo ""
echo "3. Скачайте App Store Connect API Key:"
echo "   - https://appstoreconnect.apple.com"
echo "   - Users and Access → Keys"
echo "   - Создайте новый ключ или используйте существующий"
echo ""

read -p "Нажмите Enter когда все файлы готовы..."

echo ""
echo "🔄 Кодирование файлов..."
echo ""

# Encode certificate
read -p "Путь к distribution.p12 файлу: " cert_path
encode_file "$cert_path" "certificate_base64.txt"

# Encode provisioning profile
read -p "Путь к .mobileprovision файлу: " profile_path
encode_file "$profile_path" "profile_base64.txt"

# Encode API key
read -p "Путь к AuthKey_XXXXXX.p8 файлу: " apikey_path
encode_file "$apikey_path" "apikey_base64.txt"

echo ""
echo "📋 GitHub Secrets для добавления:"
echo "================================="
echo ""
echo "1. APP_STORE_CONNECT_API_KEY_ID"
read -p "   Введите Key ID (10 символов): " key_id
echo "   ✅ Значение: $key_id"
echo ""

echo "2. APP_STORE_CONNECT_API_KEY_ISSUER_ID"
read -p "   Введите Issuer ID (UUID): " issuer_id
echo "   ✅ Значение: $issuer_id"
echo ""

echo "3. APP_STORE_CONNECT_API_KEY_KEY"
echo "   ✅ Файл: $OUTPUT_DIR/apikey_base64.txt"
echo ""

echo "4. BUILD_CERTIFICATE_BASE64"
echo "   ✅ Файл: $OUTPUT_DIR/certificate_base64.txt"
echo ""

echo "5. P12_PASSWORD"
read -s -p "   Введите пароль от .p12 файла: " p12_password
echo ""
echo "   ✅ Значение сохранено"
echo ""

echo "6. BUILD_PROVISION_PROFILE_BASE64"
echo "   ✅ Файл: $OUTPUT_DIR/profile_base64.txt"
echo ""

echo "7. KEYCHAIN_PASSWORD"
echo "   ✅ Можно использовать любой пароль, например: temp_ci_keychain_pwd"
echo ""

# Save secrets info
cat > "$OUTPUT_DIR/secrets_to_add.txt" << EOF
GitHub Secrets для добавления:

1. APP_STORE_CONNECT_API_KEY_ID = $key_id
2. APP_STORE_CONNECT_API_KEY_ISSUER_ID = $issuer_id
3. APP_STORE_CONNECT_API_KEY_KEY = содержимое файла apikey_base64.txt
4. BUILD_CERTIFICATE_BASE64 = содержимое файла certificate_base64.txt
5. P12_PASSWORD = [ваш пароль от сертификата]
6. BUILD_PROVISION_PROFILE_BASE64 = содержимое файла profile_base64.txt
7. KEYCHAIN_PASSWORD = temp_ci_keychain_pwd

Опциональные:
8. SLACK_WEBHOOK = [webhook URL из Slack]

Как добавить:
1. Откройте https://github.com/YOUR_REPO/settings/secrets/actions
2. Нажмите "New repository secret"
3. Добавьте каждый секрет из списка выше
EOF

echo "💾 Информация сохранена в: $OUTPUT_DIR/secrets_to_add.txt"
echo ""
echo "🎯 Следующие шаги:"
echo "1. Откройте GitHub репозиторий → Settings → Secrets"
echo "2. Добавьте все секреты из файла $OUTPUT_DIR/secrets_to_add.txt"
echo "3. Сделайте тестовый commit для проверки CI/CD"
echo ""
echo "⚠️  ВАЖНО: Не коммитьте папку '$OUTPUT_DIR' в git!"
echo ""
echo "✅ Готово!" 