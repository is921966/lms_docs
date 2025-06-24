#!/bin/bash

echo "🔧 Решение проблемы с Provisioning Profile"
echo "========================================="
echo ""

# Проверяем, есть ли уже файлы
if [ -f .temp-cicd/profile_base64.txt ]; then
    echo "✅ Файл profile_base64.txt уже существует!"
    echo "   Путь: .temp-cicd/profile_base64.txt"
    exit 0
fi

echo "📱 Provisioning Profile не найден автоматически."
echo "Это нормально! Есть два варианта решения:"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "ВАРИАНТ 1: Пропустить (Рекомендуется) ⭐"
echo "-----------------------------------------"
echo "GitHub Actions может автоматически управлять provisioning profiles!"
echo ""
echo "При добавлении секретов в GitHub просто:"
echo "• Оставьте поле BUILD_PROVISION_PROFILE_BASE64 пустым"
echo "• Или напишите в значении: skip"
echo ""
echo "CI/CD будет использовать автоматическое управление профилями."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "ВАРИАНТ 2: Создать профиль вручную"
echo "-----------------------------------"
echo "1. Откройте https://developer.apple.com"
echo "2. Certificates, IDs & Profiles → Profiles"
echo "3. Создайте новый App Store profile"
echo "4. Скачайте его"
echo ""

read -p "Выберите вариант (1 - пропустить, 2 - создать): " choice

if [ "$choice" = "1" ]; then
    # Создаем пустой файл чтобы скрипт не ругался
    mkdir -p .temp-cicd
    echo "skip" > .temp-cicd/profile_base64.txt
    echo ""
    echo "✅ Готово! Будет использоваться автоматическое управление."
    echo ""
    echo "В GitHub Secrets для BUILD_PROVISION_PROFILE_BASE64 укажите: skip"
elif [ "$choice" = "2" ]; then
    echo ""
    echo "Скачайте профиль с developer.apple.com и положите в папку Загрузки"
    read -p "Нажмите Enter когда скачали..."
    
    # Ищем скачанный профиль
    PROFILE=$(ls -t ~/Downloads/*.mobileprovision 2>/dev/null | head -1)
    if [ -f "$PROFILE" ]; then
        mkdir -p .temp-cicd
        cp "$PROFILE" .temp-cicd/profile.mobileprovision
        base64 -i "$PROFILE" -o .temp-cicd/profile_base64.txt
        echo "✅ Provisioning Profile обработан!"
    else
        echo "❌ Файл .mobileprovision не найден в Загрузках"
    fi
fi

echo ""
echo "🎯 Следующий шаг:"
echo "Продолжайте следовать инструкциям из github-secrets.txt" 