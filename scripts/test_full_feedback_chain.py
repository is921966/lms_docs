#!/usr/bin/env python3
"""
Полная проверка цепочки обратной связи со скриншотом
"""

import requests
import json
import base64
from datetime import datetime

# URL сервера
SERVER_URL = "https://lms-feedback-server.onrender.com"

# Создаем тестовое изображение (красный квадрат 100x100)
def create_test_image():
    # PNG header + IHDR chunk
    png_data = b'\x89PNG\r\n\x1a\n'
    png_data += b'\x00\x00\x00\rIHDR\x00\x00\x00d\x00\x00\x00d\x08\x02\x00\x00\x00\xff\x80\x02\x03'
    # IDAT chunk with red pixels
    png_data += b'\x00\x00\x00\x1eIDAT\x78\x9c\xed\xc1\x01\r\x00\x00\x00\xc2\xa0\xf7Om\x0e7\xa0\x00\x00\x00\x00\x00\x00\x00\x00\xbe\r!\x00\x00\x01\x7f\x19\x9c'
    # IEND chunk
    png_data += b'\x00\x00\x00\x00IEND\xaeB`\x82'
    return base64.b64encode(png_data).decode('utf-8')

# Данные отзыва
feedback_data = {
    "type": "bug",
    "text": f"Тест полной цепочки: скриншот → Imgur → GitHub ({datetime.now().strftime('%Y-%m-%d %H:%M:%S')})",
    "userEmail": "test@example.com",
    "userName": "Test Script",
    "deviceInfo": {
        "model": "Test Device",
        "osVersion": "Test OS",
        "appVersion": "2.0.2",
        "buildNumber": "100",
        "locale": "ru-RU",
        "screenSize": "390x844"
    },
    "timestamp": datetime.now().isoformat(),
    "screenshot": create_test_image()
}

print("📤 Тестирование полной цепочки обратной связи")
print("=" * 50)
print(f"📍 Сервер: {SERVER_URL}")
print(f"📝 Тип: {feedback_data['type']}")
print(f"💬 Сообщение: {feedback_data['text']}")
print(f"🖼️  Скриншот: Тестовое изображение (красный квадрат 100x100)")
print(f"📏 Размер base64: {len(feedback_data['screenshot'])} символов")

# Проверка здоровья сервера
print("\n1️⃣ Проверка сервера...")
try:
    health_response = requests.get(f"{SERVER_URL}/health", timeout=10)
    if health_response.status_code == 200:
        health_data = health_response.json()
        print(f"   ✅ Сервер работает")
        print(f"   GitHub: {'✅' if health_data.get('github_configured') else '❌'}")
        print(f"   Imgur: {'✅' if health_data.get('imgur_configured') else '❌'}")
    else:
        print(f"   ❌ Сервер недоступен: {health_response.status_code}")
except Exception as e:
    print(f"   ❌ Ошибка подключения: {e}")

# Отправка feedback
print("\n2️⃣ Отправка feedback...")
try:
    response = requests.post(
        f"{SERVER_URL}/api/v1/feedback",
        json=feedback_data,
        headers={"Content-Type": "application/json"},
        timeout=30
    )
    
    print(f"   Статус: {response.status_code}")
    
    if response.status_code in [200, 201]:
        result = response.json()
        print(f"   ✅ Успешно отправлено!")
        print(f"   ID: {result.get('id', 'не получен')}")
        
        if result.get('github_issue'):
            print(f"\n3️⃣ GitHub Issue создан:")
            print(f"   🔗 {result['github_issue']}")
            print(f"\n   ⚡ Проверьте issue - там должен быть скриншот!")
        else:
            print("\n   ⚠️  GitHub Issue URL не получен")
            print(f"   Ответ сервера: {json.dumps(result, indent=2)}")
    else:
        print(f"   ❌ Ошибка: {response.status_code}")
        print(f"   Ответ: {response.text}")
        
except Exception as e:
    print(f"   ❌ Ошибка при отправке: {str(e)}")

print("\n" + "=" * 50)
print("📊 Что проверить:")
print("1. GitHub Issue создан с изображением")
print("2. Изображение загружено на Imgur")
print("3. В приложении скриншот должен отображаться в ленте") 