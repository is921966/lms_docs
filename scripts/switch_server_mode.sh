#!/bin/bash

echo "🔄 Переключение режима серверов (Feedback + Logs)"
echo "================================================"
echo ""
echo "1) Локальные серверы (localhost)"
echo "2) Облачные серверы (Render.com)"
echo ""
read -p "Выберите режим (1 или 2): " choice

FEEDBACK_FILE="../LMS_App/LMS/LMS/Services/Feedback/ServerFeedbackService.swift"
LOG_FILE="../LMS_App/LMS/LMS/Services/Logging/LogUploader.swift"

case $choice in
    1)
        echo "💻 Настройка для локальных серверов..."
        
        # Update ServerFeedbackService
        sed -i '' 's|https://lms-feedback-server.onrender.com/api/v1/feedback|http://localhost:5001/api/v1/feedback|g' "$FEEDBACK_FILE"
        
        # Update LogUploader
        sed -i '' 's|https://lms-log-server.onrender.com/api/logs|http://localhost:5002/api/logs|g' "$LOG_FILE"
        
        echo "✅ Переключено на локальные серверы:"
        echo "   - Feedback: http://localhost:5001"
        echo "   - Logs: http://localhost:5002"
        echo ""
        echo "⚠️  Не забудьте запустить серверы:"
        echo "   python3 feedback_server.py"
        echo "   python3 log_server.py"
        ;;
        
    2)
        echo "☁️  Настройка для облачных серверов..."
        
        # Update ServerFeedbackService
        sed -i '' 's|http://localhost:5001/api/v1/feedback|https://lms-feedback-server.onrender.com/api/v1/feedback|g' "$FEEDBACK_FILE"
        
        # Update LogUploader
        sed -i '' 's|http://localhost:5002/api/logs|https://lms-log-server.onrender.com/api/logs|g' "$LOG_FILE"
        
        echo "✅ Переключено на облачные серверы:"
        echo "   - Feedback: https://lms-feedback-server.onrender.com"
        echo "   - Logs: https://lms-log-server.onrender.com"
        echo ""
        echo "📊 Dashboards:"
        echo "   - Feedback: https://lms-feedback-server.onrender.com"
        echo "   - Logs: https://lms-log-server.onrender.com"
        ;;
        
    *)
        echo "❌ Неверный выбор"
        exit 1
        ;;
esac

echo ""
echo "🔨 Теперь пересоберите приложение в Xcode" 