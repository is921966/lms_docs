#!/usr/bin/env python3
"""
Интерактивный скрипт для настройки GitHub токена
"""
import json
import os
import getpass

print("🔧 Настройка GitHub токена для Feedback System")
print("=" * 50)

# Загружаем текущую конфигурацию
config_file = 'feedback_config.json'
with open(config_file, 'r') as f:
    config = json.load(f)

# Запрашиваем токен
print("\n📝 Введите ваш GitHub Personal Access Token:")
print("   (токен не будет отображаться при вводе)")
token = getpass.getpass("Token (ghp_...): ")

if not token or not token.startswith('ghp_'):
    print("❌ Неверный формат токена. Токен должен начинаться с 'ghp_'")
    exit(1)

# Обновляем конфигурацию
config['github']['token'] = token

# Сохраняем
with open(config_file, 'w') as f:
    json.dump(config, f, indent=4)

print("\n✅ Токен успешно сохранен в feedback_config.json")
print("\n🚀 Теперь можно запустить сервер:")
print("   python3 feedback_server.py") 