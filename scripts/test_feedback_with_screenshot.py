#!/usr/bin/env python3
"""
Тестовый скрипт для проверки работы feedback сервера с Imgur
"""

import requests
import json
import base64
from datetime import datetime

# URL сервера
SERVER_URL = "https://lms-feedback-server.onrender.com"

# Создаем простое тестовое изображение (1x1 красный пиксель PNG)
test_image_base64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg=="

# Данные отзыва
feedback_data = {
    "type": "bug",
    "message": "Тест: Проверка загрузки скриншотов через Imgur",
    "userEmail": "test@example.com",
    "userName": "Test User",
    "deviceInfo": {
        "model": "Test Script",
        "systemVersion": "Python",
        "appVersion": "1.0.0"
    },
    "timestamp": datetime.now().isoformat(),
    "screenshot": test_image_base64
}

print("📤 Отправка тестового отзыва со скриншотом...")
print(f"   URL: {SERVER_URL}/feedback")
print(f"   Тип: {feedback_data['type']}")
print(f"   Сообщение: {feedback_data['message']}")
print("   Скриншот: ✅ (тестовое изображение)")

try:
    response = requests.post(
        f"{SERVER_URL}/feedback",
        json=feedback_data,
        headers={"Content-Type": "application/json"},
        timeout=30
    )
    
    print(f"\n📥 Ответ сервера:")
    print(f"   Статус: {response.status_code}")
    
    if response.status_code == 200:
        result = response.json()
        print(f"   Результат: {json.dumps(result, indent=2)}")
        
        if result.get("github_issue_url"):
            print(f"\n✅ GitHub Issue создан успешно!")
            print(f"   URL: {result['github_issue_url']}")
            print(f"\n🔍 Проверьте issue - скриншот должен отображаться!")
        else:
            print("\n⚠️  GitHub Issue URL не получен")
    else:
        print(f"   Ошибка: {response.text}")
        
except Exception as e:
    print(f"\n❌ Ошибка при отправке: {str(e)}")

print("\n📊 Проверка статистики:")
try:
    stats = requests.get(f"{SERVER_URL}/stats", timeout=10)
    if stats.status_code == 200:
        print(f"   {stats.json()}")
except:
    print("   Статистика недоступна") 