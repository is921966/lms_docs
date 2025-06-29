#!/bin/bash

echo "🧪 Testing LMS Feedback Server on Render"
echo "========================================"
echo ""

CLOUD_URL="https://lms-feedback-server.onrender.com"

# Test dashboard
echo "📊 Testing dashboard..."
curl -s -o /dev/null -w "Dashboard: %{http_code}\n" $CLOUD_URL

# Test API endpoint
echo ""
echo "🔌 Testing API endpoint..."
curl -s -o /dev/null -w "API endpoint: %{http_code}\n" $CLOUD_URL/api/v1/feedback

# Test feedback list
echo ""
echo "📋 Testing feedback list..."
curl -s -o /dev/null -w "Feedback list: %{http_code}\n" $CLOUD_URL/api/v1/feedback/list

# Send test feedback
echo ""
echo "📤 Sending test feedback..."
RESPONSE=$(curl -s -X POST $CLOUD_URL/api/v1/feedback \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Cloud Test from Script",
    "description": "Testing cloud deployment on Render",
    "category": "test",
    "userEmail": "test@example.com",
    "appVersion": "1.1.0",
    "iosVersion": "18.5",
    "deviceModel": "Test Script"
  }')

echo "Response: $RESPONSE"

echo ""
echo "✅ Testing complete!"
echo ""
echo "🌐 Dashboard URL: $CLOUD_URL"
echo "📱 iOS endpoint: $CLOUD_URL/api/v1/feedback" 