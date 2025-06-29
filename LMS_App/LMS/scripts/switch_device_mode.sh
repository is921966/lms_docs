#!/bin/bash

echo "🔄 Переключение режима устройства"
echo "================================="
echo ""
echo "1) Симулятор (localhost)"
echo "2) Реальное устройство (IP: $(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1))"
echo ""
read -p "Выберите режим (1 или 2): " choice

SERVICE_FILE="../LMS/Services/Feedback/ServerFeedbackService.swift"

case $choice in
    1)
        echo "📱 Настройка для симулятора..."
        cat > "$SERVICE_FILE" << 'EOF'
import Foundation

class ServerFeedbackService: FeedbackServiceProtocol {
    // URL для симулятора
    private let serverURL = "http://localhost:5001/api/v1/feedback"
    
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
        echo "✅ Настроено для симулятора"
        ;;
    2)
        echo "📱 Настройка для реального устройства..."
        ./setup_real_device.sh
        ;;
    *)
        echo "❌ Неверный выбор"
        exit 1
        ;;
esac 