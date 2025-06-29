import Foundation

class ServerFeedbackService: FeedbackServiceProtocol {
    // Автоматически настроенный URL для реального устройства
    private let serverURL = "http://192.168.68.104:5001/api/v1/feedback"
    
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
