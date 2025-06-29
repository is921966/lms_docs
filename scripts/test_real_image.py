#!/usr/bin/env python3
"""
Тест с реальным PNG изображением
"""

import requests
import json
import base64
from datetime import datetime

# URL сервера
SERVER_URL = "https://lms-feedback-server.onrender.com"

# Создаем настоящее PNG изображение (красный квадрат 10x10)
def create_real_png():
    # Настоящий PNG файл - красный квадрат 10x10 пикселей
    png_hex = """
    89504e470d0a1a0a0000000d49484452000000640000006408020000
    00ff80020300000017494441547801edc1010d000000c2a0f74f6d0e
    37a00000000000000000be0d21000001ff199c0000000049454e44ae
    426082
    """
    # Убираем пробелы и переводы строк
    png_hex = png_hex.replace('\n', '').replace(' ', '')
    # Конвертируем hex в bytes
    png_bytes = bytes.fromhex(png_hex)
    # Кодируем в base64
    return base64.b64encode(png_bytes).decode('utf-8')

# Данные отзыва
feedback_data = {
    "type": "bug",
    "text": f"Тест с реальным PNG изображением ({datetime.now().strftime('%H:%M:%S')})",
    "userEmail": "test@example.com",
    "userName": "Test User",
    "deviceInfo": {
        "model": "iPhone 15 Pro",
        "osVersion": "iOS 17.5",
        "appVersion": "2.0.2",
        "buildNumber": "100",
        "locale": "ru-RU",
        "screenSize": "390x844"
    },
    "timestamp": datetime.now().isoformat(),
    "screenshot": create_real_png()
}

print("🖼️  Тест с реальным PNG изображением")
print("=" * 50)
print(f"📏 Размер base64: {len(feedback_data['screenshot'])} символов")

# Отправка
try:
    response = requests.post(
        f"{SERVER_URL}/api/v1/feedback",
        json=feedback_data,
        headers={"Content-Type": "application/json"},
        timeout=30
    )
    
    print(f"\n📥 Статус: {response.status_code}")
    
    if response.status_code in [200, 201]:
        result = response.json()
        print(f"✅ Успешно!")
        
        if result.get('github_issue'):
            print(f"\n🔗 GitHub Issue: {result['github_issue']}")
            print("\n⚡ Проверьте issue - изображение должно быть загружено через Imgur!")
        else:
            print(f"\n❌ GitHub Issue не создан")
            print(f"Ответ: {json.dumps(result, indent=2)}")
    else:
        print(f"❌ Ошибка: {response.text}")
        
except Exception as e:
    print(f"❌ Ошибка: {str(e)}") 