#!/bin/bash

echo "🧪 Тестирование отправки feedback"
echo "================================="
echo ""

# IP адрес из настроек
IP_ADDRESS="192.168.68.104"

# Тестовые данные
FEEDBACK_JSON=$(cat <<EOF
{
  "id": "test-$(date +%s)",
  "text": "Тестовый feedback с реального устройства",
  "type": "test",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "deviceInfo": {
    "model": "iPhone Test",
    "osVersion": "18.0",
    "appVersion": "1.1.0",
    "buildNumber": "100",
    "screenSize": "393x852",
    "locale": "ru_RU"
  }
}
EOF
)

echo "📤 Отправка тестового feedback на http://$IP_ADDRESS:5001/api/v1/feedback"
echo ""

# Отправляем запрос
RESPONSE=$(curl -s -X POST \
  "http://$IP_ADDRESS:5001/api/v1/feedback" \
  -H "Content-Type: application/json" \
  -d "$FEEDBACK_JSON" \
  -w "\nHTTP_CODE:%{http_code}")

# Извлекаем HTTP код
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE:" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE:/d')

if [ "$HTTP_CODE" = "201" ]; then
    echo "✅ Feedback успешно отправлен!"
    echo ""
    echo "Ответ сервера:"
    echo "$BODY" | python3 -m json.tool
    echo ""
    echo "📊 Проверьте dashboard: http://$IP_ADDRESS:5001"
    
    # Извлекаем GitHub issue URL если есть
    GITHUB_URL=$(echo "$BODY" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('github_issue', ''))" 2>/dev/null)
    if [ ! -z "$GITHUB_URL" ]; then
        echo "📝 GitHub Issue: $GITHUB_URL"
    fi
else
    echo "❌ Ошибка отправки feedback"
    echo "HTTP код: $HTTP_CODE"
    echo "Ответ: $BODY"
fi 