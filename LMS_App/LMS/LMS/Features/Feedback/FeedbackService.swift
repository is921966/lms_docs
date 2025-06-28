import Foundation
import UIKit

class FeedbackService {
    static let shared = FeedbackService()
    
    // Конфигурация для вашего backend
    private let baseURL = "https://your-api.com/api/v1" // Замените на ваш URL
    private let apiKey = "your-api-key" // Замените на ваш API ключ
    
    // Для тестирования можно использовать mock endpoint
    private let useMockEndpoint = true
    private let mockEndpoint = "https://httpbin.org/post"
    
    private init() {}
    
    func submit(_ feedback: FeedbackModel, completion: @escaping (Bool) -> Void) {
        if useMockEndpoint {
            // Для тестирования отправляем на httpbin
            submitToMockEndpoint(feedback, completion: completion)
        } else {
            // Реальная отправка на ваш backend
            submitToBackend(feedback, completion: completion)
        }
    }
    
    private func submitToBackend(_ feedback: FeedbackModel, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/feedback") else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(feedback)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Feedback submission error: \(error)")
                    completion(false)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    let success = (200...299).contains(httpResponse.statusCode)
                    
                    if !success, let data = data {
                        let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                        print("Feedback submission failed: \(errorMessage)")
                    }
                    
                    completion(success)
                } else {
                    completion(false)
                }
            }.resume()
        } catch {
            print("Feedback encoding error: \(error)")
            completion(false)
        }
    }
    
    private func submitToMockEndpoint(_ feedback: FeedbackModel, completion: @escaping (Bool) -> Void) {
        // Для демонстрации отправляем на httpbin.org
        guard let url = URL(string: mockEndpoint) else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Создаем упрощенную версию для отправки
        let simplifiedFeedback: [String: Any] = [
            "id": feedback.id.uuidString,
            "type": feedback.type,
            "text": feedback.text,
            "hasScreenshot": feedback.screenshot != nil,
            "device": feedback.deviceInfo.model,
            "osVersion": feedback.deviceInfo.osVersion,
            "appVersion": feedback.deviceInfo.appVersion,
            "timestamp": ISO8601DateFormatter().string(from: feedback.timestamp)
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: simplifiedFeedback)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Mock submission error: \(error)")
                    completion(false)
                    return
                }
                
                // Для mock endpoint считаем успешным любой ответ
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("Mock response: \(json)")
                    completion(true)
                } else {
                    completion(false)
                }
            }.resume()
        } catch {
            print("Mock encoding error: \(error)")
            completion(false)
        }
    }
    
    // Дополнительный метод для сохранения feedback локально
    func saveLocally(_ feedback: FeedbackModel) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, 
                                                     in: .userDomainMask).first!
        let feedbackPath = documentsPath.appendingPathComponent("feedback")
        
        // Создаем директорию если не существует
        try? FileManager.default.createDirectory(at: feedbackPath, 
                                                withIntermediateDirectories: true)
        
        // Сохраняем feedback
        let filePath = feedbackPath.appendingPathComponent("\(feedback.id.uuidString).json")
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(feedback)
            try data.write(to: filePath)
            
            // Сохраняем скриншот отдельно если есть
            if let screenshotBase64 = feedback.screenshot,
               let screenshotData = Data(base64Encoded: screenshotBase64) {
                let screenshotPath = feedbackPath.appendingPathComponent("\(feedback.id.uuidString).png")
                try screenshotData.write(to: screenshotPath)
            }
            
            print("Feedback saved locally: \(filePath.path)")
        } catch {
            print("Failed to save feedback locally: \(error)")
        }
    }
    
    // Метод для получения всех локальных feedback (для отправки позже)
    func getLocalFeedback() -> [FeedbackModel] {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, 
                                                     in: .userDomainMask).first!
        let feedbackPath = documentsPath.appendingPathComponent("feedback")
        
        guard let files = try? FileManager.default.contentsOfDirectory(at: feedbackPath, 
                                                                      includingPropertiesForKeys: nil) else {
            return []
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return files.compactMap { file in
            guard file.pathExtension == "json",
                  let data = try? Data(contentsOf: file),
                  let feedback = try? decoder.decode(FeedbackModel.self, from: data) else {
                return nil
            }
            return feedback
        }
    }
} 