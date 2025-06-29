#!/bin/bash

echo "📱 Настройка для тестирования на реальном iPhone"
echo "================================================"
echo ""

# Получаем IP адрес Mac
IP_ADDRESS=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)

if [ -z "$IP_ADDRESS" ]; then
    echo "❌ Не удалось определить IP адрес"
    echo "Проверьте подключение к сети"
    exit 1
fi

echo "✅ Обнаружен IP адрес: $IP_ADDRESS"
echo ""

# Обновляем ServerFeedbackService.swift
SERVICE_FILE="../LMS/Services/Feedback/ServerFeedbackService.swift"

echo "📝 Обновляем ServerFeedbackService.swift..."

cat > "$SERVICE_FILE" << EOF
import Foundation

class ServerFeedbackService: FeedbackServiceProtocol {
    // Автоматически настроенный URL для реального устройства
    private let serverURL = "http://$IP_ADDRESS:5001/api/v1/feedback"
    
    // Для симулятора используйте:
    // private let serverURL = "http://localhost:5001/api/v1/feedback"
    
    private let session = URLSession.shared
    private let queue = DispatchQueue(label: "feedback.queue")
    
    func submitFeedback(_ feedback: FeedbackModel, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: serverURL) else {
            completion(.failure(FeedbackError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(feedback)
            
            session.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(FeedbackError.invalidResponse))
                    return
                }
                
                if httpResponse.statusCode == 201 {
                    if let data = data,
                       let response = try? JSONDecoder().decode(FeedbackResponse.self, from: data),
                       let githubIssue = response.github_issue {
                        completion(.success(githubIssue))
                    } else {
                        completion(.success("Feedback отправлен успешно"))
                    }
                } else {
                    completion(.failure(FeedbackError.serverError(httpResponse.statusCode)))
                }
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }
}

// Response model
private struct FeedbackResponse: Codable {
    let status: String
    let id: String
    let message: String
    let github_issue: String?
}

// Error types
enum FeedbackError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid server URL"
        case .invalidResponse:
            return "Invalid server response"
        case .serverError(let code):
            return "Server error: HTTP \(code)"
        }
    }
}
EOF

echo "✅ ServerFeedbackService.swift обновлен"
echo ""

# Создаем информационный файл
cat > real_device_info.txt << EOF
📱 Настройки для реального устройства
=====================================

IP адрес вашего Mac: $IP_ADDRESS
Порт сервера: 5001

URL для feedback: http://$IP_ADDRESS:5001/api/v1/feedback
Web dashboard: http://$IP_ADDRESS:5001

Инструкции:
1. Убедитесь, что iPhone и Mac в одной сети Wi-Fi
2. Feedback server должен быть запущен (./quick_start.sh)
3. Соберите приложение в Xcode для реального устройства
4. Откройте приложение на iPhone
5. Встряхните устройство для вызова feedback

Дата настройки: $(date)
EOF

echo "📋 Инструкции сохранены в real_device_info.txt"
echo ""

# Проверяем, запущен ли feedback server
if curl -s -o /dev/null -w "%{http_code}" http://localhost:5001 | grep -q "200"; then
    echo "✅ Feedback server уже запущен"
else
    echo "⚠️  Feedback server не запущен"
    echo "Запустите его командой: ./quick_start.sh <ваш_github_token>"
fi

echo ""
echo "🎯 Настройка завершена!"
echo ""
echo "Следующие шаги:"
echo "1. Откройте Xcode"
echo "2. Выберите ваш iPhone в качестве destination"
echo "3. Нажмите Run (Cmd+R)"
echo "4. На iPhone встряхните устройство для отправки feedback"
echo ""
echo "Dashboard доступен по адресу: http://$IP_ADDRESS:5001" 